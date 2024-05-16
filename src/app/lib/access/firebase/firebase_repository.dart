import 'dart:async';
import 'dart:io';

import 'package:app/access/forced_update/data/version.dart';
import 'package:app/access/forced_update/minimum_version_repository.dart';
import 'package:app/access/kill_switch/kill_switch_repository.dart';
import 'package:app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

/// Repository that gets the values from Firebase Remote Config.
/// Implements the [MinimumVersionRepository] and [KillSwitchRepository].
class FirebaseRemoteConfigRepository
    implements MinimumVersionRepository, KillSwitchRepository, Disposable {
  final Logger _logger;

  FirebaseRemoteConfigRepository(this._logger) {
    _initializeFirebaseServices();
  }

  /// Initializes Firebase services.
  Future _initializeFirebaseServices() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration(
          minutes:
              int.parse(dotenv.env["REMOTE_CONFIG_FETCH_INTERVAL_MINUTES"]!),
        ),
      ),
    );
    await remoteConfig.setDefaults(const {
      "minimum_version": "1.0.0",
      "is_kill_switch_active": false,
    });

    _logger.i("Firebase has been Initialized and registered in the container.");

    // Listen to updates to the remote config. This is only available on mobile platforms.
    if (Platform.isAndroid || Platform.isIOS) {
      remoteConfig.onConfigUpdated.listen((event) async {
        await remoteConfig.activate();

        _updateRemoteConfig();
      });
    }

    // Fetch and activate gets the data from the server and makes it available trough the singleton.
    remoteConfig.fetchAndActivate().then((_) {
      _updateRemoteConfig();
    });
  }

  /// Updates the remote config values.
  void _updateRemoteConfig() {
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

    final minimumVersion = remoteConfig.getString('minimum_version');
    final version = Version.fromString(minimumVersion);

    final isKillSwitchActive = remoteConfig.getBool('is_kill_switch_active');

    _minimumVersionBehaviorSubject.add(version);
    _isKillSwitchActiveBehaviorSubject.add(isKillSwitchActive);
  }

  final BehaviorSubject<Version> _minimumVersionBehaviorSubject =
      BehaviorSubject<Version>.seeded(const Version(1, 0, 0));

  @override
  Stream<Version> get minimumVersionStream =>
      _minimumVersionBehaviorSubject.distinct();

  final BehaviorSubject<bool> _isKillSwitchActiveBehaviorSubject =
      BehaviorSubject<bool>.seeded(false);

  @override
  Stream<bool> get isKillSwitchActivatedStream =>
      _isKillSwitchActiveBehaviorSubject.distinct();

  @override
  FutureOr onDispose() {
    _minimumVersionBehaviorSubject.close();
    _isKillSwitchActiveBehaviorSubject.close();
  }
}
