import 'dart:async';

import 'package:app/access/kill_switch/kill_switch_repository.dart';

/// Repository that emits whether the kill switch of the application is activated.
abstract interface class KillSwitchService {
  factory KillSwitchService(
    KillSwitchRepository killSwitchRepository,
  ) = _KillSwitchService;

  /// Stream that emits the state of the kill switch.
  Stream<bool> isKillSwitchActivatedStream();
}

/// Implementation of [KillSwitchService].
final class _KillSwitchService implements KillSwitchService {
  final KillSwitchRepository _killSwitchRepository;

  _KillSwitchService(
    KillSwitchRepository killSwitchRepository,
  ) : _killSwitchRepository = killSwitchRepository;

  @override
  Stream<bool> isKillSwitchActivatedStream() {
    return _killSwitchRepository.isKillSwitchActivatedStream;
  }
}
