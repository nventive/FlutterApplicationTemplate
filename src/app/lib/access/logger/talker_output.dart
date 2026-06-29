import 'package:logger/logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Custom implementation of [LogOutput] to add [Talker] logs writing support.
final class TalkerOutput extends LogOutput {
  final Talker _talker;

  TalkerOutput({required Talker talker})
      : _talker = talker,
        super();

  @override
  void output(OutputEvent event) {
    final message = event.origin.message;
    final error = event.origin.error;
    final stackTrace = event.origin.stackTrace;

    switch (event.origin.level) {
      case Level.trace:
      case Level.debug:
        _talker.debug(message, error, stackTrace);
      case Level.info:
        _talker.info(message, error, stackTrace);
      case Level.warning:
        _talker.warning(message, error, stackTrace);
      case Level.error:
        _talker.error(message, error, stackTrace);
      case Level.fatal:
        _talker.critical(message, error, stackTrace);
      default:
        _talker.log(message, exception: error, stackTrace: stackTrace);
    }
  }
}
