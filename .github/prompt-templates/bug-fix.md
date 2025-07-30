# Bug Fix Template

Use this template when debugging and fixing issues in the Flutter application. This template helps ensure systematic debugging and proper resolution following the project's established patterns.

## Bug Information
**Issue Description**: [Describe the bug behavior]
**Expected Behavior**: [What should happen instead]
**Steps to Reproduce**: [List the steps to reproduce the issue]
**Environment**: [Flutter version, device, OS, etc.]
**Error Messages/Stack Traces**: [Include any error messages or stack traces]

## Initial Investigation

### 1. Identify the Layer
Determine which layer of the architecture is affected:
- [ ] **Presentation Layer** - UI issues, ViewModel problems, widget errors
- [ ] **Business Layer** - Service logic errors, data transformation issues
- [ ] **Access Layer** - Repository failures, API errors, persistence issues

### 2. Gather Debug Information
- [ ] Enable detailed logging for the affected component
  ```dart
  // Add temporary debug logs
  _logger.d('Debug: Current state - ${viewModel.currentState}');
  _logger.d('Debug: Input parameters - $parameters');
  ```

- [ ] Check error logs and analytics
  ```dart
  // Review Logger output and Firebase Crashlytics
  // Check Bugsee for user session recordings
  ```

- [ ] Reproduce the issue consistently
  ```dart
  // Create a minimal test case that reproduces the bug
  testWidgets('reproduces the bug', (tester) async {
    // Setup conditions that trigger the bug
    await tester.pumpWidget(TestApp(child: ProblematicWidget()));
    
    // Perform actions that cause the issue
    await tester.tap(find.byKey(Key('trigger-button')));
    await tester.pumpAndSettle();
    
    // Verify the bug occurs
    expect(find.text('Error'), findsOneWidget);
  });
  ```

## Debugging Strategies by Layer

### Presentation Layer Issues

#### ViewModel State Problems
```dart
class DebuggingViewModel extends ViewModel {
  // Add debug properties to track state changes
  String get debugState => get("debugState", "initial");
  
  void debugAction() {
    _logger.d('Before action: debugState=$debugState');
    
    // Your problematic code here
    set("debugState", "updated");
    
    _logger.d('After action: debugState=$debugState');
  }
  
  // Override to track property changes
  @override
  void set<T>(String propertyName, T value) {
    _logger.d('Property changed: $propertyName = $value');
    super.set(propertyName, value);
  }
}
```

#### Widget Lifecycle Issues  
```dart
class DebuggingWidget extends StatefulWidget {
  @override
  _DebuggingWidgetState createState() => _DebuggingWidgetState();
}

class _DebuggingWidgetState extends State<DebuggingWidget> {
  @override
  void initState() {
    super.initState();
    debugPrint('Widget initState called');
  }
  
  @override
  void dispose() {
    debugPrint('Widget dispose called');
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    debugPrint('Widget build called');
    return Container(); // Your widget content
  }
}
```

#### Stream/Async Issues
```dart
// Debug stream subscriptions
StreamSubscription? _debugSubscription;

void _listenToStream() {
  _debugSubscription = dataStream.listen(
    (data) {
      _logger.d('Stream data received: $data');
    },
    onError: (error) {
      _logger.e('Stream error: $error');
    },
    onDone: () {
      _logger.d('Stream completed');
    },
  );
}
```

### Business Layer Issues

#### Service Logic Problems
```dart
abstract interface class DebuggableService {
  // Add debug methods to services
  Map<String, dynamic> getDebugInfo();
  void enableDebugMode(bool enabled);
}

final class _ServiceImpl implements DebuggableService {
  bool _debugMode = false;
  
  @override
  Map<String, dynamic> getDebugInfo() {
    return {
      'debugMode': _debugMode,
      'lastAction': _lastAction,
      'internalState': _internalState,
    };
  }
  
  Future<void> problematicMethod() async {
    if (_debugMode) {
      _logger.d('Starting problematicMethod with state: ${getDebugInfo()}');
    }
    
    try {
      // Your problematic code
      final result = await _repository.getData();
      
      if (_debugMode) {
        _logger.d('Repository returned: $result');
      }
      
    } catch (error, stackTrace) {
      _logger.e('Error in problematicMethod', error, stackTrace);
      
      if (_debugMode) {
        _logger.d('Debug info at error: ${getDebugInfo()}');
      }
      
      rethrow;
    }
  }
}
```

