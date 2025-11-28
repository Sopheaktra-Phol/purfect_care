# Purfect Care - Documentation Index

Welcome to the Purfect Care technical documentation. This documentation provides a complete guide to understanding how every component, file, and function works in the codebase.

## Documentation Files

### 📘 [Technical Documentation](./TECHNICAL_DOCUMENTATION.md)
**Complete technical reference** covering:
- Architecture overview
- All files and their purposes
- Every function and method
- Data flow diagrams
- Cross-references
- Dependencies

**Use this when you need to:**
- Understand how a specific component works
- Learn about the architecture
- Find detailed function documentation
- Understand data flow

### 📋 [Quick Reference Guide](./QUICK_REFERENCE.md)
**Quick lookup guide** with:
- Common code patterns
- File structure
- Provider usage examples
- Navigation patterns
- Error handling
- Troubleshooting

**Use this when you need to:**
- Quickly find code examples
- Remember how to use a specific feature
- Troubleshoot common issues
- Copy-paste code patterns

## Getting Started

### For New Developers

1. **Start with Architecture**: Read the [Architecture](#architecture) section in Technical Documentation
2. **Understand Entry Point**: Review `main.dart` documentation
3. **Learn State Management**: Study the Providers section
4. **Explore Services**: Understand how data persistence works
5. **Review Screens**: See how UI components are structured

### For Quick Tasks

1. **Find the Feature**: Use Quick Reference to locate relevant code
2. **Check Examples**: Copy code patterns from Quick Reference
3. **Understand Context**: Refer to Technical Documentation for details

## Key Concepts

### State Management
The app uses **Provider** pattern for state management:
- `AuthProvider`: User authentication
- `PetProvider`: Pet data
- `ReminderProvider`: Reminder data and notifications
- `HealthRecordProvider`: Health record data
- `ThemeProvider`: Theme preferences

### Data Storage
- **Hive**: Local NoSQL database (offline-first)
- **SharedPreferences**: User preferences
- **File System**: Pet images
- **Firebase**: Optional cloud sync (configured but not fully integrated)

### Navigation Flow
```
SplashScreen → WelcomeScreen → LoginScreen → HomeScreen
                                              ├── AddPetScreen
                                              ├── PetDetailScreen
                                              │   ├── AddReminderScreen
                                              │   └── AddHealthRecordScreen
                                              ├── TodayTasksScreen
                                              ├── SettingsScreen
                                              └── NotificationsScreen
```

## Architecture Overview

```
┌─────────────────────────────────────┐
│         UI Layer (Screens)          │
│  Home, Login, Add Pet, etc.        │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      State Layer (Providers)        │
│  Auth, Pet, Reminder, etc.         │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      Service Layer                   │
│  Database, Notification, Image      │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      Data Layer                     │
│  Hive, Files, SharedPreferences    │
└─────────────────────────────────────┘
```

## Common Tasks

### Adding a New Feature

1. **Create Model** (if needed): Add to `models/` with Hive adapter
2. **Create Provider**: Add state management in `providers/`
3. **Add Database Methods**: Extend `DatabaseService`
4. **Create Screen**: Add UI in `screens/`
5. **Add Navigation**: Update routing/navigation

### Debugging

1. **Check Logs**: App uses `print()` for debugging
2. **Verify State**: Use Provider's `notifyListeners()`
3. **Check Database**: Verify `switchUser()` was called
4. **Test Notifications**: Use `showTestNotification()`

### Understanding Data Flow

1. **User Action**: Screen receives user input
2. **Provider Method**: Screen calls provider method
3. **Service Call**: Provider calls service (DatabaseService, etc.)
4. **Data Update**: Service updates storage
5. **State Update**: Provider updates in-memory state
6. **UI Update**: Provider notifies listeners, UI rebuilds

## File Organization

- **`lib/models/`**: Data models with Hive adapters
- **`lib/providers/`**: State management (ChangeNotifier)
- **`lib/services/`**: Business logic and external integrations
- **`lib/screens/`**: Full-screen UI components
- **`lib/widgets/`**: Reusable UI components
- **`lib/theme/`**: Theme configuration
- **`lib/utils/`**: Utility functions

## Important Notes

### Multi-User Support
- Each user has separate Hive boxes
- Data is isolated per user
- Switching users clears previous user's data from memory

### Offline-First
- All data stored locally
- No network required for core features
- Firebase is optional

### Notification Handling
- Notifications scheduled when reminders created
- Cancelled when reminders deleted/completed
- Rescheduled on app start

## Dependencies

### Core
- `flutter`: UI framework
- `provider`: State management
- `hive`: Local database

### Features
- `flutter_local_notifications`: Notifications
- `image_picker`: Image selection
- `firebase_core`, `firebase_auth`, `cloud_firestore`: Firebase (optional)

See [Technical Documentation - Dependencies](./TECHNICAL_DOCUMENTATION.md#dependencies) for complete list.

## Contributing

When modifying the codebase:

1. **Follow Patterns**: Use existing code patterns
2. **Update Providers**: Always call `notifyListeners()` after state changes
3. **Handle Errors**: Use try-catch for async operations
4. **Test Notifications**: Verify notifications work after changes
5. **Update Documentation**: Update relevant docs if architecture changes

## Support

For questions or issues:
1. Check [Quick Reference](./QUICK_REFERENCE.md) for common patterns
2. Review [Technical Documentation](./TECHNICAL_DOCUMENTATION.md) for details
3. Check code comments for inline documentation

---

*Purfect Care Documentation*
*Last updated: 2024*

