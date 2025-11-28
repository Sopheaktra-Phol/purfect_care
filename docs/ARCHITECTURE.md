# Purfect Care - Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        APPLICATION LAYER                         │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Screens    │  │   Widgets    │  │    Theme     │         │
│  │              │  │              │  │              │         │
│  │ • Home       │  │ • PetCard    │  │ • LightTheme │         │
│  │ • Login      │  │ • SafeImage  │  │ • DarkTheme  │         │
│  │ • AddPet     │  │ • Reminder   │  │ • AppTheme   │         │
│  │ • PetDetail  │  │   Tile       │  │              │         │
│  │ • Settings   │  │ • Progress   │  │              │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Uses
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    STATE MANAGEMENT LAYER                        │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ AuthProvider │  │ PetProvider  │  │ReminderProvider│         │
│  │              │  │              │  │              │         │
│  │ • User state │  │ • Pets list  │  │ • Reminders  │         │
│  │ • Login      │  │ • CRUD ops   │  │ • Notify     │         │
│  │ • Logout     │  │ • Load data  │  │   scheduling │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐                            │
│  │HealthRecord  │  │ThemeProvider │                            │
│  │  Provider    │  │              │                            │
│  │              │  │ • Theme mode │                            │
│  │ • Records    │  │ • Toggle     │                            │
│  └──────────────┘  └──────────────┘                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Uses
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         SERVICE LAYER                            │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  Database    │  │Notification  │  │   Image       │         │
│  │   Service    │  │   Service    │  │   Service     │         │
│  │              │  │              │  │              │         │
│  │ • Hive ops   │  │ • Schedule   │  │ • Pick image │         │
│  │ • User ctx   │  │ • Cancel     │  │ • Save file  │         │
│  │ • CRUD       │  │ • Permissions│  │ • Delete     │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐                            │
│  │  Breed API   │  │  Firebase    │                            │
│  │   Service    │  │   Init       │                            │
│  │              │  │   Service    │                            │
│  │ • Fetch      │  │ • Initialize │                            │
│  │ • Cache      │  │ • Retry      │                            │
│  └──────────────┘  └──────────────┘                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Uses
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                              │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │     Hive     │  │SharedPrefs   │  │  File System  │         │
│  │   Database   │  │              │  │              │         │
│  │              │  │ • Theme      │  │ • Pet images  │         │
│  │ • Pets       │  │ • Auth state │  │ • Permanent   │         │
│  │ • Reminders  │  │              │  │   storage     │         │
│  │ • Records    │  │              │  │              │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                  │
│  ┌──────────────┐                                               │
│  │   Firebase   │  (Optional - configured but not fully used)  │
│  │              │                                               │
│  │ • Firestore  │                                               │
│  │ • Auth       │                                               │
│  │ • Storage    │                                               │
│  └──────────────┘                                               │
└─────────────────────────────────────────────────────────────────┘
```

## Component Interaction Flow

### User Login Flow

```
┌──────────┐
│   User   │
└────┬─────┘
     │ Enters credentials
     ▼
┌─────────────────┐
│  LoginScreen    │
│  • Validates    │
│  • Shows errors │
└────┬────────────┘
     │ Calls
     ▼
┌─────────────────┐
│  AuthProvider   │
│  • Validates    │
│  • Creates user │
│  • Saves state  │
└────┬────────────┘
     │ Notifies
     ▼
┌─────────────────┐
│  AuthWrapper    │
│  • Detects auth │
│  • Switches ctx │
└────┬────────────┘
     │ Calls
     ▼
┌─────────────────┐
│ DatabaseService │
│  • switchUser() │
│  • Opens boxes  │
└────┬────────────┘
     │ Then
     ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  PetProvider    │     │ReminderProvider │     │HealthRecord     │
│  • loadPets()   │     │ • loadReminders │     │  Provider       │
└─────────────────┘     └─────────────────┘     │ • loadRecords() │
                                                 └─────────────────┘
     │
     │ All notify listeners
     ▼
┌─────────────────┐
│  HomeScreen     │
│  • Displays     │
│    user data    │
└─────────────────┘
```

### Adding a Reminder Flow

```
┌──────────┐
│   User   │
└────┬─────┘
     │ Fills form
     ▼
┌─────────────────┐
│AddReminderScreen │
│  • Validates     │
│  • Collects data │
└────┬─────────────┘
     │ Submits
     ▼
