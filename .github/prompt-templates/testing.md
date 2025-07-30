# Testing Template

Use this template when writing comprehensive tests for the Flutter application. This template covers unit, widget, and integration testing following the project's established patterns and architecture.

## Testing Context
**Component to Test**: [Specify the class, service, or feature being tested]
**Test Type**: [Unit/Widget/Integration/Performance]
**Test Goals**: [What behavior or functionality to verify]
**Risk Level**: [Critical/High/Medium/Low - based on business impact]

## Test Strategy by Layer

### Access Layer Testing (Repositories & Data)

#### Repository Tests
```dart
// test/access/example_repository_test.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'example_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('ExampleRepository', () {
    late ExampleRepository repository;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      repository = ExampleRepository(mockDio);
    });

    group('getData', () {
      test('should return data when API call succeeds', () async {
        // Arrange
        final expectedResponse = Response<Map<String, dynamic>>(
          data: {'items': [{'id': '1', 'name': 'Test'}]},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );
        
        when(mockDio.get('/data')).thenAnswer((_) async => expectedResponse);

        // Act
        final result = await repository.getData();

        // Assert
        expect(result, isA<DataResponse>());
        expect(result.items, hasLength(1));
        expect(result.items.first.name, equals('Test'));
        verify(mockDio.get('/data')).called(1);
      });

      test('should throw NetworkException when API call fails', () async {
        // Arrange
        when(mockDio.get('/data')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/data'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act & Assert
        expect(
          () => repository.getData(),
          throwsA(isA<NetworkException>()),
        );
        verify(mockDio.get('/data')).called(1);
      });

      test('should handle malformed response data', () async {
        // Arrange
        final malformedResponse = Response<Map<String, dynamic>>(
          data: {'invalid': 'structure'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        );
        
        when(mockDio.get('/data')).thenAnswer((_) async => malformedResponse);

        // Act & Assert
        expect(
          () => repository.getData(),
          throwsA(isA<DataParsingException>()),
        );
      });
    });

    group('createData', () {
      test('should create data successfully', () async {
        // Arrange
        final inputData = CreateDataRequest(name: 'New Item');
        final expectedResponse = Response<Map<String, dynamic>>(
          data: {'id': '123', 'name': 'New Item', 'status': 'created'},
          statusCode: 201,
          requestOptions: RequestOptions(path: '/test'),
        );
        
        when(mockDio.post('/data', data: inputData.toJson()))
            .thenAnswer((_) async => expectedResponse);

        // Act
        final result = await repository.createData(inputData);

        // Assert
        expect(result.id, equals('123'));
        expect(result.name, equals('New Item'));
        expect(result.status, equals('created'));
        verify(mockDio.post('/data', data: inputData.toJson())).called(1);
      });
    });
  });
}
```

#### Data Model Tests
```dart
// test/access/data/user_data_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserData', () {
    group('fromJson', () {
      test('should parse valid JSON correctly', () {
        // Arrange
        final json = {
          'id': '123',
          'name': 'John Doe',
          'email': 'john@example.com',
          'created_at': '2023-01-01T00:00:00Z',
        };

        // Act
        final userData = UserData.fromJson(json);

        // Assert
        expect(userData.id, equals('123'));
        expect(userData.name, equals('John Doe'));
        expect(userData.email, equals('john@example.com'));
        expect(userData.createdAt, isA<DateTime>());
      });

      test('should handle missing optional fields', () {
        // Arrange
        final json = {
          'id': '123',
          'name': 'John Doe',
          'email': 'john@example.com',
          // missing created_at
        };

        // Act
        final userData = UserData.fromJson(json);

        // Assert
        expect(userData.id, equals('123'));
        expect(userData.createdAt, isNull);
      });

      test('should throw when required fields are missing', () {
        // Arrange
        final json = {
          'id': '123',
          // missing required name field
          'email': 'john@example.com',
        };

        // Act & Assert
        expect(
          () => UserData.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final userData = UserData(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
        );

        // Act
        final json = userData.toJson();

        // Assert
        expect(json['id'], equals('123'));
        expect(json['name'], equals('John Doe'));
        expect(json['email'], equals('john@example.com'));
        expect(json['created_at'], equals('2023-01-01T00:00:00.000Z'));
      });
    });
  });
}
```

