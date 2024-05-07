import 'dart:async';

import 'package:app/access/kill_switch/kill_switch_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

/// Mock implementation of the [KillSwitchRepository].
final class KillSwitchRepositoryMock
    implements KillSwitchRepository, Disposable {
  BehaviorSubject<bool> isKillSwitchActivatedStreamController =
      BehaviorSubject();

  KillSwitchRepositoryMock() {
    isKillSwitchActivatedStreamController.add(isKillSwitchActivated);
  }

  bool isKillSwitchActivated = false;

  /// Sets the state of the kill switch.
  void toggleKillSwitchState() {
    isKillSwitchActivated = !isKillSwitchActivated;

    isKillSwitchActivatedStreamController.add(isKillSwitchActivated);
  }

  @override
  Stream<bool> get isKillSwitchActivatedStream =>
      isKillSwitchActivatedStreamController.stream;

  @override
  FutureOr onDispose() {
    isKillSwitchActivatedStreamController.close();
  }
}
