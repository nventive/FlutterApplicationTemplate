import 'package:app/access/play_integrity/data/integrity_error_code.dart';
import 'package:app/access/play_integrity/play_integrity_repository_mock.dart';
import 'package:app/business/play_integrity/play_integrity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

void main() {
  late PlayIntegrityRepositoryMock mockRepository;
  late PlayIntegrityService SUT;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockRepository = PlayIntegrityRepositoryMock();
    SUT = PlayIntegrityService(mockRepository, Logger());
  });

  tearDown(() {
    mockRepository.reset();
  });

  group('initialization', () {
    test('initialize completes successfully', () async {
      // Arrange
      const cloudProjectNumber = 123456789012;

      // Act
      await SUT.initialize(cloudProjectNumber);

      // Assert - Should not throw
      expect(true, isTrue);
    });

    test('initialize can be called multiple times', () async {
      // Arrange
      const cloudProjectNumber = 123456789012;

      // Act
      await SUT.initialize(cloudProjectNumber);
      await SUT.initialize(cloudProjectNumber);

      // Assert - Should not throw
      expect(true, isTrue);
    });
  });

  group('standard integrity checks', () {
    test('performStandardIntegrityCheck returns true for valid request',
        () async {
      // Arrange
      await SUT.initialize(123456789012);
      final requestData = {'test': 'data'};

      // Act
      final result = await SUT.performStandardIntegrityCheck(requestData);

      // Assert
      expect(result, isTrue);
    });

    test('performStandardIntegrityCheck throws when not initialized', () async {
      // Arrange
      final requestData = {'test': 'data'};

      // Act & Assert
      expect(
        () => SUT.performStandardIntegrityCheck(requestData),
        throwsA(isA<IntegrityException>()),
      );
    });

    test('getStandardIntegrityToken returns token string', () async {
      // Arrange
      await SUT.initialize(123456789012);
      final requestData = {'test': 'data'};

      // Act
      final token = await SUT.getStandardIntegrityToken(requestData);

      // Assert
      expect(token, isNotNull);
      expect(token, isNotEmpty);
      expect(token, startsWith('mock_standard_integrity_token_'));
    });

    test('multiple standard requests succeed', () async {
      // Arrange
      await SUT.initialize(123456789012);

      // Act & Assert - Multiple requests
      for (var i = 0; i < 5; i++) {
        final requestData = {
          'request_number': i,
          'timestamp': DateTime.now().millisecondsSinceEpoch
        };
        final isValid = await SUT.performStandardIntegrityCheck(requestData);
        expect(isValid, isTrue);
      }
    });
  });

  group('classic integrity checks', () {
    test('performClassicIntegrityCheck returns true for valid request',
        () async {
      // Act
      final result = await SUT.performClassicIntegrityCheck();

      // Assert
      expect(result, isTrue);
    });

    test('getClassicIntegrityToken returns token string', () async {
      // Act
      final token = await SUT.getClassicIntegrityToken();

      // Assert
      expect(token, isNotNull);
      expect(token, isNotEmpty);
      expect(token, startsWith('mock_classic_integrity_token_'));
    });

    test('multiple classic requests succeed', () async {
      // Act & Assert - Multiple requests
      for (var i = 0; i < 5; i++) {
        final isValid = await SUT.performClassicIntegrityCheck();
        expect(isValid, isTrue);
      }
    });
  });

  group('nonce generation', () {
    test('generateNonce returns non-empty string', () {
      // Act
      final nonce = SUT.generateNonce();

      // Assert
      expect(nonce, isNotEmpty);
    });

    test('generateNonce returns base64 encoded string', () {
      // Act
      final nonce = SUT.generateNonce();

      // Assert
      // Base64 strings only contain A-Z, a-z, 0-9, +, /, and = for padding
      final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+=*$');
      expect(base64Pattern.hasMatch(nonce), isTrue);
    });

    test('generateNonce returns different values on each call', () {
      // Act
      final nonce1 = SUT.generateNonce();
      final nonce2 = SUT.generateNonce();
      final nonce3 = SUT.generateNonce();

      // Assert
      expect(nonce1, isNot(equals(nonce2)));
      expect(nonce2, isNot(equals(nonce3)));
      expect(nonce1, isNot(equals(nonce3)));
    });

    test('generateNonce produces sufficient entropy', () {
      // Act
      final nonce = SUT.generateNonce();

      // Assert
      // Should be at least 16 bytes (128 bits) base64 encoded = ~22 chars minimum
      expect(nonce.length, greaterThanOrEqualTo(22));
    });
  });

  group('request hash computation', () {
    test('computeRequestHash returns non-empty string', () {
      // Arrange
      final requestData = {'test': 'data'};

      // Act
      final hash = SUT.computeRequestHash(requestData);

      // Assert
      expect(hash, isNotEmpty);
    });

    test('computeRequestHash returns consistent hash for same data', () {
      // Arrange
      final requestData = {'user': 'test', 'action': 'purchase'};

      // Act
      final hash1 = SUT.computeRequestHash(requestData);
      final hash2 = SUT.computeRequestHash(requestData);

      // Assert
      expect(hash1, equals(hash2));
    });

    test('computeRequestHash returns different hashes for different data', () {
      // Arrange
      final requestData1 = {'user': 'test1', 'action': 'purchase'};
      final requestData2 = {'user': 'test2', 'action': 'purchase'};

      // Act
      final hash1 = SUT.computeRequestHash(requestData1);
      final hash2 = SUT.computeRequestHash(requestData2);

      // Assert
      expect(hash1, isNot(equals(hash2)));
    });

    test('computeRequestHash handles complex nested data', () {
      // Arrange
      final requestData = {
        'user': {
          'id': 123,
          'email': 'test@example.com',
        },
        'items': [
          {'id': 1, 'quantity': 2},
          {'id': 2, 'quantity': 1},
        ],
        'timestamp': 1234567890,
      };

      // Act
      final hash = SUT.computeRequestHash(requestData);

      // Assert
      expect(hash, isNotEmpty);
      expect(hash.length, equals(64)); // SHA-256 produces 64 hex characters
    });

    test('computeRequestHash returns hex string', () {
      // Arrange
      final requestData = {'test': 'data'};

      // Act
      final hash = SUT.computeRequestHash(requestData);

      // Assert
      // Hex string should only contain 0-9 and a-f
      final hexPattern = RegExp(r'^[0-9a-f]+$');
      expect(hexPattern.hasMatch(hash), isTrue);
    });

    test('computeRequestHash produces SHA-256 length hash', () {
      // Arrange
      final requestData = {'test': 'data'};

      // Act
      final hash = SUT.computeRequestHash(requestData);

      // Assert
      // SHA-256 produces 32 bytes = 64 hex characters
      expect(hash.length, equals(64));
    });
  });

  group('isAvailable', () {
    test('returns true when Play Integrity is available', () async {
      // Act
      final isAvailable = await SUT.isAvailable();

      // Assert
      expect(isAvailable, isTrue);
    });
  });

  group('integration scenarios', () {
    test('full standard integrity flow succeeds', () async {
      // Arrange
      await SUT.initialize(123456789012);

      final requestData = {
        'user_id': 'user123',
        'action': 'purchase',
        'amount': 9.99,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Act - Get token
      final token = await SUT.getStandardIntegrityToken(requestData);

      // Assert - Token should be valid
      expect(token, isNotNull);
      expect(token, isNotEmpty);

      // Act - Verify integrity
      final isValid = await SUT.performStandardIntegrityCheck(requestData);

      // Assert
      expect(isValid, isTrue);
    });

    test('full classic integrity flow succeeds', () async {
      // Act - Get token
      final token = await SUT.getClassicIntegrityToken();

      // Assert - Token should be valid
      expect(token, isNotNull);
      expect(token, isNotEmpty);

      // Act - Verify integrity
      final isValid = await SUT.performClassicIntegrityCheck();

      // Assert
      expect(isValid, isTrue);
    });

    test('repository reset clears state', () async {
      // Arrange
      await SUT.initialize(123456789012);

      // Act
      mockRepository.reset();

      // Assert - Next standard request should fail without re-initialization
      final requestData = {'test': 'data'};
      expect(
        () => SUT.performStandardIntegrityCheck(requestData),
        throwsA(isA<IntegrityException>()),
      );
    });
  });

  group('edge cases', () {
    test('computeRequestHash handles empty map', () {
      // Arrange
      final emptyData = <String, dynamic>{};

      // Act
      final hash = SUT.computeRequestHash(emptyData);

      // Assert
      expect(hash, isNotEmpty);
      expect(hash.length, equals(64));
    });

    test('computeRequestHash handles null values', () {
      // Arrange
      final dataWithNull = {
        'key1': 'value1',
        'key2': null,
        'key3': 'value3',
      };

      // Act
      final hash = SUT.computeRequestHash(dataWithNull);

      // Assert
      expect(hash, isNotEmpty);
      expect(hash.length, equals(64));
    });

    test('computeRequestHash handles list values', () {
      // Arrange
      final dataWithList = {
        'items': [1, 2, 3, 4, 5],
        'tags': ['tag1', 'tag2', 'tag3'],
      };

      // Act
      final hash = SUT.computeRequestHash(dataWithList);

      // Assert
      expect(hash, isNotEmpty);
      expect(hash.length, equals(64));
    });

    test('computeRequestHash handles boolean values', () {
      // Arrange
      final dataWithBools = {
        'is_premium': true,
        'is_trial': false,
        'has_subscription': true,
      };

      // Act
      final hash = SUT.computeRequestHash(dataWithBools);

      // Assert
      expect(hash, isNotEmpty);
      expect(hash.length, equals(64));
    });
  });
}
