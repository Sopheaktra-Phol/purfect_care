# Remove Unsupported Platforms

Since you only need iOS and Android support, you can manually remove the platform directories.

## Manual Removal (Run in Terminal)

Since some files have permission restrictions, you may need to delete them manually:

```bash
cd /Users/nexus/Documents/MAD/purfect_care

# Close Xcode if it's open (macos directory might be locked)
# Then run:
rm -rf macos web windows linux
```

If you get permission errors, you can try:
```bash
sudo rm -rf macos web windows linux
```

## What This Does

- Removes macOS platform support
- Removes Web platform support  
- Removes Windows platform support
- Removes Linux platform support
- Keeps only iOS and Android

## After Removal

The `.gitignore` file has been updated to ignore these directories if they get regenerated. Your app will now only build for iOS and Android.

## Note

Flutter may regenerate these directories when you run `flutter create` or similar commands. If that happens, you can delete them again. The `.gitignore` will prevent them from being committed to git.

