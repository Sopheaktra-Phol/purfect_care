import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/pet_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/health_record_provider.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart' show WelcomeScreen;
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await DatabaseService.init();
  
  // Initialize notifications
  try {
    final notificationService = NotificationService();
    await notificationService.init();
    
    // Always request permissions explicitly after initialization
    // This ensures the permission dialog appears on first launch
    await Future.delayed(const Duration(milliseconds: 500));
    print('=== Requesting notification permissions on app launch ===');
    final hasPermission = await notificationService.requestPermissions();
    if (hasPermission) {
      print('✓ Notification permissions granted');
    } else {
      print('⚠ Notification permissions not granted - user may need to enable in Settings');
    }
  } catch (e) {
    print('Notification service initialization error: $e');
  }
  
  runApp(const PawfectCare());
}

class PawfectCare extends StatelessWidget {
  const PawfectCare({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => HealthRecordProvider()),
      ],
      child: MaterialApp(
        title: 'Purfect Care',
        theme: AppTheme.lightTheme(),
        home: const SplashWrapper(),
        routes: {
          '/login': (context) {
            final isSignUp = ModalRoute.of(context)?.settings.arguments as bool? ?? false;
            return LoginScreen(initialMode: isSignUp ? LoginMode.signUp : LoginMode.login);
          },
          '/home': (context) => const AuthWrapper(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate minimum splash screen duration (2 seconds)
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }
    
    // Always show welcome screen first after splash screen
    // The welcome screen will handle navigation to login when completed
    return const WelcomeScreen();
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _lastUserId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final currentUserId = authProvider.user?.uid;
        
        // Switch user context and reload data when user changes
        if (authProvider.isAuthenticated && currentUserId != null && currentUserId != _lastUserId) {
          _lastUserId = currentUserId;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            // Switch to user's data context
            await DatabaseService.switchUser(currentUserId);
            // Load data
            if (!mounted) return;
            context.read<PetProvider>().loadPets();
            if (!mounted) return;
            context.read<ReminderProvider>().loadReminders();
            if (!mounted) return;
            context.read<HealthRecordProvider>().loadHealthRecords();
          });
        } else if (!authProvider.isAuthenticated && _lastUserId != null) {
          // Clear data when user logs out
          _lastUserId = null;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            await DatabaseService.clearCurrentUserData();
            if (!mounted) return;
            final petProv = context.read<PetProvider>();
            final reminderProv = context.read<ReminderProvider>();
            final healthProv = context.read<HealthRecordProvider>();
            petProv.pets.clear();
            reminderProv.reminders.clear();
            healthProv.healthRecords.clear();
            petProv.loadPets();
            reminderProv.loadReminders();
            healthProv.loadHealthRecords();
          });
        }
        
        // Show login screen if not authenticated
        if (!authProvider.isAuthenticated) {
          return const LoginScreen(initialMode: LoginMode.login);
        }
        
        // Show home screen if authenticated
        return const HomeScreen();
      },
    );
  }
}
