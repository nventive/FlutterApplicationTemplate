import 'package:app/access/play_integrity/data/integrity_error_code.dart';
import 'package:app/access/play_integrity/data/integrity_token_response.dart';

/// Repository for interacting with the Google Play Integrity API.
///
/// This repository provides methods to request integrity tokens and verdicts
/// from the Play Integrity API to verify the integrity of the app, device,
/// and user account.
abstract interface class PlayIntegrityRepository {
  /// Prepares the integrity token provider (one-off initialization).
  ///
  /// This should be called when your app launches or before you need to request
  /// integrity verdicts. The preparation is asynchronous and typically takes a few seconds.
  ///
  /// [cloudProjectNumber] - Your Google Cloud project number with Play Integrity API enabled.
  ///
  /// Throws [IntegrityException] if preparation fails.
  Future<void> prepareIntegrityTokenProvider(int cloudProjectNumber);

  /// Requests a standard integrity token.
  ///
  /// Standard API requests are suitable for any app or game and can be made on demand
  /// to check that any user action or server request is genuine. They have the lowest
  /// latency (a few hundred milliseconds on average).
  ///
  /// [requestHash] - A hash of all relevant request parameters to protect against
  /// tampering attacks. Should be computed using a secure hash function (e.g., SHA-256).
  /// The value has a maximum length of 500 bytes.
  ///
  /// Returns the encrypted integrity token string that should be sent to your backend
  /// server for decryption and verification.
  ///
  /// Throws [IntegrityException] if the request fails.
  Future<String> requestStandardIntegrityToken(String requestHash);

  /// Requests a classic integrity token.
  ///
  /// Classic API requests have higher latency (a few seconds on average) and should
  /// be made infrequently as a one-off to check whether a highly sensitive or valuable
  /// action is genuine.
  ///
  /// [nonce] - A base64-encoded URL-safe no-wrap nonce to protect against replay
  /// and tampering attacks. The nonce must be 16-500 bytes before base64 encoding.
  ///
  /// Returns the encrypted integrity token string that should be sent to your backend
  /// server for decryption and verification.
  ///
  /// Throws [IntegrityException] if the request fails.
  Future<String> requestClassicIntegrityToken(String nonce);

  /// Decrypts and verifies an integrity token on Google's servers.
  ///
  /// This should be called from your backend server to decrypt and verify
  /// the integrity token received from the client.
  ///
  /// [token] - The encrypted integrity token received from [requestStandardIntegrityToken]
  /// or [requestClassicIntegrityToken].
  /// [packageName] - Your app's package name.
  ///
  /// Returns the decrypted [IntegrityTokenResponse] containing all verdicts.
  ///
  /// Throws [IntegrityException] if decryption/verification fails.
  Future<IntegrityTokenResponse> decryptIntegrityToken(
    String token,
    String packageName,
  );

  /// Returns true if the Play Integrity API is available on the device.
  Future<bool> isPlayIntegrityAvailable();
}
