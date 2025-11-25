# Data Storage Explanation 📦

## Overview

Your app uses a **Hybrid Storage System** that stores data in **TWO places**:

1. **Local Storage (Hive)** - On the device
2. **Firebase (Cloud)** - In Google's cloud

---

## 1. Local Storage (Hive Database) 💾

### What is Hive?
- **Hive** is a fast, lightweight NoSQL database for Flutter
- Data is stored in **binary files** on the device
- Works **offline** - no internet required
- Very fast read/write operations

### Where is the data stored?

#### **Android:**
```
/data/data/com.example.purfect_care/app_flutter/
```
Files:
- `pets_{userId}.hive` - User's pets data
- `reminders_{userId}.hive` - User's reminders data
- `health_records_{userId}.hive` - User's health records data

#### **iOS:**
```
~/Library/Application Support/PurfectCare/
```
Files:
- `pets_{userId}.hive`
- `reminders_{userId}.hive`
- `health_records_{userId}.hive`

#### **How to Access:**
1. **Android (with root or emulator):**
   - Use Android Studio's Device File Explorer
   - Navigate to: `/data/data/com.example.purfect_care/app_flutter/`
   - Copy `.hive` files to your computer

2. **iOS (Simulator):**
   - Open Finder
   - Go to: `~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Library/Application Support/PurfectCare/`

3. **View Hive Data:**
   - Install Hive Studio (VS Code extension) or use Hive Inspector
   - Or use a Flutter package like `hive_flutter` with debugging tools

### Important Notes:
- ✅ Data persists even after app closes
- ✅ Each user has their own separate files (user-specific)
- ✅ Data is cleared when user signs out
- ✅ Fast and works offline

---

## 2. Firebase (Cloud Storage) ☁️

### What is Firebase?
- **Firebase Firestore** - Google's cloud database
- Data is stored in Google's servers
- Requires internet connection
- Syncs across devices

### Where to View Firebase Data:

1. **Go to Firebase Console:**
   - Visit: https://console.firebase.google.com/
   - Select your project: **purfect-care**

2. **Navigate to Firestore Database:**
   - Click **"Firestore Database"** in the left sidebar
   - You'll see collections organized by user:
     ```
     users/
       └── {userId}/
           ├── pets/
           │   └── {petId}/
           │       ├── name: "Fluffy"
           │       ├── species: "Cat"
           │       └── ...
           ├── reminders/
           │   └── {reminderId}/
           │       ├── title: "Feed cat"
           │       └── ...
           └── healthRecords/
               └── {recordId}/
                   ├── title: "Vaccination"
                   └── ...
     ```

3. **View Data:**
   - Click on any collection to see documents
   - Each document shows all fields and values
   - You can edit/delete directly in the console

### Important Notes:
- ✅ Data syncs across all user's devices
- ✅ Accessible from anywhere with internet
- ✅ Automatic backup and recovery
- ⚠️ Requires internet connection

---

## 3. How the Hybrid System Works 🔄

### When You Add Data:
```
1. User adds a pet
   ↓
2. Saves to LOCAL (Hive) first ⚡ (Fast, works offline)
   ↓
3. Then saves to FIREBASE (Cloud) ☁️ (If connected)
   ↓
4. If Firebase fails → App still works with local data ✅
```

### When You Read Data:
```
1. User opens app
   ↓
2. Reads from LOCAL (Hive) ⚡ (Fast, instant)
   ↓
3. Syncs from FIREBASE in background (Updates if needed)
```

### When User Logs In:
```
1. User signs in
   ↓
2. Opens user-specific Hive boxes (pets_{userId}.hive)
   ↓
3. Syncs data from Firebase to local storage
   ↓
4. User sees their data
```

### When User Logs Out:
```
1. User signs out
   ↓
2. Clears local Hive boxes
   ↓
3. Closes user-specific files
   ↓
4. Next user gets fresh data
```

---

## 4. Data Flow Diagram

```
┌─────────────────────────────────────────┐
│         User Action (Add Pet)          │
└─────────────────┬───────────────────────┘
                  │
                  ▼
        ┌──────────────────┐
        │  HybridDatabase  │
        │     Service       │
        └────────┬─────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
        ▼                   ▼
┌──────────────┐    ┌──────────────┐
│   Hive DB    │    │   Firebase   │
│   (Local)    │    │   (Cloud)    │
│              │    │              │
│ ✅ Fast      │    │ ✅ Sync      │
│ ✅ Offline   │    │ ✅ Backup    │
│ ✅ Private   │    │ ✅ Multi-dev  │
└──────────────┘    └──────────────┘
```

---

## 5. Which Database is Primary?

**Answer: LOCAL (Hive) is the primary database**

- App **always reads from local** (fast, works offline)
- App **always writes to local first** (instant feedback)
- Firebase is used for **backup and sync** across devices

### Priority:
1. **Local (Hive)** - Primary storage, always used
2. **Firebase** - Secondary storage, for sync and backup

---

## 6. How to Check Your Data

### Check Local Data:
```dart
// In your Flutter app, you can print data:
final pets = DatabaseService.getAllPets();
print('Local pets: ${pets.length}');
```

### Check Firebase Data:
1. Go to Firebase Console
2. Navigate to Firestore Database
3. Browse collections: `users/{userId}/pets`

### Check Both:
- Local: Fast, offline, device-specific
- Firebase: Cloud, syncs, accessible from console

---

## 7. Troubleshooting

### "I don't see my data in Firebase"
- Check if you're logged in
- Check Firebase Console → Firestore Database
- Look for `users/{yourUserId}/pets` collection
- Check internet connection

### "I see old data after logging in"
- Data syncs from Firebase on login
- If you see old data, it's from Firebase
- Local data is cleared on logout

### "Where are the Hive files?"
- Android: `/data/data/com.example.purfect_care/app_flutter/`
- iOS: `~/Library/Application Support/PurfectCare/`
- Files are named: `pets_{userId}.hive`

---

## Summary

✅ **Local (Hive)**: Fast, offline, device storage  
✅ **Firebase**: Cloud backup, sync across devices  
✅ **Hybrid**: Best of both worlds - fast local + cloud backup

Your data is stored in **BOTH places** for reliability and performance! 🎉

