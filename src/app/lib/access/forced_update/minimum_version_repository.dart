import 'dart:async';

import 'package:app/access/forced_update/data/version.dart';

/// Repository that gets the minimum version required to use the application..
abstract interface class MinimumVersionRepository {
  /// Stream of the minimum version required to use the application.
  Stream<Version> get minimumVersionStream;
}
