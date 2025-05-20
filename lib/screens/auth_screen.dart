import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masters/theme/settings.dart';
import 'package:masters/data/api_service.dart';
import 'package:provider/provider.dart';


class ScreenAuth extends StatefulWidget {
  const ScreenAuth({super.key});

  @override
  State<ScreenAuth> createState() => _ScreenAuthState();
}

class _ScreenAuthState extends State<ScreenAuth> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _login(ApiService apiService) async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _emailError = 'Введите почту');
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Введите пароль');
      return;
    }

    setState(() => _isLoading = true);
    try {
      print('🟡 Начинаем вход: email=$email');

      final success = await apiService.loginMaster(email, password);

      print('🟢 Ответ от loginUser: $success');

      if (!mounted) return;

      if (success) {
        _showSnackBar('Вход выполнен успешно!');
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        print('🔴 Ошибка авторизации: возможно, неправильные данные');
        _showSnackBar('Ошибка авторизации. Проверьте данные.');
      }
    } catch (e, stack) {
      print('🔴 Исключение при авторизации: $e');
      print(stack);
      _showSnackBar('Ошибка соединения. Попробуйте позже.');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingApp>(context);
    final theme = settings.themeData.colorScheme;
    final apiService = ApiService();

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Image.asset(
                      'assets/flower_2.png',
                      height: 90,
                      color: theme.primary.withOpacity(0.75),
                      colorBlendMode: BlendMode.modulate,
                    ),
                    Text(
                      'Войдите в свой аккаунт, мастер!',
                      style: TextStyle(
                        color: theme.inversePrimary,
                        fontSize: settings.fontSizeMultiplier * 20.0,
                        fontFamily: settings.selectedFontFamily,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _emailController,
                            style: TextStyle(
                              color: theme.inversePrimary,
                              fontFamily: settings.selectedFontFamily,
                              fontSize: 16 * settings.fontSizeMultiplier,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Почта',
                              hintStyle: TextStyle(
                                color: theme.inversePrimary.withOpacity(0.5),
                                fontFamily: settings.selectedFontFamily,
                              ),
                              prefixIcon: Icon(Icons.email, color: theme.primary),
                              errorText: _emailError,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: theme.primary.withOpacity(0.4)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: theme.primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(
                              color: theme.inversePrimary,
                              fontFamily: settings.selectedFontFamily,
                              fontSize: 16 * settings.fontSizeMultiplier,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Пароль',
                              hintStyle: TextStyle(
                                color: theme.inversePrimary.withOpacity(0.5),
                                fontFamily: settings.selectedFontFamily,
                              ),
                              prefixIcon: Icon(Icons.lock, color: theme.primary),
                              errorText: _passwordError,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: theme.primary.withOpacity(0.4)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: theme.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 16),
                      ),
                      onPressed: _isLoading ? null : () => _login(apiService),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                        'Войти',
                        style: GoogleFonts.montserrat(
                          fontSize: 16 * settings.fontSizeMultiplier,
                          color: theme.inversePrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: IconButton(
                icon: Icon(Icons.settings, color: theme.inversePrimary),
                onPressed: () {
                  Navigator.pushNamed(context, '/theme');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
