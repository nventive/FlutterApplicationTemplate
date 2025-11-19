import 'dart:io';
import 'package:app/access/play_integrity/data/integrity_error_code.dart';
import 'package:app/access/play_integrity/data/integrity_token_response.dart';
import 'package:app/access/play_integrity/play_integrity_repository.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Real implementation of [PlayIntegrityRepository] using platform channels.
///
/// This implementation communicates with native Android code via method channels
/// to access the Google Play Integrity API.
///
/// Note: This requires native Android implementation in the android/ directory.
final class PlayIntegrityRepositoryImpl implements PlayIntegrityRepository {
  static const MethodChannel _channel =
      MethodChannel('com.nventive.app/play_integrity');

  final Logger _logger;

  PlayIntegrityRepositoryImpl(this._logger);

  @override
  Future<void> prepareIntegrityTokenProvider(int cloudProjectNumber) async {
    if (!Platform.isAndroid) {
      throw const IntegrityException(
        IntegrityErrorCode.apiNotAvailable,
        'Play Integrity is only available on Android',
      );
    }

    try {
      await _channel.invokeMethod('prepareIntegrityTokenProvider', {
        'cloudProjectNumber': cloudProjectNumber,
      });
      _logger.i('Play Integrity token provider prepared successfully');
    } on PlatformException catch (e) {
      _logger.e(
          'Failed to prepare integrity token provider: ${e.code} - ${e.message}');
      throw IntegrityException(
        _mapErrorCode(e.code),
        e.message ?? 'Failed to prepare token provider',
      );
    }
  }

  @override
  Future<String> requestStandardIntegrityToken(String requestHash) async {
    if (!Platform.isAndroid) {
      throw const IntegrityException(
        IntegrityErrorCode.apiNotAvailable,
        'Play Integrity is only available on Android',
      );
    }

    if (requestHash.length > 500) {
      throw const IntegrityException(
        IntegrityErrorCode.requestHashTooLong,
        'Request hash must be 500 characters or less',
      );
    }

    try {
      final String? token =
          await _channel.invokeMethod('requestStandardIntegrityToken', {
        'requestHash': requestHash,
      });

      if (token == null || token.isEmpty) {
        throw const IntegrityException(
          IntegrityErrorCode.unknown,
          'Received empty token from Play Integrity API',
        );
      }

      return token;
    } on PlatformException catch (e) {
      _logger.e(
          'Failed to request standard integrity token: ${e.code} - ${e.message}');
      throw IntegrityException(
        _mapErrorCode(e.code),
        e.message ?? 'Failed to request standard integrity token',
      );
    }
  }

  @override
  Future<String> requestClassicIntegrityToken(String nonce) async {
    if (!Platform.isAndroid) {
      throw const IntegrityException(
        IntegrityErrorCode.apiNotAvailable,
        'Play Integrity is only available on Android',
      );
    }

    // Validate nonce is base64 encoded
    try {
      // Basic base64 validation
      if (!RegExp(r'^[A-Za-z0-9+/]+=*$').hasMatch(nonce)) {
        throw const IntegrityException(
          IntegrityErrorCode.nonceIsNotBase64,
          'Nonce must be base64 encoded',
        );
      }
    } catch (e) {
      throw const IntegrityException(
        IntegrityErrorCode.nonceIsNotBase64,
        'Invalid nonce format',
      );
    }

    try {
      final String? token =
          await _channel.invokeMethod('requestClassicIntegrityToken', {
        'nonce': nonce,
      });

      if (token == null || token.isEmpty) {
        throw const IntegrityException(
          IntegrityErrorCode.unknown,
          'Received empty token from Play Integrity API',
        );
      }

      return token;
    } on PlatformException catch (e) {
      _logger.e(
          'Failed to request classic integrity token: ${e.code} - ${e.message}');
      throw IntegrityException(
        _mapErrorCode(e.code),
        e.message ?? 'Failed to request classic integrity token',
      );
    }
  }

