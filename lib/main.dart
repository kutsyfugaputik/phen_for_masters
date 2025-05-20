import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/reqs_screen.dart';
import 'screens/schedule_screen.dart';
import 'package:masters/data/api_service.dart'; // Импорт ApiService
import 'screens/stats_screen.dart';
import 'theme/settings.dart';


final apiService = ApiService(); // глобальный экземпляр

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);

  await apiService.restoreApiUrl(); // восстанавливаем URL из памяти

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingApp()),
        Provider<ApiService>.value(value: apiService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingApp>(context);

    return MaterialApp(
      title: 'Салон красоты',
      debugShowCheckedModeBanner: false,
      theme: settings.themeData,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/auth': (context) =>ScreenAuth(),
        '/clients': (context) =>  ClientsScreen(),
        '/menu': (context) => MenuScreen(),
        '/theme': (context) =>SettingsPage(),
        '/schedule': (context) =>  ScheduleScreen(),
        '/manage_requests': (context) => RequestManagementScreen(),
        '/statistics': (context) => MasterStatsPage(),

      },
    );
  }
}