┌─────────────────┐
│ReminderProvider │
│  • addReminder()│
└────┬────────────┘
     │
     ├─────────────────┐
     │                 │
     ▼                 ▼
┌─────────────┐  ┌──────────────┐
│Notification │  │DatabaseService│
│  Service    │  │  • addReminder│
│  • Schedule │  │  • Save to    │
│  • Get ID   │  │    Hive       │
└─────────────┘  └──────────────┘
     │                 │
     │                 │
     └────────┬────────┘
              │
              ▼
     ┌─────────────────┐
     │ReminderProvider │
     │  • Updates list │
     │  • Notifies UI  │
     └─────────────────┘
              │
              ▼
     ┌─────────────────┐
     │  HomeScreen     │
     │  • Updates      │
     └─────────────────┘
```

## Data Model Relationships

```
┌─────────────────────────────────────────────────────────┐
│                      User (AuthProvider)                 │
│                                                          │
│  • uid: String                                          │
│  • email: String?                                       │
│  • isAnonymous: bool                                    │
└─────────────────────────────────────────────────────────┘
                          │
                          │ owns (1-to-many)
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Pet (PetModel)                       │
│                                                          │
│  • id: int                                              │
│  • name: String                                         │
│  • species: String                                      │
│  • photoPath: String?                                   │
└─────────────────────────────────────────────────────────┘
        │                                    │
        │ has (1-to-many)                    │ has (1-to-many)
        ▼                                    ▼
┌──────────────────────┐      ┌──────────────────────────┐
│ Reminder (Reminder)  │      │ HealthRecord (HealthRecord)│
│                      │      │                          │
│  • id: int           │      │  • id: int               │
│  • petId: int        │      │  • petId: int            │
│  • title: String     │      │  • title: String         │
│  • time: DateTime    │      │  • date: DateTime        │
│  • notificationId    │      │  • notes: String?        │
└──────────────────────┘      └──────────────────────────┘
```

## State Management Pattern

```
┌─────────────────────────────────────────────────────────┐
│                    Provider Pattern                     │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │              ChangeNotifier                      │  │
│  │                                                  │  │
│  │  • State variables (private)                     │  │
│  │  • Public getters                                │  │
│  │  • Methods that modify state                     │  │
│  │  • notifyListeners() after changes              │  │
│  └──────────────────────────────────────────────────┘  │
│                          │                              │
│                          │ extends                     │
│                          ▼                              │
│  ┌──────────────────────────────────────────────────┐  │
│  │            PetProvider                          │  │
│  │                                                  │  │
│  │  • pets: List<PetModel>                         │  │
│  │  • loadPets()                                   │  │
│  │  • addPet()                                     │  │
│  │  • updatePet()                                  │  │
│  │  • deletePet()                                  │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
                          │ used by
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    UI Components                         │
│                                                          │
│  • context.watch<PetProvider>()  → Rebuilds on change  │
│  • context.read<PetProvider>()   → No rebuild          │
│  • Consumer<PetProvider>         → Selective rebuild   │
└─────────────────────────────────────────────────────────┘
```

## Storage Architecture

### Hive Box Structure

```
User Context: userId = "user123"

Hive Boxes:
├── pets_user123
│   ├── 0 → PetModel(id: 0, name: "Fluffy", ...)
│   ├── 1 → PetModel(id: 1, name: "Max", ...)
│   └── 2 → PetModel(id: 2, name: "Bella", ...)
│
├── reminders_user123
│   ├── 0 → ReminderModel(id: 0, petId: 0, ...)
│   ├── 1 → ReminderModel(id: 1, petId: 0, ...)
│   └── 2 → ReminderModel(id: 2, petId: 1, ...)
│
└── health_records_user123
    ├── 0 → HealthRecordModel(id: 0, petId: 0, ...)
    └── 1 → HealthRecordModel(id: 1, petId: 1, ...)
```

### File System Structure

```
App Documents Directory
└── pet_images/
    ├── 1234567890.jpg  (Pet 0 photo)
    ├── 1234567891.jpg  (Pet 1 photo)
    └── 1234567892.png  (Pet 2 photo)
