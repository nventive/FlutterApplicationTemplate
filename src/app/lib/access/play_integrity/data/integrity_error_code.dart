/// Error codes returned by the Play Integrity API.
///
/// These error codes indicate various failure conditions when requesting
/// integrity verdicts from the Play Integrity API.
enum IntegrityErrorCode {
  /// API is not available. Play Store might need to be updated.
  apiNotAvailable,

  /// No official Play Store app was found on the device.
  playStoreNotFound,

  /// Network error occurred.
  networkError,

  /// No Play Store account is found on the device (Classic requests only).
  playStoreAccountNotFound,

  /// The calling app is not installed.
  appNotInstalled,

  /// Play services are unavailable or need to be updated.
  playServicesNotFound,

  /// The calling app UID does not match Package Manager.
  appUidMismatch,

  /// Too many requests. The app has been throttled.
  tooManyRequests,

  /// Binding to the service in the Play Store has failed.
  cannotBindToService,

  /// Nonce is too short (Classic requests only).
  nonceTooShort,

  /// Nonce is too long (Classic requests only).
  nonceTooLong,

  /// Google server is unavailable.
  googleServerUnavailable,

  /// Nonce is not base64 encoded (Classic requests only).
  nonceIsNotBase64,

  /// Google Play Store app needs to be updated.
  playStoreVersionOutdated,

  /// Google Play services need to be updated.
  playServicesVersionOutdated,

  /// The provided cloud project number is invalid.
  cloudProjectNumberIsInvalid,

  /// Request hash is too long (Standard requests only).
  requestHashTooLong,

  /// Transient error has occurred on the client device.
  clientTransientError,

  /// The StandardIntegrityTokenProvider is no longer valid (Standard requests only).
  integrityTokenProviderInvalid,

  /// Unknown internal error.
  internalError,

  /// StandardIntegrityManager is not initialized (Native only).
  standardIntegrityInitializationNeeded,

  /// Error initializing the Standard Integrity API (Native only).
  standardIntegrityInitializationFailed,

  /// Invalid argument passed to the API (Native only).
  standardIntegrityInvalidArgument,

  /// Unknown error.
  unknown;

  /// Returns the error code value.
  int get code {
    switch (this) {
      case IntegrityErrorCode.apiNotAvailable:
        return -1;
      case IntegrityErrorCode.playStoreNotFound:
        return -2;
      case IntegrityErrorCode.networkError:
        return -3;
      case IntegrityErrorCode.playStoreAccountNotFound:
        return -4;
      case IntegrityErrorCode.appNotInstalled:
        return -5;
      case IntegrityErrorCode.playServicesNotFound:
        return -6;
      case IntegrityErrorCode.appUidMismatch:
        return -7;
      case IntegrityErrorCode.tooManyRequests:
        return -8;
      case IntegrityErrorCode.cannotBindToService:
        return -9;
      case IntegrityErrorCode.nonceTooShort:
        return -10;
      case IntegrityErrorCode.nonceTooLong:
        return -11;
      case IntegrityErrorCode.googleServerUnavailable:
        return -12;
      case IntegrityErrorCode.nonceIsNotBase64:
        return -13;
      case IntegrityErrorCode.playStoreVersionOutdated:
        return -14;
      case IntegrityErrorCode.playServicesVersionOutdated:
        return -15;
      case IntegrityErrorCode.cloudProjectNumberIsInvalid:
        return -16;
      case IntegrityErrorCode.requestHashTooLong:
        return -17;
      case IntegrityErrorCode.clientTransientError:
        return -18;
      case IntegrityErrorCode.integrityTokenProviderInvalid:
        return -19;
      case IntegrityErrorCode.internalError:
        return -100;
      case IntegrityErrorCode.standardIntegrityInitializationNeeded:
        return -101;
      case IntegrityErrorCode.standardIntegrityInitializationFailed:
        return -102;
      case IntegrityErrorCode.standardIntegrityInvalidArgument:
        return -103;
      case IntegrityErrorCode.unknown:
        return -999;
    }
  }

