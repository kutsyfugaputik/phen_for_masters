import 'package:flutter/material.dart';
import 'package:masters/theme/modes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // Для доступа к ApiService
import 'package:masters/data/api_service.dart';

class SettingApp with ChangeNotifier {
  ThemeData _themeData = lightMode;
  ThemeData get themeData => _themeData;

  static const List<String> availableFontFamilies = ['Oswald', 'Playfair Display', 'Podkova', 'Shantell Sans'];

  String _selectedFontFamily = 'Oswald';
  String get selectedFontFamily => _selectedFontFamily;

  double _fontSizeMultiplier = 1.0;
  double get fontSizeMultiplier => _fontSizeMultiplier;

  // Constructor для загрузки настроек при инициализации
  SettingApp() {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await _loadSettings();
  }
  String _apiUrl = 'http://192.168.0.106:5000/api/'; // дефолтный URL

  String get apiUrl => _apiUrl;

  void setApiUrl(String url) {
    _apiUrl = url;
    notifyListeners();
  }

  // Метод для загрузки настроек из SharedPreferences
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Загрузка настроек темы
    String? savedTheme = prefs.getString('theme');
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'dark':
          _themeData = darkMode;
          break;
        case 'blue':
          _themeData = blueMode;
          break;
        case 'brown':
          _themeData = brownMode;
          break;
        case 'red':
          _themeData = redMode;
          break;
        default:
          _themeData = lightMode;
      }
    }

    // Загрузка выбранного шрифта
    String? savedFont = prefs.getString('fontFamily');
    if (savedFont != null && availableFontFamilies.contains(savedFont)) {
      _selectedFontFamily = savedFont;
    }

    // Загрузка мультипликатора размера шрифта
    _fontSizeMultiplier = prefs.getDouble('fontSizeMultiplier') ?? 1.0;

    notifyListeners();
  }

  // Метод для сохранения настроек в SharedPreferences
  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Сохраняем тему
    String themeString;
    if (_themeData == lightMode) {
      themeString = 'light';
    } else if (_themeData == darkMode) {
      themeString = 'dark';
    } else if (_themeData == blueMode) {
      themeString = 'blue';
    } else if (_themeData == brownMode) {
      themeString = 'brown';
    } else if (_themeData == redMode) {
      themeString = 'red';
    } else {
      themeString = 'light'; // Default to light if theme is unknown
    }
    prefs.setString('theme', themeString);

    // Сохраняем шрифт
    prefs.setString('fontFamily', _selectedFontFamily);

    // Сохраняем мультипликатор шрифта
    prefs.setDouble('fontSizeMultiplier', _fontSizeMultiplier);
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveSettings(); // Сохраняем изменения темы
    notifyListeners();
  }

  final List<ThemeData> _themes = [
    lightMode,
    darkMode,
    blueMode,
    brownMode,
    redMode,
    greenMode,
    purpleMode,
    orangeMode,
    iceMode,
    nightMode,
    sunsetMode,
    galaxyMode,
    steelMode,
    monoContrast,
    oceanIce
  ];

  void toggleTheme() {
    int currentIndex = _themes.indexOf(_themeData);
    int nextIndex = (currentIndex + 1) % _themes.length;
    themeData = _themes[nextIndex];
  }

  void setFontFamily(String fontFamily) {
    _selectedFontFamily = fontFamily;
    _saveSettings(); // Сохраняем изменение шрифта
    notifyListeners();
  }

  void setFontSizeMultiplier(double multiplier) {
    _fontSizeMultiplier = multiplier;
    _saveSettings(); // Сохраняем изменение размера шрифта
    notifyListeners();
  }

  // Метод для обновления URL API через ApiService
  void updateApiUrl(BuildContext context, String newUrl) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.setBaseUrl(newUrl);
  }
}