### Business Layer Testing (Services)

#### Service Tests with Mocking
```dart
// test/business/example_service_test.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import 'example_service_test.mocks.dart';

@GenerateMocks([ExampleRepository, Logger])
void main() {
  group('ExampleService', () {
    late ExampleService service;
    late MockExampleRepository mockRepository;
    late MockLogger mockLogger;

    setUp(() {
      mockRepository = MockExampleRepository();
      mockLogger = MockLogger();
      service = ExampleService(mockRepository, mockLogger);
    });

    tearDown(() async {
      await service.onDispose();
    });

    group('getData', () {
      test('should transform repository data correctly', () async {
        // Arrange
        final repositoryData = ExampleResponseData(
          items: [
            ExampleItemData(id: '1', name: 'Item 1', value: 100),
            ExampleItemData(id: '2', name: 'Item 2', value: 200),
          ],
        );
        
        when(mockRepository.getData()).thenAnswer((_) async => repositoryData);

        // Act
        final result = await service.getData();

        // Assert
        expect(result, hasLength(2));
        expect(result.first.id, equals('1'));
        expect(result.first.displayName, equals('Item 1'));
        expect(result.first.formattedValue, equals('\$100.00'));
        
        verify(mockRepository.getData()).called(1);
        verify(mockLogger.d('Fetching data from repository')).called(1);
        verify(mockLogger.i('Successfully transformed 2 items')).called(1);
      });

      test('should handle empty repository response', () async {
        // Arrange
        final emptyResponse = ExampleResponseData(items: []);
        when(mockRepository.getData()).thenAnswer((_) async => emptyResponse);

        // Act
        final result = await service.getData();

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getData()).called(1);
        verify(mockLogger.i('No items found')).called(1);
      });

      test('should handle repository errors gracefully', () async {
        // Arrange
        final error = NetworkException('Connection failed');
        when(mockRepository.getData()).thenThrow(error);

        // Act & Assert
        expect(
          () => service.getData(),
          throwsA(isA<ServiceException>()),
        );
        
        verify(mockRepository.getData()).called(1);
        verify(mockLogger.e('Failed to fetch data', error)).called(1);
      });
    });

    group('dataStream', () {
      test('should emit data when service loads successfully', () async {
        // Arrange
        final repositoryData = ExampleResponseData(
          items: [ExampleItemData(id: '1', name: 'Test', value: 100)],
        );
        when(mockRepository.getData()).thenAnswer((_) async => repositoryData);

        // Act
        final stream = service.dataStream;
        await service.getData(); // Trigger data load

        // Assert
        await expectLater(
          stream,
          emits(predicate<List<ExampleItem>>((items) => 
            items.length == 1 && items.first.id == '1'
          )),
        );
      });

      test('should handle stream errors', () async {
        // Arrange
        final error = NetworkException('Connection failed');
        when(mockRepository.getData()).thenThrow(error);

        // Act
        final stream = service.dataStream;
        
        // Trigger error by calling getData
        try {
          await service.getData();
        } catch (_) {} // Expect this to throw

        // Assert - Stream should not emit error items
        await expectLater(
          stream.take(1),
          emits(isEmpty), // Should emit empty list initially
        );
      });
    });

    group('createItem', () {
      test('should create item and update stream', () async {
        // Arrange
        final newItem = ExampleItem(
          id: '',
          displayName: 'New Item',
          formattedValue: '\$50.00',
        );
        
        final createdItemData = ExampleItemData(
          id: '123',
          name: 'New Item',
          value: 50,
        );
        
        when(mockRepository.createItem(any))
            .thenAnswer((_) async => createdItemData);

        // Setup initial data
        when(mockRepository.getData()).thenAnswer((_) async => 
          ExampleResponseData(items: [createdItemData])
        );

        // Act
        final result = await service.createItem(newItem);

        // Assert
        expect(result.id, equals('123'));
        verify(mockRepository.createItem(any)).called(1);
        verify(mockLogger.i('Item created successfully: 123')).called(1);
        
        // Verify stream is updated
        await expectLater(
          service.dataStream.take(1),
          emits(predicate<List<ExampleItem>>((items) => 
            items.any((item) => item.id == '123')
          )),
        );
      });
    });
  });
}
```

