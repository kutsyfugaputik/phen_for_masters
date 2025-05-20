import 'package:flutter/material.dart';
import 'package:masters/data/data_repository.dart';
import 'package:masters/models/user.dart';
import 'package:masters/theme/settings.dart';
import 'package:provider/provider.dart';
import 'package:masters/data/user_session.dart';
import 'package:masters/data/api_service.dart';
import 'package:masters/widgets/section_title.dart';
class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  late DataRepository repo;
  List<UserModel> clients = [];
  List<UserModel> filteredClients = [];
  bool isLoading = true;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initRepoAndLoadClients();
    searchController.addListener(_filterClients);
  }

  Future<void> _initRepoAndLoadClients() async {
    final apiService = ApiService();
    repo = DataRepository(apiService: apiService);
    await repo.init();
    await _loadClients();
  }

  Future<void> _loadClients() async {
    final userId = UserSession().userId;
    final masterId = UserSession().masterId;
    if (userId != null && userId.isNotEmpty && masterId != null && masterId.isNotEmpty) {
      try {
        final requests = await repo.getReqMaster(masterId);
        final users = await repo.getUsers();

        if (requests.isEmpty || users.isEmpty) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          return;
        }

        final usersMap = {for (var u in users) u.userId: u};

        final myClients = requests
            .map((r) => usersMap[r.userId])
            .whereType<UserModel>()
            .toSet() // Убираем повторяющиеся элементы
            .toList(); // Преобразуем обратно в список


        myClients.sort((a, b) {
          return '${a.firstName} ${a.lastName}'.compareTo('${b.firstName} ${b.lastName}');
        });

        if (mounted) {
          setState(() {
            clients = myClients;
            filteredClients = myClients;
            isLoading = false;
          });
        }
      } catch (e) {
        print('Ошибка при загрузке клиентов: $e');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  void _filterClients() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredClients = clients.where((client) {
        final name = '${client.firstName} ${client.lastName}'.toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  int _calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingApp>(context);
    final theme = settings.themeData.colorScheme;
    final textStyle = TextStyle(
      fontFamily: settings.selectedFontFamily,
      fontSize: 16 * settings.fontSizeMultiplier,
      color: theme.inversePrimary,
    );

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const CustomTitle('Мои клиенты'
        ),
        centerTitle: true,
        backgroundColor: theme.background.withOpacity(0.3),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Поиск по имени',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          if (filteredClients.isEmpty)
            Expanded(
              child: Center(
                child: Text('Нет клиентов', style: textStyle),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredClients.length,
                itemBuilder: (context, index) {
                  final client = filteredClients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: theme.secondary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${client.firstName} ${client.lastName}',
                            style: textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          Text('Возраст: ${_calculateAge(client.birthday)}', style: textStyle),
                          Text('Телефон: ${client.phone}', style: textStyle),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
