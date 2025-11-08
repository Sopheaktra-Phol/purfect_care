import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/pet_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/health_record_provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await DatabaseService.init(); // opens boxes and registers adapters
  await NotificationService().init(); // init notifications
  runApp(const PawfectCare());
}

class PawfectCare extends StatelessWidget {
  const PawfectCare({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PetProvider()..loadPets()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()..loadReminders()),
        ChangeNotifierProvider(create: (_) => HealthRecordProvider()..loadHealthRecords()),
      ],
      child: MaterialApp(
        title: 'Pawfect Care',
        theme: AppTheme.lightTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
