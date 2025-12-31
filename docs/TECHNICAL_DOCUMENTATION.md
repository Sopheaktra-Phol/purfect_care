# Purfect Care - Complete Technical Documentation

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Application Entry Point](#application-entry-point)
4. [Data Models](#data-models)
5. [State Management (Providers)](#state-management-providers)
6. [Services](#services)
7. [Screens](#screens)
8. [Widgets](#widgets)
9. [Theme System](#theme-system)
10. [Utilities](#utilities)
11. [Data Flow](#data-flow)
12. [Dependencies](#dependencies)

---

## Overview

**Purfect Care** is a Flutter-based mobile application for managing pet care. It allows users to:

- Track multiple pets with detailed profiles
- Schedule and manage reminders for pet care tasks
- Record health records and medical history
- Receive local notifications for scheduled tasks
- Switch between light and dark themes

### Key Technologies

- **Flutter**: Cross-platform mobile framework
- **Provider**: State management
- **Hive**: Local NoSQL database for offline storage
- **Firebase**: Cloud services (authentication, Firestore, Storage)
- **flutter_local_notifications**: Local notification scheduling

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Application Layer                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Screens  │  │ Widgets  │  │  Theme   │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                 State Management Layer                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │  Auth    │  │   Pet    │  │ Reminder │             │
│  │ Provider │  │ Provider │  │ Provider │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                    Service Layer                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │Database  │  │Notification│ │  Image   │             │
│  │ Service  │  │  Service   │ │ Service  │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                    Data Layer                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │   Hive   │  │ Firebase │  │  Local   │             │
│  │ Database │  │ Firestore│  │  Files   │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
```

### Design Patterns

1. **Provider Pattern**: State management using `provider` package
2. **Singleton Pattern**: Services use singleton pattern for single instance
3. **Repository Pattern**: DatabaseService abstracts data access
4. **Adapter Pattern**: Hive TypeAdapters for model serialization

---

## Application Entry Point

### File: `lib/main.dart`

**Purpose**: Application entry point and root widget configuration.

**Key Components**:

#### `main()` Function
- **Purpose**: Initializes app dependencies before running
- **Flow**:
  1. Ensures Flutter binding is initialized
  2. Initializes Hive for local storage
  3. Initializes DatabaseService (registers Hive adapters)
  4. Initializes NotificationService
  5. Requests notification permissions
  6. Runs the app

**Dependencies**:
- `Hive.initFlutter()`: Initializes Hive
- `DatabaseService.init()`: Registers model adapters
- `NotificationService.init()`: Sets up notification channels

#### `PurfectCare` Widget
- **Type**: StatelessWidget (root widget)
- **Purpose**: Configures MaterialApp with providers and themes
- **Providers Registered**:
  - `ThemeProvider`: Theme mode management
  - `AuthProvider`: Authentication state
  - `PetProvider`: Pet data management
  - `ReminderProvider`: Reminder data management
  - `HealthRecordProvider`: Health record management

**Routes**:
- `/login`: Login screen (with optional sign-up mode)
- `/home`: Home screen (wrapped in AuthWrapper)

#### `SplashWrapper` Widget
- **Type**: StatefulWidget
- **Purpose**: Shows splash screen for 2 seconds, then navigates to WelcomeScreen
- **State Management**: 
  - `_isInitialized`: Controls when to show welcome screen
  - `_initializeApp()`: Waits 2 seconds before showing welcome screen

#### `AuthWrapper` Widget
- **Type**: StatefulWidget
- **Purpose**: Manages authentication state and user data context switching
- **Key Logic**:
  - Watches `AuthProvider` for authentication changes
  - When user logs in: Switches database context and loads user data
  - When user logs out: Clears database and resets providers
  - Shows `LoginScreen` if not authenticated
  - Shows `HomeScreen` if authenticated

**Data Flow on Login**:
```
User Logs In
    ↓
AuthWrapper detects authentication
    ↓
DatabaseService.switchUser(userId)
    ↓
Opens user-specific Hive boxes
    ↓
Providers load data:
  - PetProvider.loadPets()
  - ReminderProvider.loadReminders()
  - HealthRecordProvider.loadHealthRecords()
```

**Data Flow on Logout**:
```
User Logs Out
    ↓
AuthWrapper detects logout
    ↓
DatabaseService.clearCurrentUserData()
    ↓
Clears all Hive boxes
    ↓
Providers clear in-memory data
    ↓
Providers reload (empty data)
```

---

## Data Models

All models implement Hive TypeAdapters for local storage.

### File: `lib/models/pet_model.dart`

**Purpose**: Represents a pet entity in the application.

**Properties**:
- `id` (int?): Unique identifier (Hive key)
- `name` (String): Pet's name
- `species` (String): Pet species (e.g., "Dog", "Cat")
- `gender` (String): Pet gender
- `age` (int): Pet age
- `breed` (String): Pet breed
- `photoPath` (String?): Path to pet photo file
- `notes` (String?): Additional notes
- `weight` (String?): Pet weight
- `height` (String?): Pet height
- `color` (String?): Pet color

**Hive Adapter**: `PetModelAdapter`
- **TypeId**: 0
- **Serialization**: Converts model to/from Map<String, dynamic>
- **Backward Compatibility**: Handles null gender for old data

**Usage**:
- Created in `AddPetScreen`
- Stored via `DatabaseService.addPet()`
- Displayed in `PetCard` widget
- Detailed view in `PetDetailScreen`

### File: `lib/models/reminder_model.dart`

**Purpose**: Represents a reminder/task for pet care.

**Properties**:
- `id` (int?): Unique identifier (Hive key)
- `petId` (int): Reference to associated pet
- `title` (String): Reminder title (e.g., "Feed", "Walk")
- `time` (DateTime): Scheduled time
- `repeat` (String): Repeat pattern ('none', 'daily', 'weekly', 'monthly')
- `notificationId` (int?): ID of scheduled notification
- `isCompleted` (bool): Completion status

**Hive Adapter**: `ReminderModelAdapter`
- **TypeId**: 1
- **Serialization**: Converts DateTime to ISO8601 string

**Usage**:
- Created in `AddReminderScreen`
- Stored via `DatabaseService.addReminder()`
- Scheduled notifications via `NotificationService`
- Displayed in `ReminderTile` widget

### File: `lib/models/health_record_model.dart`

**Purpose**: Represents a health record/medical event.

**Properties**:
- `id` (int?): Unique identifier (Hive key)
- `petId` (int): Reference to associated pet
- `title` (String): Record title (e.g., "Vaccination", "Checkup")
- `date` (DateTime): Date of health event
- `notes` (String?): Additional notes

**Hive Adapter**: `HealthRecordModelAdapter`
- **TypeId**: 2
- **Serialization**: Converts DateTime to ISO8601 string

**Usage**:
- Created in `AddHealthRecordScreen`
- Stored via `DatabaseService.addHealthRecord()`
- Displayed in `HealthRecordCard` widget

---

## State Management (Providers)

All providers extend `ChangeNotifier` and use the Provider pattern.

### File: `lib/providers/auth_provider.dart`

**Purpose**: Manages authentication state and user session.

**State Variables**:
- `_user` (LocalUser?): Current authenticated user
- `_isLoading` (bool): Loading state for async operations
- `_errorMessage` (String?): Error message for failed operations

**Public Getters**:
- `user`: Current user
- `isAuthenticated`: Whether user is logged in
- `isLoading`: Loading state
- `errorMessage`: Current error message

**Key Methods**:

#### `_init()`
- **Purpose**: Restores user session from SharedPreferences
- **Flow**: Checks saved login state and restores user if found
- **Called**: Automatically in constructor

#### `signInWithEmail(email, password)`
- **Purpose**: Authenticates user with email/password
- **Flow**:
  1. Validates email format using `EmailValidator`
  2. Validates password length (min 6 characters)
  3. Creates `LocalUser` with email-based UID
  4. Saves login state to SharedPreferences
  5. Notifies listeners
- **Returns**: `bool` (success/failure)

#### `signUpWithEmail(email, password)`
- **Purpose**: Creates new account (same logic as signIn)
- **Note**: Currently uses same validation as sign-in (mock authentication)

#### `signInWithGoogle()`
- **Purpose**: Authenticates with Google (mock implementation)
- **Returns**: `bool` (always succeeds in mock)

#### `signInAnonymously()`
- **Purpose**: Creates guest/anonymous session
- **Returns**: `bool` (always succeeds in mock)

#### `signOut()`
- **Purpose**: Logs out current user
- **Flow**: Clears user state and SharedPreferences

#### `_validateAndAuthenticate(email, password)`
- **Purpose**: Shared validation and authentication logic
- **Used by**: `signInWithEmail()` and `signUpWithEmail()`

**Dependencies**:
- `EmailValidator`: Email format validation
- `SharedPreferences`: Persistent storage

**Cross-References**:
- Used by: `LoginScreen`, `AuthWrapper`
- Triggers: User data loading in `AuthWrapper`

### File: `lib/providers/pet_provider.dart`

**Purpose**: Manages pet data in memory and coordinates with database.

**State Variables**:
- `pets` (List<PetModel>): In-memory list of all pets

**Key Methods**:

#### `loadPets()`
- **Purpose**: Loads all pets from database into memory
- **Flow**: Calls `DatabaseService.getAllPets()` and updates list
- **Triggers**: `notifyListeners()` for UI updates

#### `addPet(pet)`
- **Purpose**: Adds new pet to database and memory
- **Flow**:
  1. Saves to database via `DatabaseService.addPet()`
  2. Updates pet.id with returned key
  3. Adds to in-memory list
  4. Notifies listeners

#### `updatePet(id, pet)`
- **Purpose**: Updates existing pet
- **Flow**:
  1. Updates database via `DatabaseService.updatePet()`
  2. Updates in-memory list
  3. Notifies listeners

#### `deletePet(id)`
- **Purpose**: Deletes pet and associated data
- **Flow**:
  1. Deletes from database (cascades to reminders and images)
  2. Removes from in-memory list
  3. Notifies listeners

**Dependencies**:
- `DatabaseService`: Data persistence

**Cross-References**:
- Used by: `HomeScreen`, `AddPetScreen`, `PetDetailScreen`
- Updates: UI automatically via Provider listeners

### File: `lib/providers/reminder_provider.dart`

**Purpose**: Manages reminders and coordinates with notification service.

**State Variables**:
- `reminders` (List<ReminderModel>): In-memory list of all reminders

**Key Methods**:

#### `loadReminders()`
- **Purpose**: Loads all reminders from database
- **Flow**: Calls `DatabaseService.getAllReminders()` and updates list

#### `addReminder(reminder, pet)`
- **Purpose**: Adds reminder and schedules notification
- **Flow**:
  1. Checks if reminder is completed (skip notification if so)
  2. Requests notification permissions if needed
  3. Schedules notification via `NotificationService`
  4. Stores notification ID in reminder
  5. Saves to database
  6. Adds to in-memory list
  7. Handles errors gracefully (saves reminder even if notification fails)

#### `updateReminder(id, reminder, pet)`
- **Purpose**: Updates reminder and reschedules notification
- **Flow**:
  1. Cancels old notification if exists
  2. If completed: Cancels all related notifications and clears notification ID
  3. If not completed: Schedules new notification
  4. Updates database and memory
  5. Handles errors gracefully

#### `deleteReminder(id)`
- **Purpose**: Deletes reminder and cancels notification
- **Flow**:
  1. Cancels associated notification
  2. Deletes from database
  3. Removes from memory

#### `rescheduleAllNotifications(pets)`
- **Purpose**: Reschedules all incomplete reminders (used on app start)
- **Flow**:
  1. Iterates through all incomplete reminders
  2. Finds associated pet
  3. Cancels old notification
  4. Reschedules if time is in future
  5. Updates database with new notification ID

**Dependencies**:
- `DatabaseService`: Data persistence
- `NotificationService`: Notification scheduling

**Cross-References**:
- Used by: `HomeScreen`, `AddReminderScreen`, `TodayTasksScreen`
- Coordinates: Notification scheduling with reminder lifecycle

### File: `lib/providers/health_record_provider.dart`

**Purpose**: Manages health records data.

**State Variables**:
- `healthRecords` (List<HealthRecordModel>): In-memory list of all records

**Key Methods**:

#### `loadHealthRecords()`
- **Purpose**: Loads all health records from database

#### `addHealthRecord(record)`
- **Purpose**: Adds new health record
- **Flow**: Saves to database, updates memory, notifies listeners

#### `updateHealthRecord(id, record)`
- **Purpose**: Updates existing health record

#### `deleteHealthRecord(id)`
- **Purpose**: Deletes health record

**Dependencies**:
- `DatabaseService`: Data persistence

**Cross-References**:
- Used by: `PetDetailScreen`, `AddHealthRecordScreen`, `HealthTrackerScreen`

### File: `lib/providers/theme_provider.dart`

**Purpose**: Manages app theme mode (light/dark).

**State Variables**:
- `_themeMode` (ThemeMode): Current theme mode

**Key Methods**:

#### `_loadThemeMode()`
- **Purpose**: Loads saved theme preference from SharedPreferences
- **Called**: Automatically in constructor

#### `setThemeMode(mode)`
- **Purpose**: Sets theme mode and saves to preferences
- **Flow**: Updates state, saves to SharedPreferences, notifies listeners

#### `toggleTheme()`
- **Purpose**: Toggles between light and dark mode

**Dependencies**:
- `SharedPreferences`: Persistent storage

**Cross-References**:
- Used by: `PawfectCare` (MaterialApp), `HomeScreen` (theme toggle button)

---

## Services

Services provide business logic and external integrations.

### File: `lib/services/database_service.dart`

**Purpose**: Manages local data storage using Hive.

**Architecture**:
- Uses Hive boxes (NoSQL key-value store)
- Separate boxes per user (multi-user support)
- Box naming: `pets_{userId}`, `reminders_{userId}`, `health_records_{userId}`

**Key Methods**:

#### `init()`
- **Purpose**: Registers Hive adapters for all models
- **Called**: Once at app startup in `main()`
- **Registers**: PetModelAdapter, ReminderModelAdapter, HealthRecordModelAdapter

#### `switchUser(userId)`
- **Purpose**: Switches to user-specific data context
- **Flow**:
  1. Closes previous user's boxes
  2. Opens new user's boxes
  3. Stores current user ID

#### `clearCurrentUserData()`
- **Purpose**: Clears all data for current user
- **Flow**: Clears all boxes, closes them, resets user ID

#### Pet Operations:
- `addPet(pet)`: Adds pet, returns Hive key
- `getAllPets()`: Returns all pets from current user's box
- `updatePet(key, pet)`: Updates pet at key
- `deletePet(key)`: Deletes pet and cascades:
  - Deletes associated reminders
  - Deletes pet image file via `ImageService`

#### Reminder Operations:
- `addReminder(reminder)`: Adds reminder, returns key
- `getAllReminders()`: Returns all reminders
- `updateReminder(key, reminder)`: Updates reminder
- `deleteReminder(key)`: Deletes reminder

#### Health Record Operations:
- `addHealthRecord(record)`: Adds record, returns key
- `getAllHealthRecords()`: Returns all records
- `updateHealthRecord(key, record)`: Updates record
- `deleteHealthRecord(key)`: Deletes record

**Error Handling**:
- Throws exception if operations called before `switchUser()`
- Private getters (`_pets`, `_reminders`, `_healthRecords`) validate box state

**Dependencies**:
- `Hive`: Database engine
- `ImageService`: Image file deletion

**Cross-References**:
- Used by: All providers for data persistence
- Called by: `AuthWrapper` for user context switching

### File: `lib/services/notification_service.dart`

**Purpose**: Manages local notifications for reminders.

**Architecture**:
- Singleton pattern
- Uses `flutter_local_notifications` plugin
- Platform-specific implementations (Android/iOS)

**Key Methods**:

#### `init()`
- **Purpose**: Initializes notification plugin and requests permissions
- **Flow**:
  1. Initializes timezone data
  2. Configures Android/iOS settings
  3. Creates Android notification channel
  4. Requests platform-specific permissions

#### `scheduleNotification(petName, title, scheduledDate, repeat)`
- **Purpose**: Schedules a notification for a reminder
- **Flow**:
  1. Creates notification channel if needed
  2. Generates unique notification ID
  3. Chooses emoji based on task type (feed 🐶, walk 🚶, vet 🏥, groom ✂️)
  4. Creates notification body: "It's time to {action} {petName} {emoji}!"
  5. Converts to timezone-aware datetime
  6. Handles past dates (adjusts to 10 seconds from now for testing)
  7. Schedules one-time or repeating notification
  8. Verifies notification was scheduled
- **Returns**: Notification ID (stored in ReminderModel)

#### `_scheduleRepeating(id, title, body, scheduledTZ, details, repeat)`
- **Purpose**: Schedules repeating notifications
- **Repeat Options**:
  - `daily`: Repeats at same time every day
  - `weekly`: Repeats on same day of week
  - `monthly`: Repeats on same day of month

#### `cancelNotification(id)`
- **Purpose**: Cancels a scheduled notification
- **Flow**: Cancels notification and verifies cancellation

#### `cancelNotificationsByTitle(title)`
- **Purpose**: Cancels all notifications with matching title
- **Use Case**: Fallback when notification ID doesn't match

#### `requestPermissions()`
- **Purpose**: Requests notification permissions from user
- **Platform Handling**:
  - Android 13+: Requests runtime permission
  - iOS: Requests alert/badge/sound permissions
- **Returns**: `bool` (granted/denied)

#### `areNotificationsEnabled()`
- **Purpose**: Checks if notifications are enabled
- **Returns**: `bool`

**Dependencies**:
- `flutter_local_notifications`: Notification plugin
- `timezone`: Timezone-aware scheduling

**Cross-References**:
- Used by: `ReminderProvider` for scheduling/canceling
- Called by: `main()` for initial permission request

### File: `lib/services/image_service.dart`

**Purpose**: Manages pet image files.

**Architecture**:
- Stores images in app documents directory: `{appDir}/pet_images/`
- Uses unique filenames with timestamps
- Compresses images to 80% quality

**Key Methods**:

#### `pickImageFromGallery()`
- **Purpose**: Opens gallery picker and saves selected image
- **Flow**:
  1. Opens image picker
  2. Saves to permanent location via `_saveFile()`
- **Returns**: `File?` (null if user cancels)

#### `takePhoto()`
- **Purpose**: Opens camera and saves photo
- **Flow**: Same as `pickImageFromGallery()` but uses camera source

#### `_saveFile(sourceFile)`
- **Purpose**: Saves image to permanent storage
- **Flow**:
  1. Gets or creates images directory
  2. Generates unique filename: `{timestamp}{extension}`
  3. Copies file to permanent location
- **Returns**: `File` (permanent file path)

#### `deleteImage(imagePath)`
- **Purpose**: Deletes image file
- **Flow**: Checks if file exists, deletes if found
- **Returns**: `bool` (success/failure)
- **Error Handling**: Catches exceptions, returns false

#### `imageExists(imagePath)`
- **Purpose**: Checks if image file exists
- **Returns**: `bool`
- **Use Case**: Used by `SafeImage` widget to verify file before display

**Dependencies**:
- `image_picker`: Image selection
- `path_provider`: App directory access
- `dart:io`: File operations

**Cross-References**:
- Used by: `AddPetScreen` for image selection
- Used by: `DatabaseService` for image deletion
- Used by: `SafeImage` widget for file verification

### File: `lib/services/breed_api_service.dart`

**Purpose**: Fetches pet breed lists from external APIs.

**Architecture**:
- Singleton pattern
- Caches breed lists to avoid repeated API calls
- Fallback to hardcoded list if API fails

**Key Methods**:

#### `getDogBreeds()`
- **Purpose**: Fetches dog breeds from Dog CEO API
- **Flow**:
  1. Returns cached list if available
  2. Waits if already loading
  3. Fetches from `https://dog.ceo/api/breeds/list/all`
  4. Extracts breeds and sub-breeds
  5. Capitalizes and sorts breeds
  6. Caches result
- **Returns**: `List<String>` (empty list on error)

#### `getCatBreeds()`
- **Purpose**: Fetches cat breeds from The Cat API
- **Flow**:
  1. Returns cached list if available
  2. Fetches from `https://api.thecatapi.com/v1/breeds`
  3. Extracts breed names
  4. Falls back to `_getCommonCatBreeds()` on error
- **Returns**: `List<String>`

#### `_getCommonCatBreeds()`
- **Purpose**: Returns hardcoded list of common cat breeds
- **Use Case**: Fallback when API fails

#### `filterBreeds(breeds, query)`
- **Purpose**: Filters breed list by search query
- **Returns**: Filtered list (case-insensitive)

**Dependencies**:
- `http`: API requests

**Cross-References**:
- Used by: `AddPetScreen` for breed autocomplete

### File: `lib/services/firebase_init_service.dart`

**Purpose**: Centralized Firebase initialization with retry logic.

**Key Methods**:

#### `initialize(maxRetries)`
- **Purpose**: Initializes Firebase with retry logic
- **Flow**:
  1. Checks if already initialized
  2. Waits if initialization in progress
  3. Retries up to `maxRetries` times
  4. Handles platform channel errors specially
  5. Provides helpful error messages
- **Returns**: `bool` (success/failure)

#### `ensureInitialized(silent)`
- **Purpose**: Ensures Firebase is initialized (safe to call multiple times)
- **Flow**: Checks if initialized, calls `initialize()` if needed
- **Returns**: `bool`

**Dependencies**:
- `firebase_core`: Firebase initialization
- `firebase_options.dart`: Platform-specific config

**Cross-References**:
- Used by: `FirebaseDatabaseService` for authentication operations

---

## Screens

Screens are the main UI components of the application.

### File: `lib/screens/home_screen.dart`

**Purpose**: Main screen showing pets and upcoming tasks.

**Key Features**:
- Displays list of pets in grid layout
- Shows next upcoming reminder
- Shows today's task progress
- Provides navigation to other screens

**State Management**:
- Watches `PetProvider` and `ReminderProvider`
- Filters reminders for upcoming and today's tasks

**Navigation**:
- Tap pet card → `PetDetailScreen`
- Long press pet card → `AddPetScreen` (edit mode)
- Settings icon → `SettingsScreen`
- Notifications icon → `NotificationsScreen`
- FAB → `AddPetScreen` (add mode)

**Lifecycle**:
- On init: Requests notification permissions and reschedules notifications

**Widgets Used**:
- `PetCard`: Displays pet information
- `NextTaskCard`: Shows next reminder
- `ProgressTracker`: Shows today's task completion

### File: `lib/screens/login_screen.dart`

**Purpose**: Authentication screen with login/sign-up modes.

**Features**:
- Email/password authentication
- Google sign-in (mock)
- Anonymous/guest sign-in
- Email validation
- Password validation (min 6 characters)

**State Management**:
- Uses `AuthProvider` for authentication
- Listens to auth state changes for auto-navigation

**Navigation**:
- On successful login → Navigates to `/home`
- Guest login → Navigates directly to `/home`

**Validation**:
- Uses `EmailValidator` for email format validation
- Shows error messages via SnackBar

### File: `lib/screens/welcome_screen.dart`

**Purpose**: Onboarding screen shown on first launch.

**Features**:
- Welcome message and app introduction
- Navigation to login screen

**Flow**: Shown after splash screen, navigates to login when completed.

### File: `lib/screens/splash_screen.dart`

**Purpose**: Initial splash screen with app branding.

**Display**: Shown for 2 seconds via `SplashWrapper`.

### File: `lib/screens/add_pet_screen.dart`

**Purpose**: Form for adding/editing pets.

**Features**:
- Pet information form (name, species, gender, age, breed)
- Image picker (gallery/camera)
- Breed autocomplete using `BreedApiService`
- Validation
- Edit mode (if pet provided)

**State Management**:
- Uses `PetProvider` to save/update pets
- Updates provider after save

**Image Handling**:
- Uses `ImageService` for image selection
- Stores image path in `PetModel.photoPath`

### File: `lib/screens/pet_detail_screen.dart`

**Purpose**: Detailed view of a single pet.

**Features**:
- Pet information display
- List of reminders for pet
- List of health records for pet
- Navigation to add reminder/health record
- Edit pet functionality
- Delete pet functionality

**State Management**:
- Watches `ReminderProvider` and `HealthRecordProvider`
- Filters data by `petId`

### File: `lib/screens/add_reminder_screen.dart`

**Purpose**: Form for adding/editing reminders.

**Features**:
- Reminder form (title, time, repeat)
- Pet selection
- Time picker
- Repeat options (none, daily, weekly, monthly)
- Validation

**State Management**:
- Uses `ReminderProvider` to save/update
- Schedules notification on save

### File: `lib/screens/today_tasks_screen.dart`

**Purpose**: Shows all reminders for today.

**Features**:
- Lists today's reminders
- Mark as complete functionality
- Filters by completion status

**State Management**:
- Watches `ReminderProvider`
- Updates reminder completion status

### File: `lib/screens/add_health_record_screen.dart`

**Purpose**: Form for adding health records.

**Features**:
- Health record form (title, date, notes)
- Pet selection
- Date picker

**State Management**:
- Uses `HealthRecordProvider` to save

### File: `lib/screens/health_tracker_screen.dart`

**Purpose**: Health tracking overview.

**Features**:
- Displays health records

### File: `lib/screens/notifications_screen.dart`

**Purpose**: Shows pending notifications and notification settings.

**Features**:
- Lists pending notifications
- Test notification button
- Permission status

### File: `lib/screens/settings_screen.dart`

**Purpose**: App settings.

**Features**:
- Theme toggle
- Logout functionality
- App information

**State Management**:
- Uses `ThemeProvider` for theme switching
- Uses `AuthProvider` for logout

### File: `lib/screens/activity_log_screen.dart`

**Purpose**: Shows activity history.

---

## Widgets

Reusable UI components.

### File: `lib/widgets/pet_card.dart`

**Purpose**: Displays pet information in card format.

**Features**:
- Pet image with gradient overlay
- Pet name and breed
- Rounded corners and shadow
- Placeholder if no image

**Props**:
- `pet` (PetModel): Pet to display

**Uses**:
- `SafeImage`: For image display

### File: `lib/widgets/safe_image.dart`

**Purpose**: Safely displays image files with fallback.

**Features**:
- Checks if file exists before displaying
- Shows placeholder if file missing
- Handles loading state
- Error handling

**Components**:
- `SafeImage`: Regular image widget
- `SafeCircleAvatar`: Circular avatar version

**Uses**:
- `ImageService.imageExists()`: File verification

### File: `lib/widgets/reminder_tile.dart`

**Purpose**: Displays reminder in list format.

**Features**:
- Reminder title and time
- Completion status
- Pet name
- Tap to toggle completion

### File: `lib/widgets/health_record_card.dart`

**Purpose**: Displays health record in card format.

**Features**:
- Record title and date
- Notes display
- Styling

### File: `lib/widgets/next_task_card.dart`

**Purpose**: Displays next upcoming reminder.

**Features**:
- Shows next incomplete reminder
- Time until reminder
- Pet name
- Tap to navigate to reminder

### File: `lib/widgets/progress_tracker.dart`

**Purpose**: Shows task completion progress.

**Features**:
- Progress bar
- Completed/total task count
- Tap to navigate to today's tasks

---

## Theme System

### File: `lib/theme/app_theme.dart`

**Purpose**: Shared color constants for both themes.

**Colors**:
- `primary`: Green (#2E8771)
- `secondary`: White
- `accentOrange`: Orange (#FB930B)
- `accentRed`: Red (#E54D4D)
- `neutralGrey`: Grey (#D4D4D4)
- `textPrimary`: Black
- `textSecondary`: Grey (#666666)

### File: `lib/theme/light_theme.dart`

**Purpose**: Light theme configuration.

**Features**:
- Uses `AppTheme` colors
- White background
- Black text
- Material 2 design

### File: `lib/theme/dark_theme.dart`

**Purpose**: Dark theme configuration.

**Features**:
- Dark background (#0D1117)
- Light text (#E6EDF3)
- Adjusted colors for dark mode
- Better contrast ratios

**Theme Switching**:
- Controlled by `ThemeProvider`
- Persisted to SharedPreferences
- Applied globally via MaterialApp

---

## Utilities

### File: `lib/utils/email_validator.dart`

**Purpose**: Comprehensive email validation with typo detection.

**Features**:
- Email format validation
- Common typo detection (gmail.com → gamil.com)
- Domain validation
- TLD validation
- Character validation

**Key Methods**:

#### `validateEmail(email)`
- **Purpose**: Validates email format
- **Flow**:
  1. Checks for empty/null
  2. Validates @ symbol
  3. Validates local part (characters, length)
  4. Validates domain (format, TLD)
  5. Checks for common typos
  6. Full regex validation
- **Returns**: `String?` (null if valid, error message if invalid)

#### `_checkForTypo(domain)`
- **Purpose**: Checks if domain is typo of common domain
- **Returns**: Suggested correct domain or null

#### `_isTypo(domain1, domain2)`
- **Purpose**: Checks if domain1 is typo of domain2
- **Logic**: Compares character differences, swaps, missing chars

**Usage**:
- Used by `AuthProvider` for email validation
- Used by `LoginScreen` for form validation

---

## Data Flow

### User Login Flow

```
User enters credentials
    ↓
LoginScreen validates
    ↓
AuthProvider.signInWithEmail()
    ↓
Validates email (EmailValidator)
    ↓
Creates LocalUser
    ↓
Saves to SharedPreferences
    ↓
AuthProvider.notifyListeners()
    ↓
AuthWrapper detects authentication
    ↓
DatabaseService.switchUser(userId)
    ↓
Opens user-specific Hive boxes
    ↓
Providers load data:
  - PetProvider.loadPets()
  - ReminderProvider.loadReminders()
  - HealthRecordProvider.loadHealthRecords()
    ↓
UI updates via Provider listeners
    ↓
HomeScreen displays user data
```

### Adding a Reminder Flow

```
User fills reminder form
    ↓
AddReminderScreen submits
    ↓
ReminderProvider.addReminder()
    ↓
NotificationService.scheduleNotification()
    ↓
Generates notification ID
    ↓
Schedules local notification
    ↓
DatabaseService.addReminder()
    ↓
Saves to Hive
    ↓
ReminderProvider adds to memory
    ↓
ReminderProvider.notifyListeners()
    ↓
UI updates (HomeScreen, PetDetailScreen)
```

### Pet Deletion Flow

```
User deletes pet
    ↓
PetProvider.deletePet()
    ↓
DatabaseService.deletePet()
    ↓
Finds associated reminders
    ↓
Deletes all reminders (cascades)
    ↓
ImageService.deleteImage()
    ↓
Deletes pet image file
    ↓
Deletes pet from Hive
    ↓
PetProvider removes from memory
    ↓
PetProvider.notifyListeners()
    ↓
UI updates (removes pet card)
```

### Notification Scheduling Flow

```
Reminder created/updated
    ↓
ReminderProvider checks completion
    ↓
If not completed:
    ↓
NotificationService.scheduleNotification()
    ↓
Creates notification channel (Android)
    ↓
Generates unique ID
    ↓
Chooses emoji based on task type
    ↓
Converts to timezone-aware datetime
    ↓
Schedules (one-time or repeating)
    ↓
Verifies notification scheduled
    ↓
Returns notification ID
    ↓
Stored in ReminderModel.notificationId
```

---

## Dependencies

### Core Dependencies

- **flutter**: UI framework
- **provider**: State management
- **hive**: Local NoSQL database
- **hive_flutter**: Hive Flutter integration
- **path_provider**: App directory access
- **shared_preferences**: Key-value storage

### UI Dependencies

- **image_picker**: Image selection
- **lottie**: Animation support

### Notification Dependencies

- **flutter_local_notifications**: Local notifications
- **timezone**: Timezone-aware scheduling

### Firebase Dependencies

- **firebase_core**: Firebase initialization
- **cloud_firestore**: Firestore database
- **firebase_auth**: Authentication
- **firebase_storage**: File storage
- **google_sign_in**: Google authentication

### Utility Dependencies

- **http**: HTTP requests
- **intl**: Internationalization
- **collection**: Collection utilities

---

## Cross-Reference Map

### Models → Used By

- `PetModel` → `PetProvider`, `AddPetScreen`, `PetDetailScreen`, `PetCard`
- `ReminderModel` → `ReminderProvider`, `AddReminderScreen`, `ReminderTile`
- `HealthRecordModel` → `HealthRecordProvider`, `AddHealthRecordScreen`, `HealthRecordCard`

### Providers → Used By

- `AuthProvider` → `LoginScreen`, `AuthWrapper`, `SettingsScreen`
- `PetProvider` → `HomeScreen`, `AddPetScreen`, `PetDetailScreen`
- `ReminderProvider` → `HomeScreen`, `AddReminderScreen`, `TodayTasksScreen`, `PetDetailScreen`
- `HealthRecordProvider` → `AddHealthRecordScreen`, `PetDetailScreen`
- `ThemeProvider` → `PawfectCare`, `HomeScreen`, `SettingsScreen`

### Services → Used By

- `DatabaseService` → All providers
- `NotificationService` → `ReminderProvider`, `main()`, `NotificationsScreen`
- `ImageService` → `AddPetScreen`, `DatabaseService`, `SafeImage`
- `BreedApiService` → `AddPetScreen`
- `FirebaseInitService` → `FirebaseDatabaseService`

### Screens → Navigation

- `SplashScreen` → `WelcomeScreen`
- `WelcomeScreen` → `LoginScreen`
- `LoginScreen` → `HomeScreen` (via route)
- `HomeScreen` → `AddPetScreen`, `PetDetailScreen`, `SettingsScreen`, `NotificationsScreen`, `TodayTasksScreen`
- `PetDetailScreen` → `AddReminderScreen`, `AddHealthRecordScreen`, `AddPetScreen`

---

## Important Notes

### Multi-User Support

The app supports multiple users by:
- Using user-specific Hive boxes (prefixed with userId)
- Switching boxes when user logs in/out
- Clearing data on logout

### Offline-First

The app works offline:
- All data stored locally in Hive
- No network required for core functionality
- Firebase is optional (for cloud sync if implemented)

### Notification Handling

- Notifications are scheduled when reminders are created/updated
- Notifications are canceled when reminders are deleted/completed
- Notifications are rescheduled on app start to ensure they're active

### Error Handling

- Database operations throw exceptions if called before user context is set
- Notification failures don't prevent reminder saving
- Image operations fail gracefully (return false/null)
- API failures fall back to empty/hardcoded lists

---

## Future Enhancements

Potential areas for improvement:
- Firebase cloud sync implementation
- Real-time data synchronization
- Backup/restore functionality
- Export data functionality
- Multi-language support
- Advanced reminder scheduling
- Health record templates
- Pet weight tracking over time

---

*Documentation generated for Purfect Care application*
*Last updated: 2024*