### Presentation Layer Testing (ViewModels & Widgets)

#### ViewModel Tests
```dart
// test/presentation/example_viewmodel_test.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'example_viewmodel_test.mocks.dart';

@GenerateMocks([ExampleService])
void main() {
  group('ExampleViewModel', () {
    late ExampleViewModel viewModel;
    late MockExampleService mockService;

    setUp(() {
      mockService = MockExampleService();
      
      // Setup GetIt for dependency injection
      GetIt.I.reset();
      GetIt.I.registerSingleton<ExampleService>(mockService);
      
      viewModel = ExampleViewModel();
    });

    tearDown(() {
      viewModel.dispose();
      GetIt.I.reset();
    });

    group('initialization', () {
      test('should initialize with default values', () {
        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, isNull);
      });

      test('should setup stream subscription', () {
        // Arrange
        final testData = [
          ExampleItem(id: '1', displayName: 'Test', formattedValue: '\$100'),
        ];
        
        when(mockService.dataStream)
            .thenAnswer((_) => Stream.value(testData));

        // Act
        final stream = viewModel.dataStream;

        // Assert
        expect(stream, emits(testData));
        verify(mockService.dataStream).called(1);
      });
    });

    group('refreshData', () {
      test('should update loading state during refresh', () async {
        // Arrange
        when(mockService.getData()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = viewModel.refreshData();

        // Assert - Should be loading during operation
        expect(viewModel.isLoading, isTrue);
        expect(viewModel.error, isNull);

        await future;

        // Assert - Should not be loading after completion
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, isNull);
      });

      test('should handle service errors correctly', () async {
        // Arrange
        final error = ServiceException('Service failed');
        when(mockService.getData()).thenThrow(error);

        // Act
        await viewModel.refreshData();

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, equals('Service failed'));
        verify(mockService.getData()).called(1);
      });

      test('should clear previous errors on successful refresh', () async {
        // Arrange - First set an error state
        when(mockService.getData()).thenThrow(ServiceException('First error'));
        await viewModel.refreshData();
        expect(viewModel.error, isNotNull);

        // Act - Now succeed
        when(mockService.getData()).thenAnswer((_) async => []);
        await viewModel.refreshData();

        // Assert
        expect(viewModel.error, isNull);
        expect(viewModel.isLoading, isFalse);
      });
    });

    group('createItem', () {
      test('should create item successfully', () async {
        // Arrange
        final newItem = ExampleItem(
          id: '',
          displayName: 'New Item',
          formattedValue: '\$75.00',
        );
        
        final createdItem = ExampleItem(
          id: '123',
          displayName: 'New Item',
          formattedValue: '\$75.00',
        );

        when(mockService.createItem(newItem))
            .thenAnswer((_) async => createdItem);

        // Act
        await viewModel.createItem('New Item', 75.0);

        // Assert
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, isNull);
        verify(mockService.createItem(any)).called(1);
      });

      test('should validate input parameters', () async {
        // Act & Assert
        expect(
          () => viewModel.createItem('', 75.0),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => viewModel.createItem('Valid Name', -10.0),
          throwsA(isA<ArgumentError>()),
        );

        verifyNever(mockService.createItem(any));
      });
    });

    group('property change notifications', () {
      test('should notify listeners when loading state changes', () {
        // Arrange
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        when(mockService.getData()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 50));
          return [];
        });

        // Act
        viewModel.refreshData();

        // Assert - Should notify when loading starts
        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners when error state changes', () async {
        // Arrange
        var notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        when(mockService.getData()).thenThrow(ServiceException('Error'));

        // Act
        await viewModel.refreshData();

        // Assert
        expect(notificationCount, greaterThan(0));
        expect(viewModel.error, equals('Error'));
      });
    });
  });
}
```

