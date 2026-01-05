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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
        // [SRS 5.4] Accessibility: Large, clear fonts
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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