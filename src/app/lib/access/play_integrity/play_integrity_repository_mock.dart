import 'package:app/access/play_integrity/data/integrity_error_code.dart';
import 'package:app/access/play_integrity/data/integrity_token_response.dart';
import 'package:app/access/play_integrity/play_integrity_repository.dart';

/// Mocked implementation of [PlayIntegrityRepository] for testing.
///
/// This implementation returns predefined responses and is useful for:
/// - Testing on non-Android platforms (iOS, Windows, macOS, Linux)
/// - Unit testing without requiring Google Play Services
/// - Development and debugging
class PlayIntegrityRepositoryMock implements PlayIntegrityRepository {
  bool _isPrepared = false;
  int? _preparedCloudProjectNumber;

  @override
  Future<void> prepareIntegrityTokenProvider(int cloudProjectNumber) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isPrepared = true;
    _preparedCloudProjectNumber = cloudProjectNumber;
  }

  @override
  Future<String> requestStandardIntegrityToken(String requestHash) async {
    if (!_isPrepared) {
      throw const IntegrityException(
        IntegrityErrorCode.standardIntegrityInitializationNeeded,
        'Token provider not prepared',
      );
    }

    await Future.delayed(const Duration(milliseconds: 200));

    // Return a mock token
    return 'mock_standard_integrity_token_$requestHash';
  }

  @override
  Future<String> requestClassicIntegrityToken(String nonce) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Return a mock token
    return 'mock_classic_integrity_token_$nonce';
  }

  @override
  Future<IntegrityTokenResponse> decryptIntegrityToken(
    String token,
    String packageName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Return a mock successful response
    final mockJson = {
      'requestDetails': {
        'requestPackageName': packageName,
        'requestHash': 'mock_hash',
        'timestampMillis': DateTime.now().millisecondsSinceEpoch,
      },
      'appIntegrity': {
        'appRecognitionVerdict': 'PLAY_RECOGNIZED',
        'packageName': packageName,
        'certificateSha256Digest': ['mock_cert_hash'],
        'versionCode': '1',
      },
      'deviceIntegrity': {
        'deviceRecognitionVerdict': ['MEETS_DEVICE_INTEGRITY'],
      },
      'accountDetails': {
        'appLicensingVerdict': 'LICENSED',
      },
    };

    return IntegrityTokenResponse.fromJson(mockJson);
  }

  @override
  Future<bool> isPlayIntegrityAvailable() async {
    // Always return true in mock mode
    return true;
  }

  /// Resets the mock state (useful for testing).
  void reset() {
    _isPrepared = false;
    _preparedCloudProjectNumber = null;
  }
}