#### Widget Tests
```dart
// test/presentation/example_page_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';

import '../test_app.dart';
import 'example_page_test.mocks.dart';

@GenerateMocks([ExampleService])
void main() {
  group('ExamplePage Widget Tests', () {
    late MockExampleService mockService;

    setUp(() {
      mockService = MockExampleService();
      GetIt.I.reset();
      GetIt.I.registerSingleton<ExampleService>(mockService);
    });

    tearDown(() {
      GetIt.I.reset();
    });

    testWidgets('should display loading indicator initially', (tester) async {
      // Arrange
      when(mockService.dataStream)
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(TestApp(child: ExamplePage()));
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display data when loaded', (tester) async {
      // Arrange
      final testData = [
        ExampleItem(id: '1', displayName: 'Test Item 1', formattedValue: '\$100'),
        ExampleItem(id: '2', displayName: 'Test Item 2', formattedValue: '\$200'),
      ];

      when(mockService.dataStream)
          .thenAnswer((_) => Stream.value(testData));

      // Act
      await tester.pumpWidget(TestApp(child: ExamplePage()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Test Item 1'), findsOneWidget);
      expect(find.text('Test Item 2'), findsOneWidget);
      expect(find.text('\$100'), findsOneWidget);
      expect(find.text('\$200'), findsOneWidget);
    });

    testWidgets('should display error message on error', (tester) async {
      // Arrange
      when(mockService.dataStream)
          .thenAnswer((_) => Stream.error(ServiceException('Network error')));

      // Act
      await tester.pumpWidget(TestApp(child: ExamplePage()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Network error'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget); // Retry button
    });

    testWidgets('should display empty state when no data', (tester) async {
      // Arrange
      when(mockService.dataStream)
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(TestApp(child: ExamplePage()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No items found'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('should handle refresh action', (tester) async {
      // Arrange
      when(mockService.dataStream)
          .thenAnswer((_) => Stream.value([]));
      when(mockService.getData())
          .thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(TestApp(child: ExamplePage()));
      await tester.pumpAndSettle();

      // Find and tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Assert
      verify(mockService.getData()).called(1);
    });

    testWidgets('should navigate to detail page when item tapped', (tester) async {
      // Arrange
      final testData = [
        ExampleItem(id: '1', displayName: 'Test Item', formattedValue: '\$100'),
      ];

      when(mockService.dataStream)
          .thenAnswer((_) => Stream.value(testData));

      // Act
      await tester.pumpWidget(TestApp(child: ExamplePage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // Assert - Check navigation occurred
      // This depends on your routing setup
      expect(find.text('Detail Page'), findsOneWidget);
    });

    testWidgets('should show create dialog when FAB tapped', (tester) async {
      // Arrange
      when(mockService.dataStream)
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(TestApp(child: ExamplePage()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Create New Item'), findsOneWidget);
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantic labels', (tester) async {
        // Arrange
        final testData = [
          ExampleItem(id: '1', displayName: 'Test Item', formattedValue: '\$100'),
        ];

        when(mockService.dataStream)
            .thenAnswer((_) => Stream.value(testData));

        // Act
        await tester.pumpWidget(TestApp(child: ExamplePage()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.bySemanticsLabel('Items list'), findsOneWidget);
        expect(find.bySemanticsLabel('Refresh items'), findsOneWidget);
        expect(find.bySemanticsLabel('Add new item'), findsOneWidget);
      });

      testWidgets('should support screen reader navigation', (tester) async {
        // Test semantic traversal order and labels
        final testData = [
          ExampleItem(id: '1', displayName: 'Item 1', formattedValue: '\$100'),
          ExampleItem(id: '2', displayName: 'Item 2', formattedValue: '\$200'),
        ];

        when(mockService.dataStream)
            .thenAnswer((_) => Stream.value(testData));

        await tester.pumpWidget(TestApp(child: ExamplePage()));
        await tester.pumpAndSettle();

        final semantics = tester.getSemantics(find.byType(Scaffold));
        expect(semantics, hasA11yFocus());
      });
    });
  });
}
```

