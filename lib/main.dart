import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/pet_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/health_record_provider.dart';
import 'providers/weight_provider.dart';
import 'providers/milestone_provider.dart';
import 'providers/vaccination_provider.dart';
import 'providers/photo_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';
import 'services/firestore_database_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart' show WelcomeScreen;
import 'theme/light_theme.dart';
import 'theme/dark_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✓ Firebase initialized successfully');
    
    // Give Firebase a moment to fully establish platform channels
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Enable Firestore persistence
    try {
      FirestoreDatabaseService.enablePersistence();
      print('✓ Firestore persistence configured');
    } catch (e) {
      print('⚠ Could not configure Firestore persistence: $e');
    }
  } catch (e) {
    print('⚠ Firebase initialization error: $e');
  }

  await Hive.initFlutter();
  await DatabaseService.init();
  

  try {
    final notificationService = NotificationService();
    await notificationService.init();

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => HealthRecordProvider()),
        ChangeNotifierProvider(create: (_) => WeightProvider()),
        ChangeNotifierProvider(create: (_) => MilestoneProvider()),
        ChangeNotifierProvider(create: (_) => VaccinationProvider()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Purfect Care',
            theme: LightTheme.getTheme(),
            darkTheme: DarkTheme.getTheme(),
            themeMode: themeProvider.themeMode,
            home: const SplashWrapper(),
            routes: {
              '/login': (context) {
                final isSignUp = ModalRoute.of(context)?.settings.arguments as bool? ?? false;
                return LoginScreen(initialMode: isSignUp ? LoginMode.signUp : LoginMode.login);
              },
              '/home': (context) => const AuthWrapper(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
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
  bool _firebaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate minimum splash screen duration (2 seconds)
    await Future.delayed(const Duration(seconds: 2));
    
    // Firebase is already initialized in main(), so mark as ready
    if (mounted) {
      setState(() {
        _isInitialized = true;
        _firebaseInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen until both initialization and Firebase are ready
    if (!_isInitialized || !_firebaseInitialized) {
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
        
        // Load data from Firebase when user logs in
        if (authProvider.isAuthenticated && currentUserId != null && currentUserId != _lastUserId) {
          _lastUserId = currentUserId;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            // Load data from Firebase (Firebase handles user context automatically)
            if (!mounted) return;
            final petProv = context.read<PetProvider>();
            await petProv.loadPets();
            if (!mounted) return;
            // Load reminders and clean up orphaned ones
            await context.read<ReminderProvider>().loadReminders(pets: petProv.pets);
            if (!mounted) return;
            await context.read<HealthRecordProvider>().loadHealthRecords();
          });
        } else if (!authProvider.isAuthenticated && _lastUserId != null) {
          // Clear data when user logs out
          _lastUserId = null;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            final petProv = context.read<PetProvider>();
            final reminderProv = context.read<ReminderProvider>();
            final healthProv = context.read<HealthRecordProvider>();
            petProv.clearPets();
            reminderProv.reminders.clear();
            healthProv.healthRecords.clear();
            petProv.notifyListeners();
            reminderProv.notifyListeners();
            healthProv.notifyListeners();
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
