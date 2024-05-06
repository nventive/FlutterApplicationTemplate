# Logging

We use [Logger](https://pub.dev/packages/logger) for logging.

For more documentation on logging, read the references listed at the bottom.

## Log levels

We use the following convention for log levels:

- **Trace** : Used for parts of a method to capture a flow with `logger.t()`.
- **Debug** : Used for diagnostics information with `logger.d()`.
- **Information** : Used for general successful information. Generally the default minimum with `logger.i()`.
- **Warning** : Used for anything that can potentially cause application oddities. Automatically recoverable with `logger.w()`.
- **Error** : Used for anything that is fatal to the current operation but not to the whole process. Potentially recoverable with `logger.e()`.
- **Fatal** : Used for anything that is forcing a shutdown to prevent data loss or corruption. Not recoverable with `logger.f()`.

## Log providers

- We've implemented [CustomFileOutput](../src/app/lib/business/logger/custom_file_output.dart) for file logging.
- We've implemented [CustomConsoleOutput](../src/app/lib/business/logger/custom_file_output.dart) to workaround this issue https://github.com/flutter/flutter/issues/64491.
- We've implemented [LevelLogFilter](../src/app/lib/business/logger/level_log_filter.dart) to ensure that logs are filtered for a given log level.

The loggers are configured inside the [LoggerManager.cs](../src/app/lib/business/logger/logger_manager.dart) file.

## Logging

To log, you simply need to get a `Logger` and use the appropriate methods.

```dart
final myLogger = Get.It.Get<Logger>();

myLogger.i("This is an information log.");
```

## Diagnostics

Multiple logging features can be tested from the diagnostics screen. This is configured in [LoggerDiagnosticWidget](../src/app/lib/presentation/diagnostic/logger_diagnostic_widget.dart).

- You can test the different log levels / providers. 
- You can enable / disable console logging.
- You can enable / disable file logging.
- You can see if a log file exists.
- You can share the logs / app summary by email, etc.

## References
- [Logger documentation](https://pub.dev/documentation/logger/latest/logger/logger-library.html)