#### Custom Widget Component Tests
```dart
// test/presentation/components/example_list_item_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('ExampleListItem', () {
    testWidgets('should display item information correctly', (tester) async {
      // Arrange
      final item = ExampleItem(
        id: '1',
        displayName: 'Test Item',
        formattedValue: '\$100.00',
      );

      bool tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExampleListItem(
              item: item,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('\$100.00'), findsOneWidget);

      // Test interaction
      await tester.tap(find.byType(ExampleListItem));
      expect(tapped, isTrue);
    });

    testWidgets('should handle long text gracefully', (tester) async {
      // Arrange
      final item = ExampleItem(
        id: '1',
        displayName: 'Very Long Item Name That Should Be Truncated',
        formattedValue: '\$1,000,000.00',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Constrained width
              child: ExampleListItem(item: item),
            ),
          ),
        ),
      );

      // Assert - Text should be truncated with ellipsis
      final textWidget = tester.widget<Text>(find.text(contains('Very Long')));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should apply correct theme styles', (tester) async {
      // Arrange
      final item = ExampleItem(
        id: '1',
        displayName: 'Test Item',
        formattedValue: '\$100.00',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ExampleListItem(item: item),
          ),
        ),
      );

      // Assert theme application
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.textColor, isNotNull);
    });
  });
}
```

### Integration Testing

#### Full Feature Integration Tests
```dart
// integration_test/example_feature_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Example Feature Integration', () {
    testWidgets('complete user workflow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to example feature
      await tester.tap(find.text('Examples'));
      await tester.pumpAndSettle();

      // Wait for data to load
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify initial state
      expect(find.byType(ListView), findsOneWidget);

      // Test create functionality
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill create form
      await tester.enterText(find.byKey(Key('name_field')), 'Integration Test Item');
      await tester.enterText(find.byKey(Key('value_field')), '150.00');

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify item was created
      expect(find.text('Integration Test Item'), findsOneWidget);

      // Test item interaction
      await tester.tap(find.text('Integration Test Item'));
      await tester.pumpAndSettle();

      // Verify navigation to detail page
      expect(find.text('Item Details'), findsOneWidget);
      expect(find.text('Integration Test Item'), findsOneWidget);

      // Test back navigation
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify back on list page
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('error handling integration', (tester) async {
      // This test would require network mocking or test environment setup
      // to simulate error conditions

      app.main();
      await tester.pumpAndSettle();

      // Simulate network error scenario
      // Implementation depends on your mocking strategy

      // Verify error handling UI
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Test retry functionality
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
    });
  });
}
```

## Testing Utilities and Helpers

### Test App Wrapper
```dart
// test/test_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app/l10n/gen_l10n/app_localizations.dart';

class TestApp extends StatelessWidget {
  final Widget child;
  final ThemeData? theme;

  const TestApp({
    super.key,
    required this.child,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}
```

### Mock Data Factories
```dart
// test/factories/example_factory.dart
class ExampleFactory {
  static ExampleItem createItem({
    String? id,
    String? displayName,
    String? formattedValue,
  }) {
    return ExampleItem(
      id: id ?? 'test_id',
      displayName: displayName ?? 'Test Item',
      formattedValue: formattedValue ?? '\$100.00',
    );
  }

  static List<ExampleItem> createItems(int count) {
    return List.generate(count, (index) =>
      createItem(
        id: 'item_$index',
        displayName: 'Test Item $index',
        formattedValue: '\$${(index + 1) * 100}.00',
      ),
    );
  }

  static ExampleItemData createItemData({
    String? id,
    String? name,
    double? value,
  }) {
    return ExampleItemData(
      id: id ?? 'test_id',
      name: name ?? 'Test Item',
      value: value ?? 100.0,
    );
  }
}
```

### Custom Matchers
```dart
// test/matchers/custom_matchers.dart
import 'package:flutter_test/flutter_test.dart';

Matcher hasA11yFocus() => _HasA11yFocus();

class _HasA11yFocus extends Matcher {
  @override
  bool matches(Object? item, Map matchState) {
    // Implementation for checking accessibility focus
    return true; // Simplified
  }

  @override
  Description describe(Description description) {
    return description.add('has accessibility focus');
  }
}

Matcher hasValidationError(String expectedError) => 
    _HasValidationError(expectedError);

class _HasValidationError extends Matcher {
  final String expectedError;
  
  _HasValidationError(this.expectedError);

  @override
  bool matches(Object? item, Map matchState) {
    // Check for validation error in form fields
    return true; // Simplified
  }

  @override
  Description describe(Description description) {
    return description.add('has validation error: $expectedError');
  }
}
```

