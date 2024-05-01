import 'dart:async';

import 'package:app/access/forced_update/current_version_repository.dart';
import 'package:app/access/forced_update/minimum_version_repository.dart';

/// This service checks if the application is running the minimum required version.
abstract interface class UpdateRequiredService {
  factory UpdateRequiredService(
    MinimumVersionRepository minimumVersionRepository,
    CurrentVersionRepository currentVersionService,
  ) = _UpdateRequiredService;

  /// Checks if the application is running the minimum required version.
  /// We use a Future<void> since this is a one-time check.
  Future<void> checkUpdateRequired();
}

/// Implementation of [UpdateRequiredService].
final class _UpdateRequiredService implements UpdateRequiredService {
  final MinimumVersionRepository _minimumVersionRepository;
  final CurrentVersionRepository _currentVersionService;

  _UpdateRequiredService(
    this._minimumVersionRepository,
    this._currentVersionService,
  );

  @override
  Future<void> checkUpdateRequired() async {
    final currentVersion = await _currentVersionService.getCurrentVersion();

    return _minimumVersionRepository.minimumVersionStream
        .where((minVersion) => currentVersion.compareTo(minVersion) < 0)
        .first
        .then((_) {});
  }
}
