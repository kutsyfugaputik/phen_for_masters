import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _flowerController;
  late Animation<double> _flowerRotation;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    print('SplashScreen initialized');

    _flowerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _flowerRotation = Tween(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _flowerController, curve: Curves.easeInOut),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    // Ждём, пока отрисуется первый кадр, потом запускаем переход
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        print('Navigating to auth screen');
        Navigator.pushReplacementNamed(context, '/auth');
      });
    });
  }

  @override
  void dispose() {
    _flowerController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9C93CC), Color(0xFF87455B), Color(0xFF393163)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _flowerRotation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _flowerRotation.value,
                    child: Image.asset(
                      'assets/flower_3.png',
                      width: 130,
                      height: 130,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              _pastelText('П О Д Ф Е Н О М', 45),
              const SizedBox(height: 10),
              _pastelText('Добро пожаловать!', 30),
              const SizedBox(height: 6),
              _pastelText('Красота — это просто, когда ты с нами ✨', 16),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressController.value,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Colors.white24,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pastelText(String text, double size, {Color color = const Color(0xFFFFB8D2)}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}
