import 'dart:async';

/// Repository that emits whether the kill switch of the application is activated.
abstract interface class KillSwitchRepository {
  /// Stream that emits the state of the kill switch.
  Stream<bool> get isKillSwitchActivatedStream;
}
