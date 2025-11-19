# Google Play Integrity API

This app uses Google Play Integrity API to verify that app requests are coming from your genuine app binary, running on a genuine Android device. You can learn more about Play Integrity API in the [official documentation](https://developer.android.com/google/play/integrity/overview).

## Overview

The Play Integrity API provides three types of verdicts:

1. **Device Integrity**: Confirms the device is genuine and meets basic security requirements
2. **App Integrity**: Verifies the app was installed from Google Play Store
3. **Account Details**: Checks if the user has a licensed account

The API supports two request types:

- **Standard requests**: For frequent integrity checks with optimized performance
- **Classic requests**: For one-time or infrequent checks (backward compatibility)

## Setup

### 1. Google Cloud Configuration

1. Create or open a Google Cloud project linked to your Play Console app
2. Enable the Play Integrity API in the [Google Cloud Console](https://console.cloud.google.com/apis/library/playintegrity.googleapis.com)
3. Note your Cloud Project Number (found in Google Cloud Console → Project Settings)
4. Link your Play Console app to the Cloud project

### 2. Backend Server Setup

**Important**: Token decryption **must** be done on your backend server for security reasons. Never decrypt integrity tokens on the client.

1. Set up a backend service with the [Play Integrity API client library](https://cloud.google.com/java/docs/reference/google-cloud-playintegrity/latest/overview)
2. Create an endpoint that accepts integrity tokens and returns verdict information
3. Implement token verification using Google's server-side API
4. Configure service account credentials for API authentication

Example backend flow:

```
Client App → [Encrypted Token] → Your Backend → Play Integrity API → [Decrypted Verdict] → Your Backend → Client App
```

### 3. App Configuration

Add your Google Cloud Project Number to your environment files:

**.env.dev**

```
PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER=123456789012
```

**.env.staging**

```
PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER=123456789012
```

**.env.prod**

```
PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER=123456789012
```

## Usage

### Initialization

Initialize the Play Integrity service during app startup. This is typically done in your main initialization flow:

```dart
import 'package:get_it/get_it.dart';
import 'package:app/business/play_integrity/play_integrity_service.dart';

// In your initialization code
final playIntegrityService = GetIt.I.get<PlayIntegrityService>();
final cloudProjectNumber = int.parse(dotenv.env['PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER'] ?? '0');
await playIntegrityService.initialize(cloudProjectNumber);
```

### Standard Integrity Check (Recommended)

Use standard requests for frequent integrity checks with better performance:

```dart
// Generate a request hash from your request data
final requestData = {
  'user_id': userId,
  'action': 'purchase_item',
  'timestamp': DateTime.now().millisecondsSinceEpoch,
};
final requestHash = playIntegrityService.computeRequestHash(requestData);

// Perform the integrity check
final isIntegrityValid = await playIntegrityService.performStandardIntegrityCheck(requestHash);

if (isIntegrityValid) {
  // Proceed with sensitive operation
  await processPurchase();
} else {
  // Handle integrity failure
  showSecurityWarning();
}
```

### Classic Integrity Check

Use classic requests for one-time or infrequent checks:

```dart
// Generate a cryptographic nonce
final nonce = playIntegrityService.generateNonce();

// Perform the integrity check
final isIntegrityValid = await playIntegrityService.performClassicIntegrityCheck(nonce);

if (isIntegrityValid) {
  // Proceed with sensitive operation
  await processApiRequest();
} else {
  // Handle integrity failure
  showSecurityWarning();
}
```

### Getting Raw Tokens

If you need the raw tokens for backend verification:

```dart
// Standard request token
final requestHash = playIntegrityService.computeRequestHash(requestData);
final standardToken = await playIntegrityService.getStandardIntegrityToken(requestHash);

// Classic request token
final nonce = playIntegrityService.generateNonce();
final classicToken = await playIntegrityService.getClassicIntegrityToken(nonce);

// Send token to your backend for verification
final response = await yourApiClient.verifyIntegrityToken(standardToken);
```

## Architecture

The Play Integrity implementation follows the app's standard architecture pattern:

```
Presentation Layer (UI)
        ↓
Business Layer (PlayIntegrityService)
        ↓
Access Layer (PlayIntegrityRepository)
        ↓
Platform Channel (play_integrity package)
        ↓
Native Android (Play Integrity SDK)
```

### Components

**PlayIntegrityService** (`lib/business/play_integrity/play_integrity_service.dart`)

- Business logic for integrity checks
- Token request orchestration
- Cryptographic utilities (nonce generation, hash computation)
- Platform-agnostic interface for UI layer

**PlayIntegrityRepository** (`lib/access/play_integrity/play_integrity_repository.dart`)

- Repository interface defining data access contract
- Platform channel abstraction
- Token request/response handling

**PlayIntegrityRepositoryImpl** (`lib/access/play_integrity/play_integrity_repository_impl.dart`)

- Real implementation using `play_integrity` package
- Error mapping and exception handling
- Android-specific functionality

**PlayIntegrityRepositoryMock** (`lib/access/play_integrity/play_integrity_repository_mock.dart`)

- Mock implementation for testing and desktop platforms
- Simulated responses for development

## Error Handling

The implementation provides comprehensive error handling with specific error codes:

### Common Errors

| Error Code                    | Description                                         | Retryable | Action                         |
| ----------------------------- | --------------------------------------------------- | --------- | ------------------------------ |
| `API_NOT_AVAILABLE`           | Play Integrity API not available on device          | No        | Show error message             |
| `NETWORK_ERROR`               | Network connectivity issue                          | Yes       | Retry with exponential backoff |
| `APP_NOT_INSTALLED`           | App not installed via Play Store (testing/sideload) | No        | Allow in debug builds only     |
| `PLAY_SERVICES_NOT_AVAILABLE` | Google Play Services unavailable                    | No        | Prompt user to install         |
| `TOO_MANY_REQUESTS`           | Rate limit exceeded                                 | Yes       | Implement exponential backoff  |

### Error Handling Example

```dart
try {
  final isValid = await playIntegrityService.performStandardIntegrityCheck(requestHash);
  if (isValid) {
    await processRequest();
  } else {
    handleIntegrityFailure();
  }
} on IntegrityException catch (e) {
  switch (e.code) {
    case IntegrityErrorCode.networkError:
    case IntegrityErrorCode.tooManyRequests:
      // Retryable errors
      await retryWithBackoff(() => playIntegrityService.performStandardIntegrityCheck(requestHash));
      break;
    case IntegrityErrorCode.appNotInstalled:
      // Development scenario - allow in debug mode
      if (kDebugMode) {
        await processRequest();
      } else {
        showError('App integrity verification failed');
      }
      break;
    default:
      // Non-retryable error
      showError(e.message);
  }
}
```

## Platform Support

| Platform | Support          | Notes                              |
| -------- | ---------------- | ---------------------------------- |
| Android  | ✅ Full          | Requires Android 5.0+ (API 21+)    |
| iOS      | ❌ Not Available | Use Apple's App Attest instead     |
| Desktop  | ⚠️ Mock Only     | Uses `PlayIntegrityRepositoryMock` |
| Web      | ❌ Not Available | N/A                                |

The implementation automatically uses mock repository on non-Android platforms for development and testing.

## Testing

### Unit Testing

The mock repository provides predictable responses for testing:

```dart
import 'package:app/access/play_integrity/play_integrity_repository_mock.dart';
import 'package:app/business/play_integrity/play_integrity_service.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:test/test.dart';

void main() {
  late PlayIntegrityService service;
  late PlayIntegrityRepositoryMock mockRepository;

  setUp(() {
    mockRepository = PlayIntegrityRepositoryMock();
    service = PlayIntegrityService(mockRepository, Logger());
  });

  test('performStandardIntegrityCheck returns true for valid request', () async {
    await service.initialize(123456789012);
    final requestHash = service.computeRequestHash({'test': 'data'});

    final result = await service.performStandardIntegrityCheck(requestHash);

    expect(result, isTrue);
  });

  tearDown(() {
    mockRepository.reset();
  });
}
```

### Integration Testing

For integration tests on Android devices:

1. Configure a test Google Cloud project
2. Add test environment configuration
3. Use real implementation with test credentials
4. Verify actual API responses

```dart
// integration_test/play_integrity_test.dart
testWidgets('Play Integrity API integration test', (tester) async {
  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();

  final service = GetIt.I.get<PlayIntegrityService>();

  // Initialize with test project number
  await service.initialize(int.parse(dotenv.env['TEST_PLAY_INTEGRITY_PROJECT_NUMBER']!));

  // Test standard request
  final requestHash = service.computeRequestHash({'test': 'integration'});
  final isValid = await service.performStandardIntegrityCheck(requestHash);

  expect(isValid, isTrue);
});
```

## Security Best Practices

### 1. Never Decrypt Tokens on Client

**❌ WRONG:**

```dart
// DO NOT DO THIS - INSECURE!
final decryptedVerdict = await repository.decryptIntegrityToken(token, packageName);
```

**✅ CORRECT:**

```dart
// Send token to your backend for server-side decryption
final token = await service.getStandardIntegrityToken(requestHash);
await yourApiClient.sendTokenToBackend(token);
```

### 2. Use Standard Requests for Production

Standard requests provide:

- Better performance through token provider preparation
- Reduced latency for frequent checks
- More efficient API quota usage

```dart
// Initialize once during app startup
await service.initialize(cloudProjectNumber);

// Use standard requests for all integrity checks
final isValid = await service.performStandardIntegrityCheck(requestHash);
```

### 3. Include Contextual Data in Request Hash

Bind the integrity check to specific user actions:

```dart
final requestData = {
  'user_id': currentUserId,
  'action': 'purchase',
  'amount': purchaseAmount,
  'timestamp': DateTime.now().millisecondsSinceEpoch,
  'nonce': generateRandomNonce(), // Additional entropy
};
final requestHash = service.computeRequestHash(requestData);
```

### 4. Implement Rate Limiting

Protect against abuse:

```dart
class RateLimitedIntegrityService {
  static const maxRequestsPerMinute = 5;
  final List<DateTime> _requestTimestamps = [];

  Future<bool> checkIntegrity(String requestHash) async {
    _cleanOldTimestamps();

    if (_requestTimestamps.length >= maxRequestsPerMinute) {
      throw Exception('Rate limit exceeded');
    }

    _requestTimestamps.add(DateTime.now());
    return await playIntegrityService.performStandardIntegrityCheck(requestHash);
  }

  void _cleanOldTimestamps() {
    final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
    _requestTimestamps.removeWhere((timestamp) => timestamp.isBefore(oneMinuteAgo));
  }
}
```

### 5. Handle Errors Gracefully

Don't block users on integrity check failures in all scenarios:

```dart
Future<void> performSensitiveAction() async {
  try {
    final isIntegrityValid = await service.performStandardIntegrityCheck(requestHash);

    if (!isIntegrityValid) {
      // Log for monitoring but consider allowing action with additional verification
      logger.w('Integrity check failed for user action');

      // Implement progressive security (e.g., CAPTCHA, additional auth)
      final passedAdditionalCheck = await showCaptcha();
      if (!passedAdditionalCheck) {
        throw SecurityException('Failed integrity and additional verification');
      }
    }

    await executeAction();
  } on IntegrityException catch (e) {
    // Log error but decide policy based on error type
    logger.e('Integrity check error: ${e.code} - ${e.message}');

    // For network errors, allow action but log for review
    if (e.code == IntegrityErrorCode.networkError) {
      await executeActionWithLogging();
    } else {
      throw e;
    }
  }
}
```

### 6. Monitor and Alert

Implement monitoring for integrity failures:

```dart
class IntegrityMonitoring {
  static void logIntegrityFailure(String requestHash, IntegrityErrorCode? errorCode) {
    // Log to analytics service
    analytics.logEvent('integrity_failure', parameters: {
      'error_code': errorCode?.code.toString() ?? 'unknown',
      'request_hash': requestHash.substring(0, 8), // First 8 chars only
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Alert if failure rate exceeds threshold
    if (_getRecentFailureRate() > 0.1) { // 10% failure rate
      alerting.sendAlert('High integrity failure rate detected');
    }
  }
}
```

## Quota and Limits

- Standard requests: Higher quota, use for production
- Classic requests: Limited quota, use sparingly
- Default quota: 10,000 requests per day (can be increased)
- Rate limits: Managed by Google Play, implement client-side throttling

Monitor your usage in the [Google Cloud Console](https://console.cloud.google.com/apis/api/playintegrity.googleapis.com/quotas).

## Troubleshooting

### "API_NOT_AVAILABLE" Error

**Cause**: Play Integrity API not available on the device

**Solutions**:

- Ensure device has Google Play Services installed
- Verify device runs Android 5.0+ (API 21+)
- Check if device is Play Protect certified
- Use mock repository for testing on non-certified devices

### "APP_NOT_INSTALLED" Error

**Cause**: App not installed from Google Play Store

**Solutions**:

- This is expected during development (sideloaded apps)
- Test on internal testing track in Play Console
- Use debug builds with mock repository
- Production builds must be installed from Play Store

### "PLAY_STORE_VERSION_OUTDATED" Error

**Cause**: Google Play Store app is outdated

**Solutions**:

- Prompt user to update Google Play Store
- Implement fallback verification method
- Allow action to proceed with additional monitoring

### Token Decryption Returns Null

**Cause**: Attempting client-side decryption (not supported)

**Solution**:

```dart
// ❌ This will return null - don't use on client
final verdict = await repository.decryptIntegrityToken(token, packageName);

// ✅ Send token to backend instead
await apiClient.post('/verify-integrity', body: {'token': token});
```

## Additional Resources

- [Play Integrity API Overview](https://developer.android.com/google/play/integrity/overview)
- [Standard Requests Guide](https://developer.android.com/google/play/integrity/standard)
- [Classic Requests Guide](https://developer.android.com/google/play/integrity/classic)
- [Verdict Structure](https://developer.android.com/google/play/integrity/verdicts)
- [Error Codes Reference](https://developer.android.com/google/play/integrity/error-codes)
- [Backend Server Integration](https://developer.android.com/google/play/integrity/setup#token-response)
