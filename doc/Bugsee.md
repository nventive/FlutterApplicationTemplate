# Bugsee

This project include [Bugsee](https://www.bugsee.com/) reporting and Logging, for both Android and iOS apps.
Bugsee lets you monitor and get instant log of unhandled exceptions with traces, events, stacktrace and videos/screenshots of the reported exception. More features are provided by Bugsee like data obscuration and log filter.

For this implementation we've used [bugsee_flutter](https://pub.dev/packages/bugsee_flutter) package.

- By default only release apps will have Bugsee reporting enabled, to enable Bugsee in debug mode add your token in `launch.json` add remove the check on debug mode in `BugseeManager` class.
- **Token**
    - Generate your token in order to test Bugsee logging and reporting 
        - Head to [Bugsee dashboard](https://www.bugsee.com/)
        - Create a new account
        - Create a new Android/iOS (choose Flutter framework)
        - Copy-paste the generated token into `launch.json`


## 1) Features

In this project we've implemented the following features of Bugsee:
- [Manual invocation](https://docs.bugsee.com/sdk/flutter/manual/) helpfull for developers to test their Bugsee integration and setup with new tokens.
- [Custom data](https://docs.bugsee.com/sdk/flutter/custom/) custom data could be attached to the logged exceptions (emails or other type of data)
    - [Email](https://docs.bugsee.com/sdk/flutter/custom/#:~:text=Adding%20custom%20data-,User%20email,-When%20you%20already) this will identify the user whom experienced the exception/bug this will update the exception dashboard item from anonymous to the user's mail this data will be reported with every logged exception unless the app is deleted or removed manually.
    - [Attributes](https://docs.bugsee.com/sdk/flutter/custom/#:~:text=User/Session%20attributes) attributes related to the user info, will be reported with every logged exception unless the app is deleted or removed manually.
    - [Traces](https://docs.bugsee.com/sdk/flutter/custom/#:~:text=them%0ABugsee.clearAllAttributes()%3B-,Custom%20traces,-Traces%20may%20be) helpfull when developer want to track the change of specific value before the logging of the exception.
    - [Events](https://docs.bugsee.com/sdk/flutter/custom/#:~:text=Custom%20events-,Events,-are%20identified%20by) highlight on which event the exception is logged, accept also json data attached to it.
- [Exception Logging](https://docs.bugsee.com/sdk/flutter/logs/) the app automatically log every unhandled exception: Dart SDK exception are related to data or logic errors and Flutter  SDK errors that are related to layout and rendering issues. The implementation also offer an API to manually log an exception with traces and events.
- [Video Capturing](https://docs.bugsee.com/sdk/flutter/privacy/video/) video capturing is by default enabled in this project, but it can be turned off using the `videoEnabled` flag in the launchOptions object for Android and iOS.
- [Log reporting](https://docs.bugsee.com/sdk/flutter/privacy/logs/) all logs are filtered by default using the `_filterBugseeLogs` method, this can be turned off from the app or by removing the call to `setLogFilter` Bugsee method.
- [Obscure Data](https://docs.bugsee.com/sdk/flutter/privacy/video/#:~:text=Protecting%20flutter%20views): data obscuration is by default enabled in the project in order to protect user-related data from being leaked through captured videos.

**Default configurations:**
Data obscuration, log collection, log filter and attaching log file features are initialized from the `.env.staging` file.
```
BUGSEE_IS_DATA_OBSCURE=true
BUGSEE_DISABLE_LOG_COLLECTION=true
BUGSEE_FILTER_LOG_COLLECTION=false
BUGSEE_ATTACH_LOG_FILE=true
```

## 2) Implementation
- [Bugsee Manager](../src/app/lib/business/bugsee/bugsee_manager.dart): a service class that handle the Bugsee intialization, capturing logs, customize Bugsee fields and features (Video capture, data obscure, logs filter...) .
- [Bugsee Config State](../src/app/lib/business/bugsee/bugsee_config_state.dart): a state class holds all the actual Bugsee features status (whether enabled or not).
- [Bugsee Repository](../src/app/lib/access/bugsee/bugsee_repository.dart): save and retrieve Bugsee configuration from the shared preference storage.
- [Bugsee saved configuration](../src/app/lib/access/bugsee/bugsee_configuration_data.dart): holds the Bugsee saved configuration in shared preference, used in [Bugsee Manager](../src/app/lib/business/bugsee/bugsee_manager.dart) to initialize [Bugsee Config State](../src/app/lib/business/bugsee/bugsee_config_state.dart).

### Intecepting exceptions
Bugsee implementation in this project, by default intecepts all the unhandled Dart and Flutter exception.

`main.dart`
```dart
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
```
the `inteceptExceptions` and `inteceptRenderExceptions` recerespectively report Dart and Flutter exceptions to the Bugsee Dashboard.

`inteceptExceptions`
```dart
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
```

`inteceptRenderExceptions`
```dart
@override
  Future<void> inteceptRenderExceptions(FlutterErrorDetails error) async {
    await logException(
      exception: Exception(error.exception),
      stackTrace: error.stack,
    );
  }
```

### Manually invoke report dialog

To manually display the report dialog, you call the `showCaptureLogReport` method from the `BugseeManager` class.

```dart
final bugseeManager = Get.I.get<BugseeManager>();
bugseeManger.showCaptureLogReport();
```


### Manually log an exception

To manually log an exception, you call the `logException` method from the `BugseeManager` class. You can add traces and events to the reported exception.

```dart
final bugseeManager = Get.I.get<BugseeManager>();
bugseeManger.logException(exception: Exception());
```


### Add attributes

To attach the user's email to the logged exception use `addEmailAttribute` method and to clear this attribute you can use `clearEmailAttribute`.

```dart
final bugseeManager = Get.I.get<BugseeManager>();
bugseeManger.addEmailAttribute("johndoe@nventive.com");
//some other code..
bugseeManger.clearEmailAttribute();
```

for other attributes you can use `addAttributes` with a map where key is the attribute name and value is the attribute value. To clear these attributes use `clearAttribute` and pass the attribute name to it.

```dart
final bugseeManager = Get.I.get<BugseeManager>();
bugseeManger.addAttributes({
    'name': 'john',
    'age': 45,
});
//some other code..
bugseeManger.clearAttribute('name');
```

## 3) Deployment

The Bugsee token is injected directly in the azure devops pipeline when building the Android/iOS app for release mode in the [Android Build Job](../build/steps-build-android.yml) and [iOS Build Job](../build/steps-build-ios.yml) under the `multiDartDefine` parameter.