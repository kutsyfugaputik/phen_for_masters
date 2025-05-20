import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masters/data/data_repository.dart';
import 'package:masters/data/user_session.dart';
import 'package:masters/models/request.dart';
import 'package:masters/models/user.dart';
import 'package:masters/models/service.dart';
import 'package:masters/theme/settings.dart';
import 'package:provider/provider.dart';
import 'package:masters/data/api_service.dart';
import 'package:masters/widgets/section_title.dart';
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final apiService = ApiService();
  late final DataRepository repo;
  List<RequestModel> requests = [];
  Map<String, UserModel> usersMap = {};
  Map<String, ServiceModel> servicesMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    repo = DataRepository(apiService: apiService);
    _initialize();
  }

  Future<void> _initialize() async {
    await repo.init();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final masterId = UserSession().masterId;
    if (masterId != null) {
      try {
        final allRequests = await repo.getReqMaster(masterId);
        final allUsers = await repo.getUsers();
        final allServices = await repo.getServices();

        final now = DateTime.now();
        final nextWeek = now.add(const Duration(days: 7));

        final masterRequests = allRequests.where((r) {
          return r.masterId == masterId &&
              r.statusId == 3 &&  // статус заявки должен быть целым числом
              r.startTime.isAfter(now) &&
              r.startTime.isBefore(nextWeek);
        }).toList();

        if (mounted) {
          setState(() {
            requests = masterRequests;
            usersMap = {for (var u in allUsers) u.userId: u}; // Используем userId для пользователей
            servicesMap = {for (var s in allServices) s.serviceId.toString(): s};
            isLoading = false;
          });
        }
      } catch (e) {
        print('Ошибка при загрузке расписания: $e');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
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
        title: const CustomTitle('Мое расписание:'
        ),
        centerTitle: true,
        backgroundColor: theme.background.withOpacity(0.3),// Используем основной цвет
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? Center(child: Text('Нет записей на ближайшую неделю', style: textStyle))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          final user = usersMap[request.clientId]; // Используем clientId для получения пользователя
          final service = servicesMap[request.serviceId.toString()];
          final dateStr = DateFormat('EEEE, d MMMM', 'ru').format(request.startTime);
          final timeStr = DateFormat('HH:mm').format(request.startTime);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: theme.secondary.withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$dateStr в $timeStr',
                      style: textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 17)),
                  const SizedBox(height: 6),
                  if (user != null)
                    Text('Клиент: ${user.firstName} ${user.lastName}', style: textStyle),
                  if (service != null)
                    Text('Услуга: ${service.name}', style: textStyle),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
