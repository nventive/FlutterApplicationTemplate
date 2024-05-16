import 'dart:async';

import 'package:app/access/forced_update/data/version.dart';
import 'package:app/access/forced_update/minimum_version_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

/// Mock implementation of [MinimumVersionRepository].
final class MinimumVersionRepositoryMock
    implements MinimumVersionRepository, Disposable {
  final BehaviorSubject<Version> _minimumVersionBehaviorSubject =
      BehaviorSubject<Version>();

  /// Updates the minimum version required to use the application.
  void updateMinimumVersion({Version version = const Version(2, 0, 0)}) {
    _minimumVersionBehaviorSubject.add(version);
  }

  @override
  Stream<Version> get minimumVersionStream =>
      _minimumVersionBehaviorSubject.stream;

  @override
  FutureOr onDispose() {
    _minimumVersionBehaviorSubject.close();
  }
}