```

### SharedPreferences Keys

```
• isLoggedIn: bool
• userId: String
• userEmail: String?
• isAnonymous: bool
• theme_mode: String
```

## Notification Architecture

```
┌─────────────────────────────────────────────────────────┐
│              Notification Scheduling Flow                │
│                                                          │
│  1. Reminder Created/Updated                            │
│     │                                                    │
│     ▼                                                    │
│  2. ReminderProvider.addReminder()                      │
│     │                                                    │
│     ▼                                                    │
│  3. NotificationService.scheduleNotification()         │
│     │                                                    │
│     ├─► Generate unique ID                             │
│     ├─► Choose emoji based on task type                 │
│     ├─► Convert to timezone-aware datetime              │
│     ├─► Schedule (one-time or repeating)               │
│     └─► Verify notification scheduled                   │
│     │                                                    │
│     ▼                                                    │
│  4. Store notificationId in ReminderModel               │
│     │                                                    │
│     ▼                                                    │
│  5. Save reminder to database                           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│            Notification Cancellation Flow                │
│                                                          │
│  1. Reminder Deleted/Completed                          │
│     │                                                    │
│     ▼                                                    │
│  2. ReminderProvider.deleteReminder() or                │
│     ReminderProvider.updateReminder()                   │
│     │                                                    │
│     ▼                                                    │
│  3. NotificationService.cancelNotification(id)          │
│     │                                                    │
│     ├─► Cancel by ID (if available)                     │
│     └─► Cancel by title (fallback)                      │
│     │                                                    │
│     ▼                                                    │
│  4. Verify cancellation                                 │
└─────────────────────────────────────────────────────────┘
```

## Multi-User Architecture

```
┌─────────────────────────────────────────────────────────┐
│              User Context Switching                     │
│                                                          │
│  User A Logs In                                          │
│    │                                                     │
│    ▼                                                     │
│  DatabaseService.switchUser("userA")                    │
│    │                                                     │
│    ├─► Close previous boxes (if any)                   │
│    ├─► Open pets_userA                                  │
│    ├─► Open reminders_userA                             │
│    └─► Open health_records_userA                        │
│    │                                                     │
│    ▼                                                     │
│  Providers load User A's data                           │
│                                                          │
│  ─────────────────────────────────────                  │
│                                                          │
│  User A Logs Out                                         │
│    │                                                     │
│    ▼                                                     │
│  DatabaseService.clearCurrentUserData()                 │
│    │                                                     │
│    ├─► Clear all boxes                                  │
│    ├─► Close boxes                                      │
│    └─► Reset currentUserId                              │
│    │                                                     │
│    ▼                                                     │
│  Providers clear in-memory data                         │
│                                                          │
│  ─────────────────────────────────────                  │
│                                                          │
│  User B Logs In                                          │
│    │                                                     │
│    ▼                                                     │
│  DatabaseService.switchUser("userB")                    │
│    │                                                     │
│    ├─► Open pets_userB                                  │
│    ├─► Open reminders_userB                             │
│    └─► Open health_records_userB                        │
│    │                                                     │
│    ▼                                                     │
│  Providers load User B's data                          │
└─────────────────────────────────────────────────────────┘
```

## Error Handling Strategy

```
┌─────────────────────────────────────────────────────────┐
│                  Error Handling Layers                   │
│                                                          │
│  UI Layer                                                │
│    │                                                     │
│    ├─► Try-catch for async operations                  │
│    ├─► Show SnackBar for user errors                    │
│    └─► Graceful fallbacks (placeholders)                │
│                                                          │
│  Provider Layer                                          │
│    │                                                     │
│    ├─► Validate inputs before operations               │
│    ├─► Set error messages                               │
│    └─► Notify listeners on errors                      │
│                                                          │
│  Service Layer                                           │
│    │                                                     │
│    ├─► Database: Throw exceptions for invalid state   │
│    ├─► Notifications: Return null/false on failure     │
│    ├─► Images: Return null/false on failure            │
│    └─► API: Return empty list on failure                │
│                                                          │
│  Data Layer                                              │
│    │                                                     │
│    ├─► Hive: Throws on uninitialized boxes             │
│    └─► Files: Returns false on missing files           │
└─────────────────────────────────────────────────────────┘
```

## Performance Considerations

### Caching Strategy

- **Breed Lists**: Cached in memory after first API call
- **Provider State**: Kept in memory, reloaded on user switch
- **Images**: Stored permanently, checked before display

### Optimization Patterns

- **Lazy Loading**: Providers load data on demand
- **Selective Rebuilds**: Use `Consumer` for specific widgets
- **Image Compression**: 80% quality on save
- **Notification Verification**: Async verification to avoid blocking

---

*Architecture documentation for Purfect Care*
*See TECHNICAL_DOCUMENTATION.md for detailed component documentation*

