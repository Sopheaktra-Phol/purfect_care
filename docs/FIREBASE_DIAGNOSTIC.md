# Firebase Diagnostic Guide 🔍

## Issue Found and Fixed ✅

**Problem:** `AuthProvider` was trying to access `FirebaseAuth.instance` before Firebase was initialized, causing the app to crash.

**Fix Applied:** Added Firebase initialization checks before accessing Firebase Auth.

---

## How to Check if Firebase is Working

### 1. **Check Console Logs**

When you run the app, look for these messages in the console:

**✅ Firebase Working:**
```
🔥 Initializing Firebase...
🔄 Initializing Firebase (attempt 1/3)...
✅ Firebase initialized successfully
   Project: purfect-care
   App ID: 1:126123056507:ios:2383645e9e79122c9cb1de
```

**❌ Firebase Not Working:**
```
🔥 Initializing Firebase...
❌ Firebase initialization attempt 1 failed: [error message]
⚠️ Firebase initialization failed - app will continue with local storage only
```

### 2. **Common Firebase Issues**

#### Issue 1: Platform Channel Error (iOS)
**Symptoms:**
- Error: "Platform channel error" or "PlatformException"
- Firebase fails to initialize on iOS

**Fix:**
```bash
# Stop the app completely
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
flutter run
```

#### Issue 2: Authentication Not Enabled
**Symptoms:**
- Error: "operation-not-allowed" or "internal-error"
- Can't sign in or create account

**Fix:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **purfect-care**
3. Go to **Authentication → Sign-in method**
4. Enable:
   - ✅ **Email/Password** (REQUIRED)
   - ✅ **Google Sign-In** (if using Google login)
   - ⚠️ **Anonymous** (optional, for guest mode)
5. Click **Save** for each
6. Restart the app

#### Issue 3: Firestore Not Created
**Symptoms:**
- Data doesn't save to cloud
- Error: "PERMISSION_DENIED" or "NOT_FOUND"

**Fix:**
1. Go to Firebase Console → **Firestore Database**
2. Click **"Create database"** (if not exists)
3. Choose **"Start in test mode"** (for development)
4. Select a location
5. Click **"Enable"**

#### Issue 4: Missing Configuration Files
**Symptoms:**
- Error: "MissingPluginException" or "FirebaseOptions not found"
- App crashes on startup

**Fix:**
1. Check these files exist:
   - ✅ `android/app/google-services.json`
   - ✅ `ios/Runner/GoogleService-Info.plist`
   - ✅ `lib/firebase_options.dart`

2. If missing, download from Firebase Console:
   - Go to Project Settings → Your apps
   - Download `google-services.json` (Android)
   - Download `GoogleService-Info.plist` (iOS)

#### Issue 5: Wrong Bundle ID / Package Name
**Symptoms:**
- Firebase connects but authentication fails
- Data doesn't sync

**Fix:**
1. Check your app's bundle ID matches Firebase:
   - iOS: `com.nexuscasy.purfectcare`
   - Android: `com.example.purfect_care` (or your actual package name)

2. In Firebase Console → Project Settings:
   - Verify the bundle ID/package name matches
   - If different, either:
     - Update Firebase app registration, OR
     - Update your app's bundle ID/package name

---

## Step-by-Step Verification

### Step 1: Check Firebase Initialization
Run the app and check console for:
```
✅ Firebase initialized successfully
```

### Step 2: Test Authentication
1. Try to create an account
2. Check console for errors
3. If error: "operation-not-allowed" → Enable Email/Password in Firebase Console

### Step 3: Test Data Sync
1. Create a pet
2. Check Firebase Console → Firestore Database
3. You should see data in: `users/{userId}/pets/{petId}`

### Step 4: Check Firestore Rules
1. Go to Firebase Console → Firestore Database → Rules
2. Make sure rules allow authenticated users to read/write their data
3. Rules should look like:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /pets/{petId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

## Quick Test Commands

### Test Firebase Connection
```bash
# Run app and watch for Firebase logs
flutter run

# Look for these in console:
# ✅ Firebase initialized successfully
# ✅ Firebase connected successfully
```

### Rebuild iOS (if platform channel error)
```bash
flutter clean
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
flutter pub get
flutter run
```

---

## What to Check in Firebase Console

### ✅ Authentication
- [ ] Email/Password enabled
- [ ] Google Sign-In enabled (if using)
- [ ] Anonymous enabled (if using guest mode)
- [ ] Users can be created (check Users tab)

### ✅ Firestore Database
- [ ] Database created
- [ ] Rules configured
- [ ] Data appears when you create pets/reminders

### ✅ Storage
- [ ] Storage bucket created
- [ ] Rules configured
- [ ] Photos upload successfully

### ✅ Project Settings
- [ ] iOS app registered with correct bundle ID
- [ ] Android app registered with correct package name
- [ ] Configuration files downloaded

---

## Still Not Working?

1. **Check the exact error message** in console
2. **Verify Firebase Console setup** (all checkboxes above)
3. **Try rebuilding the app** (flutter clean + rebuild)
4. **Check network connection** (Firebase needs internet)
5. **Verify you're using the correct Firebase project** (purfect-care)

---

## Expected Behavior

**When Firebase Works:**
- ✅ App starts without crashes
- ✅ You can create account / sign in
- ✅ Data saves to cloud (visible in Firestore)
- ✅ Data syncs across devices
- ✅ Photos upload to Firebase Storage

**When Firebase Doesn't Work:**
- ⚠️ App still works (uses local storage)
- ⚠️ Data only saves locally
- ⚠️ No cloud sync
- ⚠️ Can't create account / sign in

---

## Need More Help?

Check these files for more details:
- `docs/FIREBASE_COMPLETE_SETUP.md` - Complete setup guide
- `docs/FIREBASE_AUTH_SETUP.md` - Authentication setup
- `lib/services/firebase_init_service.dart` - Initialization code

