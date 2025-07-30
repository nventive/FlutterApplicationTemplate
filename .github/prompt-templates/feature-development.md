# Feature Development Template

Use this template when creating new features in the Flutter application. This template follows the Clean Architecture + MVVM pattern established in the project.

## Context
I need to create a new feature that follows the project's established patterns:
- MVVM architecture with custom ViewModel base class
- Clean Architecture with Access/Business/Presentation layers  
- GetIt dependency injection
- Repository pattern for data access
- RxDart streams for reactive programming

## Feature Requirements
**Feature Name**: [Specify the feature name]
**Description**: [Brief description of what the feature should do]
**User Stories**: [List the user stories this feature addresses]

## Implementation Checklist

### 1. Data Layer (Access)
- [ ] Create data models in `/lib/access/[feature]/data/`
  ```dart
  // Example: user_data.dart
  @JsonSerializable()
  class UserData {
    final String id;
    final String name;
    final String email;
    
    const UserData({
      required this.id,
      required this.name, 
      required this.email,
    });
    
    factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);
    Map<String, dynamic> toJson() => _$UserDataToJson(this);
  }
  ```

- [ ] Create repository interface in `/lib/access/[feature]/`
  ```dart
  // Example: user_repository.dart
  @RestApi(baseUrl: 'https://api.example.com/users')
  abstract interface class UserRepository {
    factory UserRepository(Dio dio, {String baseUrl}) = _UserRepository;
    
    @GET('/')
    Future<List<UserData>> getUsers();
    
    @GET('/{id}')
    Future<UserData> getUser(@Path('id') String id);
    
    @POST('/')
    Future<UserData> createUser(@Body() UserData user);
  }
  ```

- [ ] Create mock repository for testing in `/lib/access/[feature]/mocks/`
  ```dart
  // Example: user_repository_mock.dart
  class MockUserRepository implements UserRepository {
    @override
    Future<List<UserData>> getUsers() async {
      return [
        UserData(id: '1', name: 'John Doe', email: 'john@example.com'),
        UserData(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
      ];
    }
  }
  ```

### 2. Business Layer
- [ ] Create domain model in `/lib/business/[feature]/`
  ```dart
  // Example: user.dart
  class User extends Equatable {
    final String id;
    final String name;
    final String email;
    final bool isOnline;
    
    const User({
      required this.id,
      required this.name,
      required this.email,
      this.isOnline = false,
    });
    
    factory User.fromData(UserData data) => User(
      id: data.id,
      name: data.name,
      email: data.email,
    );
    
    User copyWith({
      String? id,
      String? name, 
      String? email,
      bool? isOnline,
    }) => User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isOnline: isOnline ?? this.isOnline,
    );
    
    @override
    List<Object?> get props => [id, name, email, isOnline];
  }
  ```

- [ ] Create service interface and implementation
  ```dart
  // Example: user_service.dart
  abstract interface class UserService implements Disposable {
    factory UserService(
      UserRepository repository,
      Logger logger,
    ) = _UserService;
    
    Stream<List<User>> get usersStream;
    Future<List<User>> getUsers();
    Future<User> getUser(String id);
    Future<User> createUser(User user);
  }
  
  final class _UserService implements UserService {
    final BehaviorSubject<List<User>> _usersSubject = BehaviorSubject();
    final UserRepository _repository;
    final Logger _logger;
    
    _UserService(UserRepository repository, Logger logger)
        : _repository = repository,
          _logger = logger {
      _loadInitialData();
    }
    
    @override
    Stream<List<User>> get usersStream => _usersSubject.stream;
    
    @override
    Future<List<User>> getUsers() async {
      try {
        _logger.d('Fetching users from repository');
        final userData = await _repository.getUsers();
        final users = userData.map(User.fromData).toList();
        _usersSubject.add(users);
        _logger.i('Successfully loaded ${users.length} users');
        return users;
      } catch (error, stackTrace) {
        _logger.e('Failed to load users', error, stackTrace);
        rethrow;
      }
    }
    
    Future<void> _loadInitialData() async {
      try {
        await getUsers();
      } catch (error) {
        _logger.w('Failed to load initial user data', error);
      }
    }
    
    @override
    FutureOr onDispose() async {
      await _usersSubject.close();
    }
  }
  ```

### 3. Presentation Layer
- [ ] Create ViewModel in `/lib/presentation/[feature]/`
  ```dart
  // Example: user_list_viewmodel.dart
  class UserListViewModel extends ViewModel {
    final _userService = GetIt.I<UserService>();
    final _logger = GetIt.I<Logger>();
    
    Stream<List<User>> get usersStream =>
        getLazy("usersStream", () => _userService.usersStream);
    
    bool get isLoading => get("isLoading", false);
    String? get error => get("error", null);
    
    Future<void> refreshUsers() async {
      try {
        set("isLoading", true);
        set("error", null);
        await _userService.getUsers();
      } catch (error) {
        _logger.e('Failed to refresh users', error);
        set("error", error.toString());
      } finally {
        set("isLoading", false);
      }
    }
    
    Future<void> createUser(String name, String email) async {
      try {
        set("isLoading", true);
        final newUser = User(
          id: '', // Will be assigned by server
          name: name,
          email: email,
        );
        await _userService.createUser(newUser);
        _logger.i('User created successfully');
      } catch (error) {
        _logger.e('Failed to create user', error);
        set("error", error.toString());
      } finally {
        set("isLoading", false);
      }
    }
  }
  ```

