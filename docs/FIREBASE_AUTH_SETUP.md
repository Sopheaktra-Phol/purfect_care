# Firebase Anonymous Authentication Setup

## Error: `[firebase_auth/internal-error]` or `operation-not-allowed`

This error means **Anonymous Authentication is not enabled** in your Firebase project.

## How to Fix (Step by Step)

### 1. Go to Firebase Console
- Visit: https://console.firebase.google.com/
- Select your project: **purfect-care**

### 2. Enable Anonymous Authentication
1. Click on **"Authentication"** in the left sidebar
2. Click on the **"Sign-in method"** tab
3. Find **"Anonymous"** in the list of providers
4. Click on **"Anonymous"**
5. Toggle **"Enable"** to ON
6. Click **"Save"**

### 3. Verify It's Enabled
- You should see a green checkmark next to "Anonymous"
- Status should show "Enabled"

### 4. Restart Your App
- Stop the app
- Run `flutter run` again
- The error should be gone

## Alternative: Use Email/Password Authentication

If you prefer email/password instead of anonymous:

1. **Enable Email/Password in Firebase Console:**
   - Go to Authentication → Sign-in method
   - Click "Email/Password"
   - Enable it
   - Save

2. **Update the code** to use email/password instead of anonymous (optional)

## Current Behavior

Even if Firebase authentication fails, **your app will still work perfectly**:
- ✅ All data saves to local Hive database
- ✅ App works offline
- ✅ All features function normally
- ⚠️ Data just won't sync to cloud until authentication is enabled

## Verify It's Working

After enabling anonymous auth, you should see in the console:
```
✅ Firebase connected successfully
```

Instead of:
```
⚠️ Firebase authentication failed. App will work in local-only mode.
```

## Need Help?

If you still get errors after enabling anonymous auth:
1. Check Firebase Console → Authentication → Users (should show anonymous users)
2. Verify your `google-services.json` and `GoogleService-Info.plist` are up to date
3. Make sure you're using the correct Firebase project

