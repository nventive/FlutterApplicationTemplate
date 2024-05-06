import 'dart:async';
import 'dart:io';

import 'package:app/access/forced_update/data/version.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get_it/get_it.dart';

/// Repository that gets the minimum version required to use the application.
abstract interface class MinimumVersionRepository {
  factory MinimumVersionRepository() = _MinimumVersionRepository;

  /// Stream of the minimum version required to use the application.
  Stream<Version> get minimumVersionStream;
}

/// Implementation of [MinimumVersionRepository].
final class _MinimumVersionRepository
    implements MinimumVersionRepository, Disposable {
  _MinimumVersionRepository() {
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

    // Listen to updates to the remote config. This is only available on mobile platforms.
    if (Platform.isAndroid || Platform.isIOS) {
      remoteConfig.onConfigUpdated.listen((event) async {
        await remoteConfig.activate();

        _updateMinimumVersion();
      });
    }

    // Fetch and activate gets the data from the server and makes it available trough the singleton.
    remoteConfig.fetchAndActivate().then((_) {
      _updateMinimumVersion();
    });
  }

  void _updateMinimumVersion() {
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

    final minimumVersion = remoteConfig.getString('minimum_version');
    final version = Version.fromString(minimumVersion);

    _minimumVersionStreamController.add(version);
  }

  final StreamController<Version> _minimumVersionStreamController =
      StreamController<Version>.broadcast();

  @override
  Stream<Version> get minimumVersionStream =>
      _minimumVersionStreamController.stream;

  @override
  FutureOr onDispose() {
    _minimumVersionStreamController.close();
  }
}
