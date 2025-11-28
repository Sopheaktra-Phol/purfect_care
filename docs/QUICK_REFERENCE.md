# Purfect Care - Quick Reference Guide

## File Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── models/                      # Data models
│   ├── pet_model.dart
│   ├── reminder_model.dart
│   └── health_record_model.dart
├── providers/                   # State management
│   ├── auth_provider.dart
│   ├── pet_provider.dart
│   ├── reminder_provider.dart
│   ├── health_record_provider.dart
│   └── theme_provider.dart
├── services/                    # Business logic
│   ├── database_service.dart
│   ├── notification_service.dart
│   ├── image_service.dart
│   ├── breed_api_service.dart
│   ├── firebase_init_service.dart
│   └── firebase_database_service.dart
├── screens/                     # UI screens
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── welcome_screen.dart
│   ├── splash_screen.dart
│   ├── add_pet_screen.dart
│   ├── pet_detail_screen.dart
│   ├── add_reminder_screen.dart
│   ├── today_tasks_screen.dart
│   ├── add_health_record_screen.dart
│   ├── health_tracker_screen.dart
│   ├── notifications_screen.dart
│   ├── settings_screen.dart
│   └── activity_log_screen.dart
├── widgets/                     # Reusable components
│   ├── pet_card.dart
│   ├── safe_image.dart
│   ├── reminder_tile.dart
│   ├── health_record_card.dart
│   ├── next_task_card.dart
│   └── progress_tracker.dart
├── theme/                       # Theming
│   ├── app_theme.dart
│   ├── light_theme.dart
│   └── dark_theme.dart
└── utils/                       # Utilities
    └── email_validator.dart
```

## Common Operations

### Adding a Pet

```dart
// 1. Create PetModel
final pet = PetModel(
  name: 'Fluffy',
  species: 'Cat',
  gender: 'Female',
  age: 2,
  breed: 'Persian',
);

// 2. Add via provider
await context.read<PetProvider>().addPet(pet);

// Provider automatically:
// - Saves to DatabaseService
// - Updates in-memory list
// - Notifies listeners (UI updates)
```

### Adding a Reminder

```dart
// 1. Create ReminderModel
final reminder = ReminderModel(
  petId: pet.id!,
  title: 'Feed',
  time: DateTime.now().add(Duration(hours: 2)),
  repeat: 'daily',
);

// 2. Add via provider (with pet reference)
await context.read<ReminderProvider>().addReminder(reminder, pet);

// Provider automatically:
// - Schedules notification
// - Saves to DatabaseService
// - Updates in-memory list
// - Notifies listeners
```

### Switching Users

```dart
// Called automatically by AuthWrapper when user logs in
await DatabaseService.switchUser(userId);

// This:
// - Closes previous user's boxes
// - Opens new user's boxes
// - Providers should reload data after this
```

### Scheduling a Notification

```dart
final notificationService = NotificationService();
final notificationId = await notificationService.scheduleNotification(
  petName: 'Fluffy',
  title: 'Feed',
  scheduledDate: DateTime.now().add(Duration(hours: 2)),
  repeat: 'daily',
);

// Store notificationId in ReminderModel
reminder.notificationId = notificationId;
```

### Loading Data

```dart
// Load pets
context.read<PetProvider>().loadPets();

// Load reminders
context.read<ReminderProvider>().loadReminders();

// Load health records
context.read<HealthRecordProvider>().loadHealthRecords();
```

## Provider Usage Patterns

### Reading Data

```dart
// Watch (rebuilds on changes)
final pets = context.watch<PetProvider>().pets;

// Read (no rebuild)
final pets = context.read<PetProvider>().pets;

// Consumer (for specific widgets)
Consumer<PetProvider>(
  builder: (context, petProvider, _) {
    return Text('Pets: ${petProvider.pets.length}');
  },
)
```

### Modifying Data

```dart
// Always use read() for modifications
final provider = context.read<PetProvider>();
await provider.addPet(pet);
// Provider automatically notifies listeners
```

## Database Operations

### Direct Database Access

```dart
// Add pet
final id = await DatabaseService.addPet(pet);

// Get all pets
final pets = DatabaseService.getAllPets();

// Update pet
await DatabaseService.updatePet(id, pet);

// Delete pet (cascades to reminders and images)
await DatabaseService.deletePet(id);
```

**Important**: Always call `DatabaseService.switchUser()` before database operations.

## Notification Operations

### Check Permissions

```dart
final notificationService = NotificationService();
final hasPermission = await notificationService.areNotificationsEnabled();
```

### Request Permissions

```dart
final granted = await notificationService.requestPermissions();
```

### Cancel Notification

```dart
// By ID
await notificationService.cancelNotification(notificationId);