#### Data Transformation Issues
```dart
// Add validation and debugging for data transformations
User transformUserData(UserData data) {
  _logger.d('Transforming UserData: ${data.toJson()}');
  
  // Validate input data
  if (data.id.isEmpty) {
    throw ArgumentError('UserData.id cannot be empty');
  }
  
  try {
    final user = User.fromData(data);
    _logger.d('Transformation successful: ${user.toString()}');
    return user;
  } catch (error) {
    _logger.e('Failed to transform UserData: ${data.toJson()}', error);
    rethrow;
  }
}
```

### Access Layer Issues

#### Repository/API Problems
```dart
class DebuggableRepository {
  final Dio _dio;
  final Logger _logger;
  
  Future<T> _makeRequest<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) parser, {
    Map<String, dynamic>? data,
  }) async {
    _logger.d('API Request: $method $path');
    _logger.d('Request data: $data');
    
    try {
      final response = await _dio.request(
        path,
        options: Options(method: method),
        data: data,
      );
      
      _logger.d('API Response status: ${response.statusCode}');
      _logger.d('API Response data: ${response.data}');
      
      return parser(response.data);
      
    } on DioException catch (error) {
      _logger.e('API Error: ${error.message}');
      _logger.e('Response data: ${error.response?.data}');
      
      // Handle specific error types
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          throw NetworkException('Connection timeout');
        case DioExceptionType.receiveTimeout:
          throw NetworkException('Receive timeout');
        case DioExceptionType.badResponse:
          throw ApiException('Server error: ${error.response?.statusCode}');
        default:
          throw NetworkException('Network error: ${error.message}');
      }
    }
  }
}
```

#### Persistence Issues
```dart
class DebuggablePersistence {
  final SharedPreferences _prefs;
  final Logger _logger;
  
  Future<T?> getData<T>(String key, T Function(String) parser) async {
    try {
      _logger.d('Reading data for key: $key');
      
      final rawData = _prefs.getString(key);
      if (rawData == null) {
        _logger.d('No data found for key: $key');
        return null;
      }
      
      _logger.d('Raw data found: $rawData');
      
      final parsedData = parser(rawData);
      _logger.d('Parsed data: $parsedData');
      
      return parsedData;
      
    } catch (error) {
      _logger.e('Failed to read data for key: $key', error);
      return null;
    }
  }
}
```

## Testing the Fix

### Create Regression Tests
```dart
// Create tests that verify the bug is fixed
group('Bug Fix - [Bug Description]', () {
  test('should handle the problematic scenario correctly', () async {
    // Arrange - Set up the exact conditions that caused the bug
    final service = TestService();
    
    // Act - Perform the action that previously caused the bug
    final result = await service.problematicMethod();
    
    // Assert - Verify the fix works
    expect(result, isNotNull);
    expect(result.isValid, isTrue);
  });
  
  test('should not break existing functionality', () async {
    // Verify that fixing the bug didn't break other features
    final service = TestService();
    
    // Test normal scenarios still work
    final normalResult = await service.normalMethod();
    expect(normalResult, isA<ExpectedType>());
  });
});
```

### Integration Testing
```dart
// Test the fix in a real app scenario
testWidgets('integration test for bug fix', (tester) async {
  await tester.pumpWidget(TestApp());
  
  // Simulate the exact user flow that caused the bug
  await tester.tap(find.byKey(Key('problematic-button')));
  await tester.pumpAndSettle();
  
  // Verify the fix works in the UI
  expect(find.text('Error'), findsNothing);
  expect(find.text('Success'), findsOneWidget);
});
```

