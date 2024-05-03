import 'package:logger/logger.dart';

/// Custom implementation of [LogFilter] to ensure logging for a given minimum[Level].
final class LevelLogFilter extends LogFilter {
  Level minimumLevel;

  LevelLogFilter(this.minimumLevel);

  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= minimumLevel.index;
  }
}