- [ ] Create Page widget
  ```dart
  // Example: user_list_page.dart
  final class UserListPage extends MvvmWidget<UserListViewModel> {
    const UserListPage({super.key});
    
    @override
    UserListViewModel getViewModel() => UserListViewModel();
    
    @override
    Widget build(BuildContext context, UserListViewModel viewModel) {
      final local = context.local;
      
      return Scaffold(
        appBar: AppBar(
          title: Text(local.usersPageTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: viewModel.refreshUsers,
            ),
          ],
        ),
        body: StreamBuilder<List<User>>(
          stream: viewModel.usersStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorWidget(
                error: snapshot.error.toString(),
                onRetry: viewModel.refreshUsers,
              );
            }
            
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final users = snapshot.data!;
            
            if (users.isEmpty) {
              return EmptyStateWidget(
                message: local.noUsersFound,
                actionText: local.refresh,
                onAction: viewModel.refreshUsers,
              );
            }
            
            return RefreshIndicator(
              onRefresh: viewModel.refreshUsers,
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return UserListItem(
                    user: user,
                    onTap: () => _navigateToUserDetail(context, user.id),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateUserDialog(context, viewModel),
          child: const Icon(Icons.add),
        ),
      );
    }
    
    void _navigateToUserDetail(BuildContext context, String userId) {
      context.go('/users/$userId');
    }
    
    void _showCreateUserDialog(BuildContext context, UserListViewModel viewModel) {
      // Implementation for create user dialog
    }
  }
  ```

- [ ] Create reusable widgets (if needed)
  ```dart
  // Example: user_list_item.dart
  class UserListItem extends StatelessWidget {
    const UserListItem({
      super.key,
      required this.user,
      this.onTap,
    });
    
    final User user;
    final VoidCallback? onTap;
    
    @override
    Widget build(BuildContext context) {
      return ListTile(
        leading: CircleAvatar(
          child: Text(user.name.substring(0, 1).toUpperCase()),
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: user.isOnline 
          ? const Icon(Icons.circle, color: Colors.green, size: 12)
          : null,
        onTap: onTap,
      );
    }
  }
  ```

### 4. Dependency Registration
- [ ] Register services in GetIt configuration
  ```dart
  // In your DI setup file
  GetIt.I.registerSingleton<UserRepository>(
    UserRepository(GetIt.I<Dio>()),
  );
  
  GetIt.I.registerSingleton<UserService>(
    UserService(
      GetIt.I<UserRepository>(),
      GetIt.I<Logger>(),
    ),
  );
  ```

### 5. Routing
- [ ] Add routes to GoRouter configuration
  ```dart
  // In app_router.dart
  GoRoute(
    path: '/users',
    builder: (context, state) => const UserListPage(),
  ),
  GoRoute(
    path: '/users/:id',
    builder: (context, state) {
      final userId = state.pathParameters['id']!;
      return UserDetailPage(userId: userId);
    },
  ),
  ```

### 6. Localization
- [ ] Add strings to localization files
  ```arb
  // In app_en.arb
  "usersPageTitle": "Users",
  "noUsersFound": "No users found",
  "refresh": "Refresh",
  "createUser": "Create User"
  ```

### 7. Testing
- [ ] Write unit tests for service
- [ ] Write unit tests for ViewModel  
- [ ] Write widget tests for Page
- [ ] Create integration tests if needed

## Testing Implementation

### Service Tests
```dart
// test/business/user_service_test.dart
group('UserService', () {
  late UserService service;
  late MockUserRepository mockRepository;
  late MockLogger mockLogger;

  setUp(() {
    mockRepository = MockUserRepository();
    mockLogger = MockLogger();
    service = UserService(mockRepository, mockLogger);
  });

  tearDown(() {
    service.onDispose();
  });

  test('should load users successfully', () async {
    // Arrange
    final expectedUsers = [
      UserData(id: '1', name: 'John', email: 'john@example.com'),
    ];
    when(mockRepository.getUsers()).thenAnswer((_) async => expectedUsers);

    // Act
    final result = await service.getUsers();

    // Assert
    expect(result, hasLength(1));
    expect(result.first.name, equals('John'));
    verify(mockRepository.getUsers()).called(1);
  });
});
```

### Widget Tests
```dart
// test/presentation/user_list_page_test.dart
testWidgets('UserListPage displays users correctly', (tester) async {
  // Arrange
  await tester.pumpWidget(TestApp(child: UserListPage()));

  // Act
  await tester.pumpAndSettle();

  // Assert
  expect(find.byType(ListView), findsOneWidget);
  expect(find.byType(UserListItem), findsWidgets);
});
```

## Performance Considerations
- Use `const` constructors for widgets
- Implement proper stream disposal
- Use ListView.builder for large lists
- Consider pagination for large datasets
- Cache data appropriately
- Minimize API calls with proper state management

## Common Issues to Avoid
- Forgetting to dispose of streams and subscriptions
- Not handling loading and error states
- Missing null safety checks
- Improper exception handling
- Not following the established naming conventions
- Skipping unit tests for business logic

## Review Checklist
- [ ] Follows MVVM architecture pattern
- [ ] Implements proper error handling
- [ ] Includes loading states
- [ ] Has comprehensive tests
- [ ] Uses proper localization
- [ ] Follows established naming conventions
- [ ] Includes proper documentation
- [ ] Handles edge cases appropriately