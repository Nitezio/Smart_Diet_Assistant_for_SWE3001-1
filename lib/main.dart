import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/app_state.dart';
import 'screens/role_selection_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      home: Consumer<AppState>(
        builder: (context, state, child) {
          if (!state.isProfileLoaded) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            );
          }
          return state.user != null ? const HomeScreen() : const RoleSelectionScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin_login': (context) => const AdminLoginScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 🟢 NEW: Pre-populate credentials if they were saved
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<AppState>(context, listen: false);
      _emailController.text = state.savedEmail;
      _passwordController.text = state.savedPassword;
    });
  }

  void _handleLogin(BuildContext context, AppState state) async {
    final role = state.selectedRole;

    if (role == 'Family Member') {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _codeController.text.length != 7) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter Email, Password, and 7-char Connection Code")),
        );
        return;
      }

      // 🟢 NEW: Link to primary user data via code (even if they are logged out)
      final success = await state.loginAsFamily(_codeController.text);
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Connection Code. No profile found with that code.")),
        );
      }
    } else {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter Email and Password")));
        return;
      }

      // 🟢 NEW: Attempt Login with saved account
      final success = await state.loginWithCredentials(_emailController.text, _passwordController.text);
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // New User -> Go to Onboarding
        Navigator.pushNamed(
          context, 
          '/onboarding', 
          arguments: {'email': _emailController.text, 'pass': _passwordController.text}
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final role = state.selectedRole;
    final isFamily = role == 'Family Member';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.green),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.jpg', height: 120),
              const SizedBox(height: 20),
              const Text("Smart Diet Assistant", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Text("Login as $role", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 40),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: "Email Address",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder()
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder()
                ),
              ),

              if (isFamily) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  maxLength: 7,
                  decoration: const InputDecoration(
                      labelText: "Family Connection Code (7-chars)",
                      helperText: "Get this from the primary user's profile",
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder()
                  ),
                ),
              ],

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => _handleLogin(context, state),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text("Login / Continue", style: TextStyle(fontSize: 18)),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