  @override
  Future<IntegrityTokenResponse> decryptIntegrityToken(
    String token,
    String packageName,
  ) async {
    // Token decryption MUST be done server-side for security reasons
    // The decryption key should never be exposed to the client
    _logger
        .w('decryptIntegrityToken called - this should be done server-side!');
    throw IntegrityException(
      IntegrityErrorCode.internalError,
      'Token decryption must be performed on your backend server. '
      'See: https://developer.android.com/google/play/integrity/setup#token-response',
    );
  }

  @override
  Future<bool> isPlayIntegrityAvailable() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final bool? available =
          await _channel.invokeMethod('isPlayIntegrityAvailable');
      return available ?? false;
    } on PlatformException catch (e) {
      _logger.w(
          'Failed to check Play Integrity availability: ${e.code} - ${e.message}');
      return false;
    }
  }

  /// Maps platform exception error codes to [IntegrityErrorCode].
  IntegrityErrorCode _mapErrorCode(String? code) {
    if (code == null) return IntegrityErrorCode.unknown;

    switch (code) {
      case 'API_NOT_AVAILABLE':
      case '-1':
        return IntegrityErrorCode.apiNotAvailable;
      case 'APP_NOT_INSTALLED':
      case '-5':
        return IntegrityErrorCode.appNotInstalled;
      case 'APP_UID_MISMATCH':
      case '-7':
        return IntegrityErrorCode.appUidMismatch;
      case 'CANNOT_BIND_TO_SERVICE':
      case '-9':
        return IntegrityErrorCode.cannotBindToService;
      case 'GOOGLE_SERVER_UNAVAILABLE':
      case '-13':
        return IntegrityErrorCode.googleServerUnavailable;
      case 'NETWORK_ERROR':
      case '-3':
        return IntegrityErrorCode.networkError;
      case 'NONCE_IS_NOT_BASE64':
      case '-14':
        return IntegrityErrorCode.nonceIsNotBase64;
      case 'NONCE_TOO_LONG':
      case '-11':
        return IntegrityErrorCode.nonceTooLong;
      case 'NONCE_TOO_SHORT':
      case '-10':
        return IntegrityErrorCode.nonceTooShort;
      case 'PLAY_SERVICES_NOT_FOUND':
      case '-6':
        return IntegrityErrorCode.playServicesNotFound;
      case 'PLAY_SERVICES_VERSION_OUTDATED':
      case '-16':
        return IntegrityErrorCode.playServicesVersionOutdated;
      case 'PLAY_STORE_ACCOUNT_NOT_FOUND':
      case '-4':
        return IntegrityErrorCode.playStoreAccountNotFound;
      case 'PLAY_STORE_VERSION_OUTDATED':
      case '-15':
        return IntegrityErrorCode.playStoreVersionOutdated;
      case 'PLAY_STORE_NOT_FOUND':
      case '-2':
        return IntegrityErrorCode.playStoreNotFound;
      case 'TOO_MANY_REQUESTS':
      case '-8':
        return IntegrityErrorCode.tooManyRequests;
      case 'STANDARD_INTEGRITY_INITIALIZATION_NEEDED':
      case '-100':
        return IntegrityErrorCode.standardIntegrityInitializationNeeded;
      case 'STANDARD_INTEGRITY_INITIALIZATION_FAILED':
      case '-101':
        return IntegrityErrorCode.standardIntegrityInitializationFailed;
      case 'STANDARD_INTEGRITY_INVALID_ARGUMENT':
      case '-102':
        return IntegrityErrorCode.standardIntegrityInvalidArgument;
      case 'INTEGRITY_TOKEN_PROVIDER_INVALID':
      case '-19':
        return IntegrityErrorCode.integrityTokenProviderInvalid;
      default:
        return IntegrityErrorCode.unknown;
    }
  }
}
