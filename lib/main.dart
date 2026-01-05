import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState())],
      child: const SmartDietApp(),
    ),
  );
}

class SmartDietApp extends StatelessWidget {
  const SmartDietApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Diet Assistant',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        // Large fonts for elderly accessibility
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}