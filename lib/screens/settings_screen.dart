import 'package:flutter/material.dart';
import 'package:masters/theme/settings.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:masters/data/api_service.dart'; // Импорт ApiService

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingApp>();
    final apiService = Provider.of<ApiService>(context, listen: false); // Получаем ApiService
    final theme = Theme.of(context);
    final fontSize = settings.fontSizeMultiplier;
    final fontFamily = settings.selectedFontFamily;  // Строка 14 final selectedFontFamily = Provider.of<SettingApp>(context).selectedFontFamily;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.colorScheme.background,
        title: Text(
          'Настройки',
          style: TextStyle(
            fontSize: fontSize * 22,
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.inversePrimary,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle(context, 'Профиль'),
          _card(
            context,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.chat, color: theme.colorScheme.primary),
                title: Text(
                  'Связь с Telegram-ботом',
                  style: TextStyle(
                    fontSize: fontSize * 16,
                    fontFamily: fontFamily,
                    color: theme.colorScheme.primary,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.secondary),
                onTap: () async {
                  await launchUrl(Uri.parse('https://web.telegram.org/k/#@pod_phenom_masha_bot'));
                },
              ),
            ],
          ),
          const SizedBox(height: 30),

          _sectionTitle(context, 'Оформление'),
          _card(
            context,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                title: Text(
                  'Тема',
                  style: TextStyle(
                    fontSize: fontSize * 16,
                    fontFamily: fontFamily,
                    color: theme.colorScheme.primary,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    settings.toggleTheme();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Тема изменена'), duration: Duration(seconds: 1)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Сменить',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: fontSize * 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _card(
            context,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  value: SettingApp.availableFontFamilies.contains(settings.selectedFontFamily)
                      ? settings.selectedFontFamily
                      : SettingApp.availableFontFamilies.first,
                  decoration: InputDecoration(
                    labelText: 'Шрифт',
                    labelStyle: TextStyle(color: theme.colorScheme.secondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  dropdownColor: theme.colorScheme.inversePrimary,
                  iconEnabledColor: theme.colorScheme.primary,
                  onChanged: (String? value) {
                    if (value != null) {
                      settings.setFontFamily(value);
                    }
                  },
                  items: SettingApp.availableFontFamilies.map((String font) {
                    return DropdownMenuItem<String>(
                      value: font,
                      child: Text(
                        font,
                        style: TextStyle(
                          fontFamily: font,
                          fontSize: fontSize * 14,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              ),
            ],
          ),
          const SizedBox(height: 20),
          _card(
            context,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Размер шрифта',
                      style: TextStyle(
                        fontSize: fontSize * 16,
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    Slider(
                      value: settings.fontSizeMultiplier,
                      min: 0.80,
                      max: 1.40,
                      divisions: 5,
                      activeColor: theme.colorScheme.primary,
                      label: '${(settings.fontSizeMultiplier * 100).round()}%',
                      onChanged: (value) {
                        settings.setFontSizeMultiplier(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          _sectionTitle(context, 'Подключение'),
          _card(
            context,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextFormField(
                  initialValue: settings.apiUrl,
                  onChanged: (value) async {
                    settings.setApiUrl(value);
                    apiService.setBaseUrl(value); // <--- обновляем URL в ApiService
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Адрес API обновлён'), duration: Duration(seconds: 1)),
                    );
                  },
                  decoration: InputDecoration(
                    labelText: 'Адрес API',
                    labelStyle: TextStyle(color: theme.colorScheme.secondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: fontSize * 14,
                    fontFamily: fontFamily,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final selectedFontFamily = Provider.of<SettingApp>(context).selectedFontFamily;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: selectedFontFamily,
          color: theme.colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
