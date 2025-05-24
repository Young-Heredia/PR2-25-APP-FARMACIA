// lib/views/splash_screen_view.dart

import 'package:flutter/material.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3)); // Espera 3 segundos
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home'); // Redirigir al HomeView
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO institucional
              Image.asset(
                'assets/images/logo/logo_splash.png',
                width: 180,
                height: 180,
              ),
              const SizedBox(height: 32),
              const Text(
                'Bienvenido a App Farmacia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                color: Colors.teal,
              ),
              const SizedBox(height: 60),
              const Text(
                'Cuidando tu salud, siempre.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
