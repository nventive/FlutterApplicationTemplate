import 'package:app/access/mocking/mocking_repository.dart';

/// Service that manages everything related to mocking.
abstract interface class MockingManager {
  factory MockingManager(MockingRepository mockingRepository) = _MockingManager;

  /// Gets whether mocking is enabled.
  bool get isMockingEnabled;

  /// Gets whether mocking configuration has been changed via [setIsMockingEnabled].
  bool get hasConfigurationBeenChanged;

  /// Sets whether mocking should be enabled on next app launch.
  Future<void> setIsMockingEnabled(bool isMockingEnabled);

  /// Initializes the mocking manager.
  Future<void> initialize();
}

/// Implementation of [MockingManager].
/// This class is responsible for managing the mocking configuration.
final class _MockingManager implements MockingManager {
  final MockingRepository _mockingRepository;

   late bool _initialIsMockingEnabled;

  _MockingManager(this._mockingRepository);

  @override
  bool hasConfigurationBeenChanged = false;

  @override
  late bool isMockingEnabled;
    
  @override
  Future<void> initialize() async {
    _initialIsMockingEnabled = await _mockingRepository.isMockingEnabled();
    isMockingEnabled = _initialIsMockingEnabled;
  }

  @override
  Future<void> setIsMockingEnabled(bool isMockingEnabled) async {
    await _mockingRepository.setMocking(isMockingEnabled);

     this.isMockingEnabled = isMockingEnabled;
    hasConfigurationBeenChanged = isMockingEnabled != _initialIsMockingEnabled;
  }
}
