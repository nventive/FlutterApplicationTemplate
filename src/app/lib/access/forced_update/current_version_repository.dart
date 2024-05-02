import 'package:app/access/forced_update/data/version.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Repository to get what is the current version of the app.
abstract interface class CurrentVersionRepository {
  factory CurrentVersionRepository() = _CurrentVersionRepository;

  Future<Version> getCurrentVersion();
}

/// Implementation of [CurrentVersionRepository].
final class _CurrentVersionRepository implements CurrentVersionRepository {
  _CurrentVersionRepository();

  Version? _currentVersion;

  @override
  Future<Version> getCurrentVersion() async {
    if (_currentVersion == null) {
      var packageInfo = await PackageInfo.fromPlatform();

      _currentVersion = Version.fromString(packageInfo.version);
    }

    return SynchronousFuture(_currentVersion!);
  }
}
