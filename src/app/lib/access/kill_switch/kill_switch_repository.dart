import 'dart:async';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

/// Repository that emits whether the kill switch of the application is activated.
abstract interface class KillSwitchRepository {
  factory KillSwitchRepository() = _KillSwitchRepository;

  /// Stream that emits the state of the kill switch.
  Stream<bool> get isKillSwitchActivatedStream;
}

/// Implementation of [KillSwitchRepository] that emits a stream using data from firebase.
final class _KillSwitchRepository implements KillSwitchRepository, Disposable {
  final BehaviorSubject<bool> _isKillSwitchActivatedStreamController =
      BehaviorSubject<bool>.seeded(false);

  _KillSwitchRepository() {
    final remoteConfig = FirebaseRemoteConfig.instance;

    if (Platform.isAndroid || Platform.isIOS) {
      remoteConfig.onConfigUpdated.listen((event) async {
        await remoteConfig.activate();

        _updateKillSwitch();
      });
    }

    //Fetch and activate gets the data from the server and makes it available trough the singleton.
    remoteConfig.fetchAndActivate().then((_) {
      _updateKillSwitch();
    });
  }

  void _updateKillSwitch() {
    final remoteConfig = FirebaseRemoteConfig.instance;

    final isKillSwitchActivated = remoteConfig.getBool('is_kill_switch_active');

    _isKillSwitchActivatedStreamController.add(isKillSwitchActivated);
  }

  @override
  Stream<bool> get isKillSwitchActivatedStream =>
      _isKillSwitchActivatedStreamController.stream;

  @override
  FutureOr onDispose() {
    _isKillSwitchActivatedStreamController.close();
  }
}
