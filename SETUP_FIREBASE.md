# Firebase Setup Guide for App Check

This guide walks you through setting up Firebase with App Check for this Flutter application.

## What is App Check?

Firebase App Check protects your Firebase resources from abuse by ensuring requests come from your authentic app. Once configured, App Check tokens are **automatically attached** to all Firebase service requests (Firestore, Functions, Storage, etc.) without any additional code needed.

You don't need to manually handle or send tokens - the Firebase SDK does this automatically.

## Prerequisites

- Google account
- Flutter SDK installed
- Android Studio (recommended for Android development)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter a project name (e.g., "app-check-poc")
4. Enable/disable Google Analytics as desired
5. Click "Create project"

## Step 2: Register Android App

1. In Firebase Console, click "Add app" and select Android
2. Enter your app details:
   - **Package name**: `com.example.app_check_poc`
   - **App nickname**: "App Check POC"
   - **SHA-256 certificate**: See instructions below
3. Click "Register app"


## Step 3: Get SHA-256 Certificate Fingerprint

The SHA-256 fingerprint uniquely identifies your app's signing certificate. Firebase uses this for security verification.

### Quick Method (Recommended)

**Using Gradle:**
```powershell
# Navigate to android folder and run:
cd android
.\gradlew signingReport
```

Look for the SHA-256 under the "debug" variant. The fingerprint looks like:
```
SHA256: A1:B2:C3:D4:E5:F6:07:08:09:0A:1B:2C:3D:4E:5F:60:71:82:93:A4:B5:C6:D7:E8:F9:0A:1B:2C:3D:4E:5F:60
```

**If gradlew doesn't exist:**
```powershell
flutter build apk --debug
cd android
.\gradlew signingReport
```

### Alternative: Using Keytool

```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### Important Notes

- **Debug vs Release**: Different fingerprints for debug and release builds
- **Multiple fingerprints**: Add all needed fingerprints in Firebase Console → Project Settings → Your App → "Add fingerprint"
- Each developer may have different debug certificates

## Step 4: Download Configuration File

1. Download `google-services.json` from Firebase Console
2. Place it at: `android/app/google-services.json`
3. Verify the file is in the correct location

## Step 5: Enable App Check

1. In Firebase Console, navigate to "App Check"
2. Click "Get started"
3. Select your Android app
4. Choose "Play Integrity" as the provider
5. Click "Enable"

## Step 6: Configure Firebase in Flutter

**Using FlutterFire CLI (Recommended):**
```bash
# Install if needed
dart pub global activate flutterfire_cli

# Configure
flutterfire configure
```

Follow the prompts to select your project and platforms.

## Step 7: Configure Debug Provider (Development)

For development and testing, use the debug provider instead of Play Integrity:

1. **Update your code to use debug provider:**
   ```dart
   await FirebaseAppCheck.instance.activate(
     androidProvider: AndroidProvider.debug,
   );
   ```

2. **Get your debug token:**
   - Run the app: `flutter run`
   - The debug token will be printed in the console/logcat
   - Look for a log message containing the token (format: `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`)
   - Or check logcat: `adb logcat -d | Select-String "debug token"`

3. **Register the debug token in Firebase Console:**
   - Go to Firebase Console → App Check → Your Android App
   - Click "Manage debug tokens"
   - Click "Add debug token"
   - Give it a name (e.g., "dev-laptop" or "debug")
   - Paste the token
   - Click "Save"

4. **Restart your app**
   - Stop the app completely
   - Run again: `flutter run`
   - Tap the button to request an App Check token
   - Should now work without 403 errors!

**For Production:** Change back to `AndroidProvider.playIntegrity` and follow the Play Integrity setup steps.

## Step 8: Test the Setup

1. Run the app: `flutter run`
2. Tap the button to request an App Check token
3. A successful token indicates App Check is working

## How App Check Works in Your App

Once App Check is configured, **you don't need to do anything with the token manually**. The Firebase SDK automatically:

1. Requests and refreshes App Check tokens
2. Attaches tokens to all Firebase service requests (Firestore, Functions, Storage, etc.)
3. Handles token validation and errors

**Example - Using Firestore with App Check (automatic):**
```dart
// App Check token is automatically sent with this request
FirebaseFirestore.instance.collection('users').get();
```

**Example - Calling Cloud Functions with App Check (automatic):**
```dart
// App Check token is automatically attached
final callable = FirebaseFunctions.instance.httpsCallable('myFunction');
await callable.call();
```

The token display in this demo app is just for verification purposes. In production apps, you typically never need to manually retrieve or display App Check tokens.

## Troubleshooting

**"gradlew not recognized"**
- Use `.\gradlew` (with dot and backslash) on Windows
- Run `flutter build apk --debug` first to generate Gradle wrapper

**"App not authenticating"**
- Verify SHA-256 fingerprint matches your current build type
- Check package name matches exactly: `com.example.app_check_poc`

**"403 App attestation failed"**
- You're likely using debug provider without registering a debug token
- Follow Step 7 above to register your debug token in Firebase Console
- Or temporarily disable App Check enforcement in Firebase Console while testing

**"No token received"**
- Ensure App Check is enabled in Firebase Console
- Verify `google-services.json` is in `android/app/` folder
- Check that SHA-256 fingerprint is added to Firebase (for Play Integrity)
- For debug provider, ensure debug token is registered

**"keytool not recognized"**
- Install Java JDK or use Android Studio's Gradle method instead

For release builds, add your release signing certificate's SHA-256 fingerprint to Firebase Console.