// By title
await notificationService.cancelNotificationsByTitle('Feed');
```

## Image Operations

### Pick Image

```dart
final imageService = ImageService();

// From gallery
final file = await imageService.pickImageFromGallery();

// From camera
final file = await imageService.takePhoto();

// Use file.path in PetModel.photoPath
```

### Check Image Exists

```dart
final exists = await imageService.imageExists(imagePath);
```

### Delete Image

```dart
final deleted = await imageService.deleteImage(imagePath);
```

## Theme Operations

### Get Current Theme

```dart
final themeProvider = context.watch<ThemeProvider>();
final isDark = themeProvider.isDarkMode;
```

### Toggle Theme

```dart
await context.read<ThemeProvider>().toggleTheme();
```

### Set Specific Theme

```dart
await context.read<ThemeProvider>().setThemeMode(ThemeMode.dark);
```

## Navigation Patterns

### Named Routes

```dart
// Navigate to login
Navigator.pushNamed(context, '/login');

// Navigate to home
Navigator.pushNamed(context, '/home');
```

### Material Routes

```dart
// Navigate to screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => AddPetScreen()),
);

// Navigate and wait for result
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => AddPetScreen()),
);
```

### Replace All Routes

```dart
// Used on login/logout
Navigator.pushNamedAndRemoveUntil(
  context,
  '/home',
  (route) => false,
);
```

## Error Handling Patterns

### Database Errors

```dart
try {
  await DatabaseService.addPet(pet);
} catch (e) {
  // Handle error (e.g., user not switched)
  print('Error: $e');
}
```

### Notification Errors

```dart
try {
  final id = await notificationService.scheduleNotification(...);
} catch (e) {
  // Notification failed, but reminder can still be saved
  print('Notification error: $e');
}
```

### Image Errors

```dart
// Image operations return null/false on error
final file = await imageService.pickImageFromGallery();
if (file == null) {
  // User cancelled or error occurred
}
```

## Common Widget Patterns

### Safe Image Display

```dart
SafeImage(
  imagePath: pet.photoPath,
  fit: BoxFit.cover,
  placeholder: Icon(Icons.pets),
)
```

### Provider Consumer

```dart
Consumer<PetProvider>(
  builder: (context, petProvider, _) {
    return Text('${petProvider.pets.length} pets');
  },
)
```

### Loading State

```dart
if (authProvider.isLoading) {
  return CircularProgressIndicator();
}
```

## Data Model Relationships

```
User
  └── Pets (one-to-many)
      ├── Reminders (one-to-many)
      └── Health Records (one-to-many)
```

### Cascading Deletes

- Deleting a pet automatically:
  - Deletes all associated reminders
  - Cancels all associated notifications
  - Deletes pet image file

## Hive Box Structure

```
pets_{userId}           # PetModel objects
reminders_{userId}      # ReminderModel objects
health_records_{userId} # HealthRecordModel objects
```

## Notification ID Generation

```dart
// Uses timestamp modulo 2^31 for unique ID
final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
```

## Timezone Handling

All scheduled notifications use timezone-aware datetimes:

```dart
final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
```

## Common Issues & Solutions

### Issue: "User data not initialized"

**Solution**: Call `DatabaseService.switchUser(userId)` before database operations.

### Issue: Notifications not firing

**Solution**: 
1. Check permissions: `areNotificationsEnabled()`
2. Request permissions: `requestPermissions()`
3. Verify notification is scheduled: Check pending notifications

### Issue: Image not displaying

**Solution**: 
1. Check if file exists: `imageExists(imagePath)`
2. Verify path is correct
3. Use `SafeImage` widget for automatic fallback

### Issue: Data not persisting

**Solution**: 
1. Ensure `DatabaseService.init()` was called
2. Verify `switchUser()` was called
3. Check Hive adapters are registered

## Testing Patterns

### Mock Authentication

```dart
// AuthProvider uses mock authentication
// Any valid email + password (min 6 chars) works
```

### Test Notifications

```dart
// Show immediate test notification
await notificationService.showTestNotification(
  petName: 'Test Pet',
  title: 'Test Reminder',
);
```

### Check Pending Notifications

```dart
final pending = await notificationService.getPendingNotifications();
print('Pending: ${pending.length}');
```

---

*Quick Reference for Purfect Care*
*See TECHNICAL_DOCUMENTATION.md for detailed information*

