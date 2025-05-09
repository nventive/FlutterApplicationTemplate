# Bugsee Integration Documentation

This document provides a comprehensive guide to integrating and using **Bugsee** in your mobile application. Bugsee is a powerful tool for monitoring and debugging your app by capturing and reporting unhandled exceptions, providing insights into app crashes, user interactions, and more.

## Overview

**Bugsee** helps developers quickly identify and troubleshoot crashes, bugs, and performance issues in mobile applications. By integrating Bugsee, developers can capture detailed logs, screen recordings, and contextual data (such as user attributes) to understand and fix issues faster.

---

## Features

This implementation of Bugsee leverages the following features to provide robust exception tracking and reporting:

### 1. Manual Invocation
   - Developers can trigger Bugsee for testing purposes or to verify the integration. You can also use different tokens for testing in different environments.
   - Documentation: [Bugsee SDK Docs](https://docs.bugsee.com/)

### 2. Custom Data Reporting
   - Add additional user-specific data (like email addresses) or custom attributes to exception reports for better context.
     - **Email:** Helps identify the specific user experiencing issues.
     - **Attributes:** Attach custom key-value pairs for further context.
     - **Traces:** Track specific values or conditions before an exception occurs.
     - **Events:** Log events leading to exceptions and attach structured JSON data for detailed insights.
   - Documentation: [Bugsee Custom Data](https://docs.bugsee.com/)

### 3. Exception Logging
   - Bugsee automatically captures unhandled exceptions in your Dart and Flutter code.
     - **Dart Exceptions:** Captures logic and data errors.
     - **Flutter Exceptions:** Captures rendering and layout errors.
   - You can also manually log exceptions with additional context, such as traces and events.
   - Documentation: [Bugsee Exception Logging](https://bugsee.com/)

### 4. Video Capture
   - Bugsee automatically captures screen recordings of user interactions that lead to exceptions. This helps developers visually understand what the user was doing when the issue occurred.
   - You can disable video capture by setting the `videoEnabled` flag.
   - Documentation: [Bugsee Flutter Installation](https://docs.bugsee.com/sdk/flutter/installation/)

### 5. Log Reporting and Filtering
   - Bugsee integrates with your app’s logging system. By default, logs are filtered to remove sensitive information to protect user privacy.
   - You can customize log collection behavior using configuration options.
   - Documentation: [Bugsee Log Reporting](https://docs.bugsee.com/sdk/flutter/installation/)

### 6. Data Obfuscation
   - Sensitive user data (like passwords or personal information) in captured videos is automatically obscured by default to prevent leaks.
   - Documentation: [Bugsee Data Obscuration](https://docs.bugsee.com/sdk/flutter/installation/)

---

## Default Configurations

Bugsee’s behavior can be controlled via environment settings, particularly for data obscuration, log collection, and file attachment. The default configurations are defined in the `.env.staging` file as follows:

```env
BUGSEE_IS_DATA_OBSCURE=true        # Enables data obscuration for captured videos
BUGSEE_DISABLE_LOG_COLLECTION=true  # Disables log collection by default
BUGSEE_FILTER_LOG_COLLECTION=false # Allows all logs unless manually filtered
BUGSEE_ATTACH_LOG_FILE=true        # Attaches log files with Bugsee reports
```

Ensure that these values are properly set for different environments (e.g., staging, production).

---

## Implementation Details

The Bugsee integration consists of several key components for handling configuration, exception tracking, and reporting.

### 1. [Bugsee Manager](../src/app/lib/business/bugsee/bugsee_manager.dart)
   - Responsible for initializing Bugsee, capturing logs, and configuring Bugsee features (like video capture, data obfuscation, and log filtering).
   
### 2. [Bugsee Config State](../src/app/lib/business/bugsee/bugsee_config_state.dart)
   - Maintains the current state of Bugsee’s features (enabled/disabled) within the app.

### 3. [Bugsee Repository](../src/app/lib/access/bugsee/bugsee_repository.dart)
   - Handles the saving and retrieving of Bugsee configurations from shared preferences.

### 4. [Bugsee Saved Configuration](../src/app/lib/access/bugsee/bugsee_configuration_data.dart)
   - Stores and manages the saved configurations used to initialize Bugsee upon app launch.

---

## Exception Handling and Reporting

### Intercepting Exceptions
By default, Bugsee intercepts all unhandled Dart and Flutter exceptions globally:

1. Dart Exceptions:
   - These are data or logic errors that happen within your Dart code.
   
2. Flutter Exceptions:
   - These occur during layout or rendering issues.

Both types of exceptions are captured and reported to Bugsee’s dashboard.

The exceptions are intercepted using `runZonedGuarded` and `FlutterError.onError`:

```dart
// main.dart

runZonedGuarded(
    () async {
      FlutterError.onError =
          GetIt.I.get<BugseeManager>().inteceptRenderExceptions;
      await initializeComponents();
      await registerBugseeManager();
      runApp(const App());
    },
    GetIt.I.get<BugseeManager>().inteceptExceptions,
  );

// bugsee_manager.dart

@override
  Future<void> inteceptExceptions(
    Object error,
    StackTrace stackTrace,
  ) async {
    String? message = switch (error.runtimeType) {
      const (PersistenceException) => (error as PersistenceException).message,
      _ => null,
    };
    await logException(
      exception: Exception(error),
      stackTrace: stackTrace,
      traces: {
        'message': message,
      },
    );
  }

  @override
  Future<void> inteceptRenderExceptions(FlutterErrorDetails error) async {
    await logException(
      exception: Exception(error.exception),
      stackTrace: error.stack,
    );
  }
```

### Manually Reporting Issues

You can manually trigger Bugsee to capture logs and display a report dialog using the `showCaptureLogReport` method:

```dart
final bugseeManager = Get.I.get<BugseeManager>();
bugseeManager.showCaptureLogReport();
```

This is useful for debugging specific scenarios or reporting custom issues.

### Manually Logging Exceptions

To manually log an exception (with or without additional traces), use the `logException` method:

```dart
final bugseeManager = Get.I.get<BugseeManager>();
bugseeManager.logException(exception: Exception("Custom error"));
```

You can add additional context **traces**:

```dart
bugseeManager.logException(
  exception: Exception("Custom error"),
  traces: ["Trace 1", "Trace 2"],  // Add relevant traces
);
```

### Adding User Attributes

To provide more context about the user experiencing the issue, you can add custom attributes such as an email address:

- Add Email Attribute:

```dart
final bugseeManager = Get.I.get<BugseeManager>();
bugseeManager.addEmailAttribute("johndoe@nventive.com");
```

- Clear Email Attribute:

```dart
bugseeManager.clearEmailAttribute();
```

- Add Custom Attributes:

You can also add custom key-value pairs as additional attributes to enrich the exception reports:

```dart
bugseeManager.addAttributes({
  "userType": "premium",
  "accountStatus": "active"
});
```

## Additional Resources

- [Bugsee SDK Documentation](https://docs.bugsee.com/)
- [Bugsee Flutter Installation Guide](https://docs.bugsee.com/sdk/flutter/installation/)
- [bugsee_flutter package](https://pub.dev/packages/bugsee_flutter)
- [Handling Flutter errors](https://docs.flutter.dev/testing/errors)
- [runZoneGuarded Error handling](https://api.flutter.dev/flutter/dart-async/runZonedGuarded.html)

---