## Performance Testing

### Performance Benchmarks
```dart
// test/performance/widget_performance_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('list scrolling performance', (tester) async {
      // Create large dataset
      final items = ExampleFactory.createItems(1000);

      await tester.pumpWidget(
        TestApp(
          child: ExampleList(items: items),
        ),
      );

      await tester.pumpAndSettle();

      // Measure scroll performance
      final stopwatch = Stopwatch()..start();

      await tester.fling(find.byType(ListView), Offset(0, -500), 1000);
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Assert performance criteria
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    testWidgets('memory usage test', (tester) async {
      // Test for memory leaks during widget lifecycle
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(TestApp(child: ExamplePage()));
        await tester.pumpAndSettle();
        
        await tester.pumpWidget(Container()); // Dispose widget
        await tester.pumpAndSettle();
      }

      // Verify no memory leaks (implementation depends on your measurement strategy)
    });
  });
}
```

## Test Configuration and Setup

### Test Configuration Files
```dart
// test/test_config.dart
class TestConfig {
  static void setupTests() {
    // Global test setup
    setUpAll(() {
      // Initialize test environment
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    tearDownAll(() {
      // Global cleanup
    });
  }

  static void setupMockServices() {
    // Setup mock services for all tests
    GetIt.I.reset();
    GetIt.I.allowReassignment = true;
    
    // Register mock services
    GetIt.I.registerSingleton<Logger>(MockLogger());
  }
}
```

## Testing Checklist

### Unit Tests
- [ ] **Service layer logic** is thoroughly tested
- [ ] **Error handling** scenarios are covered
- [ ] **Edge cases** are tested (empty data, null values, etc.)
- [ ] **Async operations** are properly tested
- [ ] **Stream behavior** is verified
- [ ] **Dependency injection** is mocked correctly

### Widget Tests
- [ ] **Widget rendering** is tested for different states
- [ ] **User interactions** (taps, scrolls, text input) are tested
- [ ] **Navigation** behavior is verified
- [ ] **Error states** are properly displayed
- [ ] **Loading states** are shown correctly
- [ ] **Accessibility** features are tested

### Integration Tests
- [ ] **Complete user workflows** are tested end-to-end
- [ ] **Cross-layer interactions** work correctly
- [ ] **Real API calls** work in test environment (if applicable)
- [ ] **Data persistence** is verified
- [ ] **Performance** meets acceptable criteria

### Test Quality
- [ ] **Test coverage** meets minimum requirements (aim for 80%+)
- [ ] **Tests are fast** and run quickly in CI/CD
- [ ] **Tests are reliable** and don't flake
- [ ] **Tests are maintainable** and easy to update
- [ ] **Test data** is consistent and realistic
- [ ] **Mocks are accurate** and reflect real behavior

## Common Testing Anti-Patterns to Avoid

1. **Testing Implementation Details** - Test behavior, not internal structure
2. **Overly Complex Test Setup** - Keep test setup simple and focused
3. **Brittle Tests** - Don't depend on specific UI element positions or timing
4. **Missing Edge Cases** - Test boundary conditions and error scenarios
5. **Slow Tests** - Optimize for fast feedback loops
6. **Inconsistent Test Data** - Use factories and consistent test data
7. **Missing Integration Tests** - Don't rely only on unit tests

## CI/CD Integration

### GitHub Actions Test Configuration
```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.4.0'
      
      - name: Install dependencies
        run: flutter pub get
        working-directory: src/app
      
      - name: Run unit tests
        run: flutter test --coverage
        working-directory: src/app
      
      - name: Run integration tests
        run: flutter test integration_test/
        working-directory: src/app
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: src/app/coverage/lcov.info
```