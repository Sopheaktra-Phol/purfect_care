# Firebase Complete Setup Guide 🔥

Since your app now uses **Firebase-only storage** (no local storage), you need to configure Firebase properly. Follow this checklist:

---

## ✅ Required Firebase Setup Checklist

### 1. **Firebase Project Setup** (If not done already)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing project: **purfect-care**
3. Add your apps:
   - **Android**: Register your Android app (package: `com.example.purfect_care`)
   - **iOS**: Register your iOS app (bundle ID: `com.nexuscasy.purfectcare`)
4. Download configuration files:
   - `google-services.json` → Place in `android/app/`
   - `GoogleService-Info.plist` → Place in `ios/Runner/`

---

### 2. **Enable Authentication Methods** 🔐

**Go to:** Firebase Console → Authentication → Sign-in method

Enable these sign-in providers:

#### ✅ **Email/Password** (REQUIRED)
1. Click on **"Email/Password"**
2. Toggle **"Enable"** to ON
3. Optionally enable "Email link (passwordless sign-in)" if you want
4. Click **"Save"**

#### ✅ **Google Sign-In** (REQUIRED - You mentioned you enabled this)
1. Click on **"Google"**
2. Toggle **"Enable"** to ON
3. Enter your **Support email** (your email address)
4. Click **"Save"**
5. **For iOS**: You may need to configure OAuth client IDs (Firebase will guide you)

#### ⚠️ **Anonymous** (OPTIONAL - for guest mode)
1. Click on **"Anonymous"**
2. Toggle **"Enable"** to ON
3. Click **"Save"**

---

### 3. **Set Up Firestore Database** 📊

**Go to:** Firebase Console → Firestore Database

#### Create Database (if not exists):
1. Click **"Create database"**
2. Choose **"Start in test mode"** (for development) OR **"Start in production mode"** (for production)
3. Select a **location** (choose closest to your users)
4. Click **"Enable"**

#### Set Security Rules:
**Go to:** Firestore Database → Rules tab

**Replace with these rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      // Allow read/write only if authenticated and accessing own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Sub-collections under user
      match /pets/{petId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /reminders/{reminderId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /healthRecords/{recordId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

**Click "Publish"** to save the rules.

---

### 4. **Set Up Firebase Storage** 🗄️

**Go to:** Firebase Console → Storage

#### Create Storage Bucket (if not exists):
1. Click **"Get started"**
2. Choose **"Start in test mode"** (for development) OR **"Start in production mode"** (for production)
3. Select a **location** (should match Firestore location)
4. Click **"Done"**

#### Set Storage Security Rules:
**Go to:** Storage → Rules tab

**Replace with these rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Pet images - users can only access their own images
    match /pet_images/{userId}/{petId}/{imageId} {
      // Anyone authenticated can read (for sharing)
      allow read: if request.auth != null;
      
      // Only the owner can write/delete
      allow write: if request.auth != null 
                   && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024  // Max 5MB
                   && request.resource.contentType.matches('image/.*');
      
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Click "Publish"** to save the rules.

---

### 5. **Verify Configuration Files** 📁

Make sure these files exist and are correct:

#### Android:
- ✅ `android/app/google-services.json` - Should exist
- ✅ Check `android/app/build.gradle` has Google Services plugin

#### iOS:
- ✅ `ios/Runner/GoogleService-Info.plist` - Should exist
- ✅ Check `ios/Podfile` has Firebase pods

---

### 6. **Test Your Setup** 🧪

#### Test Authentication:
1. Run your app: `flutter run`
2. Try signing up with email/password
3. Try signing in with Google
4. Check Firebase Console → Authentication → Users
   - You should see your test users

#### Test Firestore:
1. Add a pet in your app
2. Go to Firebase Console → Firestore Database
3. You should see: `users/{userId}/pets/{petId}`
4. Verify the data structure matches

#### Test Storage:
1. Add a pet with an image
2. Go to Firebase Console → Storage
3. You should see: `pet_images/{userId}/{petId}/{imageName}`
4. Verify the image uploaded correctly

---

## 🔒 Security Rules Summary

### Firestore Rules:
- ✅ Users can only read/write their own data
- ✅ All operations require authentication
- ✅ Data is isolated per user ID

### Storage Rules:
- ✅ Images max size: 5MB
- ✅ Only image files allowed
- ✅ Users can only upload/delete their own images
- ✅ Anyone authenticated can view images (for sharing)

---

## ⚠️ Important Notes

### For Development:
- **Test Mode**: Allows all reads/writes (convenient for testing)
- **⚠️ Not secure for production!**

### For Production:
- **Production Mode**: Uses security rules (secure)
- **✅ Required before releasing to users**

### Switching to Production:
1. Update Firestore rules (use rules above)
2. Update Storage rules (use rules above)
3. Test thoroughly before release

---

## 🚨 Common Issues & Solutions

### Issue: "operation-not-allowed" error
**Solution:** Enable the sign-in method in Firebase Console → Authentication → Sign-in method

### Issue: "Permission denied" in Firestore
**Solution:** Check your Firestore security rules match the rules above

### Issue: "Storage permission denied"
**Solution:** Check your Storage security rules match the rules above

### Issue: Data not appearing in Firebase
**Solution:** 
1. Check you're logged in
2. Check Firestore rules allow your user
3. Check internet connection
4. Check Firebase Console → Firestore Database (not Realtime Database)

### Issue: Google Sign-In not working
**Solution:**
1. Verify Google Sign-In is enabled in Firebase Console
2. For iOS: Configure OAuth client IDs in Firebase Console
3. Check `GoogleService-Info.plist` is correct

---

## ✅ Verification Checklist

Before using your app, verify:

- [ ] Firebase project created
- [ ] Android app registered (`google-services.json` added)
- [ ] iOS app registered (`GoogleService-Info.plist` added)
- [ ] Email/Password authentication enabled
- [ ] Google Sign-In enabled
- [ ] Anonymous authentication enabled (if using guest mode)
- [ ] Firestore Database created
- [ ] Firestore security rules set
- [ ] Storage bucket created
- [ ] Storage security rules set
- [ ] Tested sign up with email
- [ ] Tested sign in with Google
- [ ] Tested adding a pet (data appears in Firestore)
- [ ] Tested uploading pet image (image appears in Storage)

---

## 📍 Where to Find Your Data

### View Users:
**Firebase Console → Authentication → Users**

### View Data:
**Firebase Console → Firestore Database → users/{userId}/pets**

### View Images:
**Firebase Console → Storage → pet_images/{userId}/{petId}/**

---

## 🎯 Quick Setup (5 Minutes)

1. **Enable Auth Methods:**
   - Authentication → Sign-in method → Enable Email/Password
   - Authentication → Sign-in method → Enable Google

2. **Create Firestore:**
   - Firestore Database → Create database → Test mode → Enable

3. **Create Storage:**
   - Storage → Get started → Test mode → Done

4. **Set Rules:**
   - Copy-paste the rules above for Firestore and Storage

5. **Test:**
   - Run app → Sign up → Add pet → Check Firebase Console

---

## 🆘 Need Help?

If something doesn't work:
1. Check the error message in your app console
2. Check Firebase Console for any error messages
3. Verify all configuration files are in place
4. Make sure you're using the correct Firebase project

---

## Status: Ready to Use! ✅

Once you complete the checklist above, your app will:
- ✅ Store all data in Firebase (cloud)
- ✅ Sync across all devices
- ✅ Support email/password and Google sign-in
- ✅ Securely store user data
- ✅ Handle pet images in Firebase Storage

**Your data is now fully cloud-based and accessible from any device!** 🎉

