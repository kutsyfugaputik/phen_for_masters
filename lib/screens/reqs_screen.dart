import 'package:flutter/material.dart';
import 'package:masters/data/data_repository.dart';
import 'package:masters/data/user_session.dart';
import 'package:masters/models/request.dart';
import 'package:masters/models/service.dart';
import 'package:masters/models/user.dart';
import 'package:masters/theme/settings.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:masters/data/api_service.dart';
import 'package:masters/widgets/section_title.dart';
class RequestManagementScreen extends StatefulWidget {
  const RequestManagementScreen({super.key});

  @override
  State<RequestManagementScreen> createState() => _RequestManagementScreenState();
}

class _RequestManagementScreenState extends State<RequestManagementScreen> {
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
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final masterId = UserSession().masterId;
    if (masterId == null) return;

    final allRequests = await repo.getReqMaster(masterId);

    if (allRequests is List<RequestModel>) {
      final pendingRequests = allRequests.where((r) =>
      r.masterId == masterId && r.statusId == 4).toList();

      final allUsers = await repo.getUsers();
      final allServices = await repo.getServices();

      setState(() {
        requests = pendingRequests;
        usersMap = {for (var u in allUsers) u.userId: u};
        servicesMap = {for (var s in allServices) s.serviceId.toString(): s};
        isLoading = false;
      });
    } else {
      print('Ошибка: Полученные данные не являются списком RequestModel');
    }
  }

  Future<void> _confirmRequest(String id) async {
    await repo.apiService.confirmRequest(id);
    await _loadRequests();
  }

  Future<void> _cancelRequest(String id) async {
    await repo.apiService.cancelRequest(id);
    await _loadRequests();
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
        title: const CustomTitle('Новые заявки'
        ),
        centerTitle: true,
        backgroundColor: theme.background.withOpacity(0.3),// Используем основной цвет
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? Center(child: Text('Нет заявок на подтверждение', style: textStyle))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          final user = usersMap[req.clientId]; // Используем clientId
          final service = servicesMap[req.serviceId.toString()];
          final dateStr = DateFormat('dd MMM, HH:mm', 'ru').format(req.startTime);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: theme.secondary.withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Дата: $dateStr', style: textStyle.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  if (user != null)
                    Text('Клиент: ${user.firstName} ${user.lastName}', style: textStyle),
                  if (service != null)
                    Text('Услуга: ${service.name}', style: textStyle),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _confirmRequest(req.requestId),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Подтвердить'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _cancelRequest(req.requestId),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Отменить'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
