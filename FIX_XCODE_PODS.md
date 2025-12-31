# Fix Red Pods Files in Xcode

The red files in the Pods folder in Xcode indicate that the Pods are incomplete or corrupted. Follow these steps to fix it:

## Step 1: Clean up Pods (run in terminal)

```bash
cd /Users/nexus/Documents/MAD/purfect_care/ios
rm -rf Pods Podfile.lock .symlinks
```

If you get permission errors, you may need to use `sudo` or close Xcode first.

## Step 2: Get Flutter dependencies

```bash
cd /Users/nexus/Documents/MAD/purfect_care
flutter pub get
```

## Step 3: Install CocoaPods

```bash
cd /Users/nexus/Documents/MAD/purfect_care/ios
pod install
```

## Step 4: Open Xcode workspace (not project)

```bash
open ios/Runner.xcworkspace
```

**Important:** Always open `.xcworkspace`, not `.xcodeproj` when using CocoaPods.

## Step 5: Clean build in Xcode

1. In Xcode: `Product` → `Clean Build Folder` (or press `Shift + Cmd + K`)
2. Close and reopen Xcode if the red files persist
3. The red files should disappear once pods are properly installed

## Alternative: If red files persist

1. Close Xcode completely
2. Delete `ios/Pods` folder manually
3. Delete `ios/Podfile.lock`
4. Run `pod install` again
5. Reopen Xcode workspace

