import 'dart:convert';
import 'dart:math';
import 'package:app/access/play_integrity/data/integrity_error_code.dart';
import 'package:app/access/play_integrity/data/integrity_token_response.dart';
import 'package:app/access/play_integrity/play_integrity_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

/// Service for managing Play Integrity API requests and verdicts.
///
/// This service provides high-level methods to check app, device, and account
/// integrity using the Google Play Integrity API.
abstract interface class PlayIntegrityService {
  factory PlayIntegrityService(
    PlayIntegrityRepository repository,
    Logger logger,
  ) = _PlayIntegrityService;

  /// Initializes the Play Integrity API with your cloud project number.
  ///
  /// This should be called early in your app's lifecycle (e.g., in main.dart).
  ///
  /// [cloudProjectNumber] - Your Google Cloud project number with Play Integrity API enabled.
  Future<void> initialize(int cloudProjectNumber);

  /// Performs a standard integrity check for the given request data.
  ///
  /// Standard checks are suitable for frequent, on-demand verification and have
  /// low latency (~few hundred ms).
  ///
  /// [requestData] - The data associated with the request (e.g., user action, server request).
  /// This will be hashed and included in the integrity token.
  ///
  /// Returns true if integrity check passed (device is trustworthy, app is recognized,
  /// user is licensed).
  Future<bool> performStandardIntegrityCheck(Map<String, dynamic> requestData);

  /// Performs a classic integrity check.
  ///
  /// Classic checks should be used infrequently for high-value actions and have
  /// higher latency (~few seconds).
  ///
  /// Returns true if integrity check passed.
  Future<bool> performClassicIntegrityCheck();

  /// Gets a standard integrity token for the given request data.
  ///
  /// This returns the encrypted token that should be sent to your backend server
  /// for decryption and verification.
  ///
  /// [requestData] - The data associated with the request.
  Future<String> getStandardIntegrityToken(Map<String, dynamic> requestData);

  /// Gets a classic integrity token.
  ///
  /// This returns the encrypted token that should be sent to your backend server
  /// for decryption and verification.
  Future<String> getClassicIntegrityToken();

  /// Generates a secure nonce for classic integrity requests.
  ///
  /// The nonce is a random base64-encoded value that protects against replay attacks.
  String generateNonce();

  /// Computes a SHA-256 hash of the request data for standard integrity requests.
  ///
  /// [requestData] - The request data to hash.
  String computeRequestHash(Map<String, dynamic> requestData);

  /// Returns true if Play Integrity API is available on this device.
  Future<bool> isAvailable();
}

/// Implementation of [PlayIntegrityService].
final class _PlayIntegrityService implements PlayIntegrityService {
  final PlayIntegrityRepository _repository;
  final Logger _logger;
  final Random _random = Random.secure();

  bool _isInitialized = false;

  _PlayIntegrityService(
    PlayIntegrityRepository repository,
    Logger logger,
  )   : _repository = repository,
        _logger = logger;

  @override
  Future<void> initialize(int cloudProjectNumber) async {
    try {
      _logger.i('Initializing Play Integrity Service...');
      await _repository.prepareIntegrityTokenProvider(cloudProjectNumber);
      _isInitialized = true;
      _logger.i('Play Integrity Service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Play Integrity Service', error: e);
      rethrow;
    }
  }

  @override
  Future<bool> performStandardIntegrityCheck(
      Map<String, dynamic> requestData) async {
    try {
      if (!_isInitialized) {
        throw const IntegrityException(
          IntegrityErrorCode.standardIntegrityInitializationNeeded,
          'Play Integrity Service not initialized. Call initialize() first.',
        );
      }

      final requestHash = computeRequestHash(requestData);
      final token =
          await _repository.requestStandardIntegrityToken(requestHash);

      // Note: In production, you should send this token to your backend server
      // for decryption and verification. For this template, we'll just check
      // if we received a token successfully.

      _logger.d('Standard integrity check completed, token received');
      return token.isNotEmpty;
    } on IntegrityException catch (e) {
      _logger.w('Standard integrity check failed: ${e.errorCode.message}');
      return false;
    } catch (e) {
      _logger.e('Unexpected error during standard integrity check', error: e);
      return false;
    }
  }

  @override
  Future<bool> performClassicIntegrityCheck() async {
    try {
      final nonce = generateNonce();
      final token = await _repository.requestClassicIntegrityToken(nonce);

      // Note: In production, you should send this token to your backend server
      // for decryption and verification.

      _logger.d('Classic integrity check completed, token received');
      return token.isNotEmpty;
    } on IntegrityException catch (e) {
      _logger.w('Classic integrity check failed: ${e.errorCode.message}');
      return false;
    } catch (e) {
      _logger.e('Unexpected error during classic integrity check', error: e);
      return false;
    }
  }

  @override
  Future<String> getStandardIntegrityToken(
      Map<String, dynamic> requestData) async {
    if (!_isInitialized) {
      throw const IntegrityException(
        IntegrityErrorCode.standardIntegrityInitializationNeeded,
        'Play Integrity Service not initialized. Call initialize() first.',
      );
    }

    final requestHash = computeRequestHash(requestData);
    return await _repository.requestStandardIntegrityToken(requestHash);
  }

  @override
  Future<String> getClassicIntegrityToken() async {
    final nonce = generateNonce();
    return await _repository.requestClassicIntegrityToken(nonce);
  }

  @override
  String generateNonce() {
    // Generate a 32-byte random nonce and base64 encode it
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  @override
  String computeRequestHash(Map<String, dynamic> requestData) {
    // Convert request data to a stable JSON string and compute SHA-256 hash
    final jsonString = jsonEncode(requestData);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes);
  }

  @override
  Future<bool> isAvailable() async {
    return await _repository.isPlayIntegrityAvailable();
  }
}