  /// Creates an [IntegrityErrorCode] from an error code value.
  static IntegrityErrorCode fromCode(int code) {
    return IntegrityErrorCode.values.firstWhere(
      (e) => e.code == code,
      orElse: () => IntegrityErrorCode.unknown,
    );
  }

  /// Returns true if this error is retryable.
  bool get isRetryable {
    switch (this) {
      case IntegrityErrorCode.networkError:
      case IntegrityErrorCode.tooManyRequests:
      case IntegrityErrorCode.googleServerUnavailable:
      case IntegrityErrorCode.clientTransientError:
      case IntegrityErrorCode.internalError:
      case IntegrityErrorCode.standardIntegrityInitializationFailed:
        return true;
      default:
        return false;
    }
  }

  /// Returns a user-friendly error message.
  String get message {
    switch (this) {
      case IntegrityErrorCode.apiNotAvailable:
        return 'Play Integrity API is not available. Please update Google Play Store.';
      case IntegrityErrorCode.playStoreNotFound:
        return 'Google Play Store is not installed on this device.';
      case IntegrityErrorCode.networkError:
        return 'Network error occurred. Please check your connection and try again.';
      case IntegrityErrorCode.playStoreAccountNotFound:
        return 'No Google Play account found. Please sign in to Google Play Store.';
      case IntegrityErrorCode.appNotInstalled:
        return 'App integrity check failed: App not properly installed.';
      case IntegrityErrorCode.playServicesNotFound:
        return 'Google Play services are unavailable. Please install or update them.';
      case IntegrityErrorCode.appUidMismatch:
        return 'App integrity check failed: Invalid app signature.';
      case IntegrityErrorCode.tooManyRequests:
        return 'Too many requests. Please try again later.';
      case IntegrityErrorCode.cannotBindToService:
        return 'Unable to connect to Google Play services. Please update Google Play Store.';
      case IntegrityErrorCode.nonceTooShort:
        return 'Request validation failed: Invalid nonce length.';
      case IntegrityErrorCode.nonceTooLong:
        return 'Request validation failed: Invalid nonce length.';
      case IntegrityErrorCode.googleServerUnavailable:
        return 'Google servers are temporarily unavailable. Please try again.';
      case IntegrityErrorCode.nonceIsNotBase64:
        return 'Request validation failed: Invalid nonce format.';
      case IntegrityErrorCode.playStoreVersionOutdated:
        return 'Google Play Store needs to be updated.';
      case IntegrityErrorCode.playServicesVersionOutdated:
        return 'Google Play services need to be updated.';
      case IntegrityErrorCode.cloudProjectNumberIsInvalid:
        return 'Invalid cloud project configuration.';
      case IntegrityErrorCode.requestHashTooLong:
        return 'Request validation failed: Request hash too long.';
      case IntegrityErrorCode.clientTransientError:
        return 'A temporary error occurred. Please try again.';
      case IntegrityErrorCode.integrityTokenProviderInvalid:
        return 'Integrity token provider expired. Please restart the request.';
      case IntegrityErrorCode.internalError:
        return 'An internal error occurred. Please try again.';
      case IntegrityErrorCode.standardIntegrityInitializationNeeded:
        return 'Play Integrity API not initialized.';
      case IntegrityErrorCode.standardIntegrityInitializationFailed:
        return 'Failed to initialize Play Integrity API.';
      case IntegrityErrorCode.standardIntegrityInvalidArgument:
        return 'Invalid argument provided to Play Integrity API.';
      case IntegrityErrorCode.unknown:
        return 'An unknown error occurred.';
    }
  }
}

/// Exception thrown when a Play Integrity API call fails.
class IntegrityException implements Exception {
  final IntegrityErrorCode errorCode;
  final String? details;

  const IntegrityException(this.errorCode, [this.details]);

  @override
  String toString() {
    final buffer = StringBuffer('IntegrityException: ${errorCode.message}');
    if (details != null) {
      buffer.write(' ($details)');
    }
    return buffer.toString();
  }
}
