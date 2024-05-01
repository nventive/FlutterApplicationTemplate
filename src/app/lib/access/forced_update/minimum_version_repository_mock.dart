import 'dart:async';

import 'package:app/access/forced_update/data/version.dart';
import 'package:app/access/forced_update/minimum_version_repository.dart';

/// Mock implementation of [MinimumVersionRepository].
final class MinimumVersionRepositoryMock implements MinimumVersionRepository {
  final StreamController<Version> _controller =
      StreamController<Version>.broadcast();

  /// Updates the minimum version required to use the application.
  void updateMinimumVersion() {
    _controller.add(Version(2, 0, 0));
  }

  @override
  Stream<Version> get minimumVersionStream => _controller.stream;
}
