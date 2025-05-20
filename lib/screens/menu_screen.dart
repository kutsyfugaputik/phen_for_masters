import 'package:flutter/material.dart';
import 'package:masters/data/data_repository.dart';
import 'package:masters/models/user.dart';
import 'package:provider/provider.dart';
import 'package:masters/theme/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:masters/data/user_session.dart';
import 'package:masters/widgets/section_title.dart';
import 'package:masters/data/api_service.dart';  // Путь к файлу ApiService

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final apiService = ApiService();
  late final DataRepository repo;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    repo = DataRepository(apiService: apiService);
    _initialize();
  }

  Future<void> _initialize() async {
    await repo.init();
    _loadUserInfo();
  }
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = UserSession().userId;
    if (userId != null) {
      final data = await repo.getUsers();
      setState(() {
        user = data.firstWhere(
              (u) => u.userId == userId,
          orElse: () => UserModel(
            userId: '',
            firstName: 'Неизвестно',
            lastName: '',
            fatherName: null,
            email: '',
            birthday: DateTime.now(),
            phone: '',
            password: '',
          ),
        );
      });
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
        backgroundColor: theme.background.withOpacity(0.3),
        title: const CustomTitle('М е н ю'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: theme.inversePrimary),
            onPressed: () => Navigator.pushNamed(context, '/theme'),
          ),
        ],
      ),
      body: AnimationLimiter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (user != null)
              Card(
                elevation: 5,
                color: theme.secondary.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user!.firstName} ${user!.lastName}', style: textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Email: ${user!.email}', style: textStyle),
                      Text('Телефон: ${user!.phone}', style: textStyle),
                      Text('Возраст: ${_calculateAge(user!.birthday)} лет', style: textStyle),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(4, (index) => AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 500),
                columnCount: 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: _buildFancyCard(context, index, settings),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.50),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              label: Text(
                'Выйти из аккаунта',
                style: textStyle.copyWith(color: Colors.white),
              ),
              onPressed: () async {
                await repo.logoutUser();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Вы вышли из аккаунта')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFancyCard(BuildContext context, int index, SettingApp settings) {
    final List<Map<String, dynamic>> items = [
      { 'icon': Icons.people, 'title': 'Клиентура', 'route': '/clients' },
      { 'icon': Icons.assignment, 'title': 'Заявки', 'route': '/manage_requests' },
      { 'icon': Icons.calendar_today, 'title': 'Расписание', 'route': '/schedule' },
      { 'icon': Icons.bar_chart, 'title': 'Статистика', 'route': '/statistics' },
    ];

    final item = items[index];
    final theme = settings.themeData.colorScheme;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, item['route']),
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 24,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(30),
          ),
          color: theme.primary.withOpacity(0.7),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withOpacity(0.4),
              offset: const Offset(4, 6),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipPath(
          clipper: LaceClipper(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 16,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.inversePrimary.withOpacity(0.1),
                  child: Icon(item['icon'], color: theme.inversePrimary, size: 24),
                ),
              ),
              Positioned(
                bottom: 20,
                child: Text(
                  item['title'],
                  style: TextStyle(
                    fontSize: 16 * settings.fontSizeMultiplier,
                    fontFamily: settings.selectedFontFamily,
                    color: theme.inversePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  int _calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }
}

class LaceClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.3, size.width * 0.4, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.6, 0, size.width * 0.8, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.3, size.width, size.height * 0.25);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
