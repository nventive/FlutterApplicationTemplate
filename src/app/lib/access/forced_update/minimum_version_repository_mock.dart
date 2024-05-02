import 'dart:async';

import 'package:app/access/forced_update/data/version.dart';
import 'package:app/access/forced_update/minimum_version_repository.dart';
import 'package:get_it/get_it.dart';

/// Mock implementation of [MinimumVersionRepository].
final class MinimumVersionRepositoryMock
    implements MinimumVersionRepository, Disposable {
  final StreamController<Version> _controller =
      StreamController<Version>.broadcast();

  /// Updates the minimum version required to use the application.
  void updateMinimumVersion() {
    _controller.add(Version(2, 0, 0));
  }

  @override
  Stream<Version> get minimumVersionStream => _controller.stream;

  @override
  FutureOr onDispose() {
    _controller.close();
  }
}