## Common Bug Patterns and Solutions

### Memory Leaks
```dart
// Problem: Stream subscriptions not disposed
class ProblematicViewModel extends ViewModel {
  StreamSubscription? _subscription;
  
  void startListening() {
    _subscription = stream.listen(/* handler */);
  }
  
  @override
  void dispose() {
    _subscription?.cancel(); // Fix: Always cancel subscriptions
    super.dispose();
  }
}
```

### Null Safety Issues
```dart
// Problem: Unexpected nulls
String? getValue() => repository.getData()?.value;

// Fix: Proper null handling
String getValue() {
  final data = repository.getData();
  if (data == null) {
    throw StateError('Data not available');
  }
  return data.value ?? 'default_value';
}
```

### Async Race Conditions
```dart
// Problem: Multiple async operations interfering
class ProblematicService {
  Future<void> loadData() async {
    final data1 = await repository.getData1(); // Takes 2 seconds
    final data2 = await repository.getData2(); // Takes 1 second
    // Race condition if called multiple times
  }
  
  // Fix: Use proper state management
  bool _isLoading = false;
  
  Future<void> loadData() async {
    if (_isLoading) return; // Prevent concurrent calls
    
    try {
      _isLoading = true;
      final results = await Future.wait([
        repository.getData1(),
        repository.getData2(),
      ]);
      processResults(results);
    } finally {
      _isLoading = false;
    }
  }
}
```

### Widget State Issues
```dart
// Problem: Widget rebuilt with stale data
class ProblematicWidget extends StatefulWidget {
  @override
  _ProblematicWidgetState createState() => _ProblematicWidgetState();
}

class _ProblematicWidgetState extends State<ProblematicWidget> {
  String? data;
  
  @override
  void initState() {
    super.initState();
    loadData(); // Problem: Not handling async properly
  }
  
  Future<void> loadData() async {
    final result = await repository.getData();
    setState(() {
      data = result; // Fix: Check if widget is still mounted
    });
  }
  
  // Fixed version:
  Future<void> loadDataFixed() async {
    final result = await repository.getData();
    if (mounted) { // Fix: Check mounted state
      setState(() {
        data = result;
      });
    }
  }
}
```

## Performance Issues

### Identifying Performance Problems
```dart
// Use Flutter Inspector and Performance overlay
class PerformanceDebuggingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder( // Problem: Not using builder for large lists
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ExpensiveWidget(items[index]); // Problem: Expensive widgets
      },
    );
  }
}

// Fix: Optimize expensive operations
class OptimizedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return const OptimizedListItem(items[index]); // Use const
      },
    );
  }
}
```

## Fix Implementation Checklist

- [ ] **Root Cause Identified**: Understand why the bug occurred
- [ ] **Minimal Fix**: Make the smallest change possible to fix the issue
- [ ] **Regression Tests**: Add tests to prevent the bug from recurring
- [ ] **Code Review**: Have the fix reviewed by team members
- [ ] **Integration Testing**: Test the fix in the complete application flow
- [ ] **Performance Impact**: Verify the fix doesn't introduce performance issues
- [ ] **Documentation**: Update documentation if the fix changes behavior
- [ ] **Logging**: Add appropriate logging for future debugging

## Post-Fix Validation

### Manual Testing
- [ ] Test the exact scenario that was broken
- [ ] Test related functionality to ensure no regression
- [ ] Test edge cases that might be affected
- [ ] Verify error handling works correctly

### Automated Testing
- [ ] All existing tests still pass
- [ ] New tests for the bug fix pass
- [ ] Integration tests validate the fix works end-to-end

### Monitoring
- [ ] Deploy to staging environment first
- [ ] Monitor error rates and performance metrics
- [ ] Check user feedback and crash reports
- [ ] Validate the fix with real users before full rollout

## Documentation
- [ ] Update relevant code comments
- [ ] Add changelog entry if appropriate
- [ ] Update technical documentation if needed
- [ ] Share learnings with the team to prevent similar issues