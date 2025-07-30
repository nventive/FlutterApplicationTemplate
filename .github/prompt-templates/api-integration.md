# API Integration Template

Use this template when integrating with APIs in the Flutter application. This template follows the project's Repository pattern with Retrofit/Dio and includes proper error handling, caching, and testing strategies.

## API Integration Context
**API Name**: [Specify the API or service name]
**Base URL**: [API base URL]
**Authentication**: [API key, OAuth, JWT, etc.]
**Data Format**: [JSON, XML, etc.]
**Rate Limits**: [Any rate limiting considerations]

## Integration Architecture

The project follows this pattern for API integration:
```
Presentation Layer (ViewModel)
↓
Business Layer (Service)
↓
Access Layer (Repository - Retrofit)
↓
Network Layer (Dio HTTP Client)
```

## Implementation Steps

### 1. Data Models

#### Response Data Models
```dart
// lib/access/[feature]/data/[model]_response_data.dart
import 'package:json_annotation/json_annotation.dart';

part '[model]_response_data.g.dart';

@JsonSerializable()
class UserResponseData {
  @JsonKey(name: 'id')
  final String id;
  
  @JsonKey(name: 'first_name')
  final String firstName;
  
  @JsonKey(name: 'last_name')
  final String lastName;
  
  @JsonKey(name: 'email')
  final String email;
  
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'is_active')
  final bool isActive;

  const UserResponseData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
    required this.isActive,
  });

  factory UserResponseData.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseDataToJson(this);
}

// For paginated responses
@JsonSerializable()
class PaginatedResponse<T> {
  @JsonKey(name: 'data')
  final List<T> data;
  
  @JsonKey(name: 'meta')
  final PaginationMeta meta;

  const PaginatedResponse({
    required this.data,
    required this.meta,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}

@JsonSerializable()
class PaginationMeta {
  @JsonKey(name: 'page')
  final int page;
  
  @JsonKey(name: 'per_page')
  final int perPage;
  
  @JsonKey(name: 'total')
  final int total;
  
  @JsonKey(name: 'total_pages')
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}
```

#### Request Data Models
```dart
// lib/access/[feature]/data/[model]_request_data.dart
import 'package:json_annotation/json_annotation.dart';

part '[model]_request_data.g.dart';

@JsonSerializable()
class CreateUserRequestData {
  @JsonKey(name: 'first_name')
  final String firstName;
  
  @JsonKey(name: 'last_name')
  final String lastName;
  
  @JsonKey(name: 'email')
  final String email;
  
  @JsonKey(name: 'password')
  final String password;

  const CreateUserRequestData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  factory CreateUserRequestData.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestDataFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUserRequestDataToJson(this);
}

@JsonSerializable()
class UpdateUserRequestData {
  @JsonKey(name: 'first_name')
  final String? firstName;
  
  @JsonKey(name: 'last_name')
  final String? lastName;
  
  @JsonKey(name: 'email')
  final String? email;

  const UpdateUserRequestData({
    this.firstName,
    this.lastName,
    this.email,
  });

  factory UpdateUserRequestData.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestDataFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserRequestDataToJson(this);
}
```

### 2. Repository Interface & Implementation

#### Repository Interface
```dart
// lib/access/[feature]/[feature]_repository.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:app/access/[feature]/data/user_response_data.dart';
import 'package:app/access/[feature]/data/create_user_request_data.dart';
import 'package:app/access/[feature]/data/update_user_request_data.dart';

part '[feature]_repository.g.dart';

@RestApi(baseUrl: 'https://api.example.com/v1')
abstract interface class UserRepository {
  factory UserRepository(Dio dio, {String baseUrl}) = _UserRepository;

  // GET requests
  @GET('/users')
  Future<PaginatedResponse<UserResponseData>> getUsers({
    @Query('page') int page = 1,
    @Query('per_page') int perPage = 20,
    @Query('search') String? search,
    @Query('sort_by') String? sortBy,
    @Query('sort_order') String? sortOrder,
  });

  @GET('/users/{id}')
  Future<UserResponseData> getUser(@Path('id') String id);

  // POST requests
  @POST('/users')
  Future<UserResponseData> createUser(@Body() CreateUserRequestData user);

  // PUT requests
  @PUT('/users/{id}')
  Future<UserResponseData> updateUser(
    @Path('id') String id,
    @Body() UpdateUserRequestData user,
  );

  // DELETE requests
  @DELETE('/users/{id}')
  Future<void> deleteUser(@Path('id') String id);

  // File upload
  @POST('/users/{id}/avatar')
  @MultiPart()
  Future<UserResponseData> uploadAvatar(
    @Path('id') String id,
    @Part(name: 'avatar') MultipartFile avatar,
  );

  // Custom headers
  @GET('/users/me')
  Future<UserResponseData> getCurrentUser(
    @Header('Authorization') String authorization,
  );
}
```

#### Repository Mock for Testing
```dart
// lib/access/[feature]/mocks/[feature]_repository_mock.dart
import 'package:app/access/[feature]/[feature]_repository.dart';
import 'package:app/access/[feature]/data/user_response_data.dart';

class MockUserRepository implements UserRepository {
  static final List<UserResponseData> _mockUsers = [
    UserResponseData(
      id: '1',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      avatarUrl: 'https://example.com/avatars/1.jpg',
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      isActive: true,
    ),
    UserResponseData(
      id: '2',
      firstName: 'Jane',
      lastName: 'Smith',
      email: 'jane.smith@example.com',
      avatarUrl: null,
      createdAt: DateTime.now().subtract(Duration(days: 15)),
      isActive: true,
    ),
  ];

  @override
  Future<PaginatedResponse<UserResponseData>> getUsers({
    int page = 1,
    int perPage = 20,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    var filteredUsers = List<UserResponseData>.from(_mockUsers);

    // Apply search filter
    if (search != null && search.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) =>
        user.firstName.toLowerCase().contains(search.toLowerCase()) ||
        user.lastName.toLowerCase().contains(search.toLowerCase()) ||
        user.email.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }

    // Apply sorting
    if (sortBy != null) {
      filteredUsers.sort((a, b) {
        int comparison = 0;
        switch (sortBy) {
          case 'first_name':
            comparison = a.firstName.compareTo(b.firstName);
            break;
          case 'last_name':
            comparison = a.lastName.compareTo(b.lastName);
            break;
          case 'email':
            comparison = a.email.compareTo(b.email);
            break;
          case 'created_at':
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
        }
        return sortOrder == 'desc' ? -comparison : comparison;
      });
    }

    // Apply pagination
    final startIndex = (page - 1) * perPage;
    final endIndex = (startIndex + perPage).clamp(startIndex, filteredUsers.length);
    final paginatedUsers = filteredUsers.sublist(startIndex, endIndex);

    return PaginatedResponse(
      data: paginatedUsers,
      meta: PaginationMeta(
        page: page,
        perPage: perPage,
        total: filteredUsers.length,
        totalPages: (filteredUsers.length / perPage).ceil(),
      ),
    );
  }

  @override
  Future<UserResponseData> getUser(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final user = _mockUsers.firstWhere(
      (user) => user.id == id,
      orElse: () => throw NotFoundException('User not found'),
    );
    
    return user;
  }

  @override
  Future<UserResponseData> createUser(CreateUserRequestData userData) async {
    await Future.delayed(Duration(milliseconds: 800));

    final newUser = UserResponseData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: userData.firstName,
      lastName: userData.lastName,
      email: userData.email,
      avatarUrl: null,
      createdAt: DateTime.now(),
      isActive: true,
    );

    _mockUsers.add(newUser);
    return newUser;
  }

  // Implement other methods...
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
}
```

### 3. Error Handling

#### Custom Exception Classes
```dart
// lib/access/exceptions/api_exceptions.dart
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  const NetworkException(String message) : super(message);
}

class ServerException extends ApiException {
  const ServerException(
    String message, {
    int? statusCode,
    Map<String, dynamic>? details,
  }) : super(message, statusCode: statusCode, details: details);
}

class ValidationException extends ApiException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException(
    String message,
    this.fieldErrors,
  ) : super(message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(String message) : super(message);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(String message) : super(message);
}

class NotFoundException extends ApiException {
  const NotFoundException(String message) : super(message);
}

class RateLimitException extends ApiException {
  final Duration retryAfter;

  const RateLimitException(
    String message,
    this.retryAfter,
  ) : super(message);
}
```

#### Dio Error Interceptor
```dart
// lib/access/interceptors/error_interceptor.dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:app/access/exceptions/api_exceptions.dart';

class ErrorInterceptor extends Interceptor {
  final Logger _logger;

  ErrorInterceptor(this._logger);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioErrorToApiException(err);
    
    _logger.e(
      'API Error: ${err.requestOptions.method} ${err.requestOptions.path}',
      exception,
      err.stackTrace,
    );

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: exception,
      type: err.type,
      response: err.response,
    ));
  }

  ApiException _mapDioErrorToApiException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response!);

      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled.');

      case DioExceptionType.connectionError:
        return NetworkException('No internet connection available.');

      case DioExceptionType.unknown:
        return NetworkException('An unexpected error occurred: ${error.message}');

      default:
        return NetworkException('Network error occurred.');
    }
  }

  ApiException _handleResponseError(Response response) {
    final statusCode = response.statusCode!;
    final data = response.data;

    switch (statusCode) {
      case 400:
        if (data is Map<String, dynamic> && data.containsKey('field_errors')) {
          return ValidationException(
            data['message'] ?? 'Validation failed',
            Map<String, List<String>>.from(data['field_errors']),
          );
        }
        return ServerException(
          data['message'] ?? 'Bad request',
          statusCode: statusCode,
          details: data,
        );

      case 401:
        return UnauthorizedException(
          data['message'] ?? 'Authentication required',
        );

      case 403:
        return ForbiddenException(
          data['message'] ?? 'Access forbidden',
        );

      case 404:
        return NotFoundException(
          data['message'] ?? 'Resource not found',
        );

      case 429:
        final retryAfter = Duration(
          seconds: int.tryParse(response.headers['retry-after']?.first ?? '60') ?? 60,
        );
        return RateLimitException(
          data['message'] ?? 'Rate limit exceeded',
          retryAfter,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          data['message'] ?? 'Server error occurred',
          statusCode: statusCode,
          details: data,
        );

      default:
        return ServerException(
          data['message'] ?? 'Unknown server error',
          statusCode: statusCode,
          details: data,
        );
    }
  }
}
```

### 4. Authentication & Authorization

#### Authentication Interceptor
```dart
// lib/access/interceptors/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getString(_tokenKey);
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _refreshToken();
      
      if (refreshed) {
        // Retry the original request
        final options = err.requestOptions;
        final token = _prefs.getString(_tokenKey);
        options.headers['Authorization'] = 'Bearer $token';
        
        try {
          final dio = Dio();
          final response = await dio.fetch(options);
          handler.resolve(response);
          return;
        } catch (e) {
          // Token refresh failed, proceed with original error
        }
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _prefs.getString(_refreshTokenKey);
      if (refreshToken == null) return false;

      final dio = Dio();
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];

      await _prefs.setString(_tokenKey, newToken);
      await _prefs.setString(_refreshTokenKey, newRefreshToken);

      return true;
    } catch (e) {
      // Clear tokens on refresh failure
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_refreshTokenKey);
      return false;
    }
  }
}
```

### 5. Caching Strategy

#### Cache Interceptor
```dart
// lib/access/interceptors/cache_interceptor.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  final Duration defaultCacheDuration;

  CacheInterceptor(
    this._prefs, {
    this.defaultCacheDuration = const Duration(minutes: 5),
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only cache GET requests
    if (options.method.toUpperCase() != 'GET') {
      handler.next(options);
      return;
    }

    final cacheKey = _getCacheKey(options);
    final cachedResponse = _getCachedResponse(cacheKey);

    if (cachedResponse != null && !_isCacheExpired(cacheKey)) {
      // Return cached response
      handler.resolve(Response(
        requestOptions: options,
        data: cachedResponse['data'],
        statusCode: cachedResponse['statusCode'],
        headers: Headers.fromMap(
          Map<String, List<String>>.from(cachedResponse['headers']),
        ),
      ));
      return;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Cache successful GET responses
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200) {
      final cacheKey = _getCacheKey(response.requestOptions);
      _cacheResponse(cacheKey, response);
    }

    handler.next(response);
  }

  String _getCacheKey(RequestOptions options) {
    final uri = options.uri.toString();
    final headers = options.headers.entries
        .where((entry) => entry.key.startsWith('X-Cache'))
        .map((entry) => '${entry.key}:${entry.value}')
        .join(',');
    
    return 'cache_${uri}_$headers'.hashCode.toString();
  }

  Map<String, dynamic>? _getCachedResponse(String cacheKey) {
    final cachedString = _prefs.getString(cacheKey);
    if (cachedString == null) return null;

    try {
      return jsonDecode(cachedString);
    } catch (e) {
      return null;
    }
  }

  bool _isCacheExpired(String cacheKey) {
    final timestampString = _prefs.getString('${cacheKey}_timestamp');
    if (timestampString == null) return true;

    final timestamp = DateTime.tryParse(timestampString);
    if (timestamp == null) return true;

    return DateTime.now().difference(timestamp) > defaultCacheDuration;
  }

  void _cacheResponse(String cacheKey, Response response) {
    final cacheData = {
      'data': response.data,
      'statusCode': response.statusCode,
      'headers': response.headers.map,
    };

    _prefs.setString(cacheKey, jsonEncode(cacheData));
    _prefs.setString('${cacheKey}_timestamp', DateTime.now().toIso8601String());
  }

  void clearCache() {
    final keys = _prefs.getKeys().where((key) => key.startsWith('cache_'));
    for (final key in keys) {
      _prefs.remove(key);
    }
  }
}
```

### 6. Dio Configuration

#### HTTP Client Setup
```dart
// lib/access/http/dio_client.dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/access/interceptors/auth_interceptor.dart';
import 'package:app/access/interceptors/cache_interceptor.dart';
import 'package:app/access/interceptors/error_interceptor.dart';

class DioClient {
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);
  static const Duration _sendTimeout = Duration(seconds: 30);

  static Dio createDioClient({
    required String baseUrl,
    required SharedPreferences prefs,
    required Logger logger,
    Map<String, String>? defaultHeaders,
    bool enableCache = true,
    Duration? cacheDuration,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?defaultHeaders,
      },
    ));

    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(prefs),
      if (enableCache) 
        CacheInterceptor(prefs, defaultCacheDuration: cacheDuration ?? Duration(minutes: 5)),
      ErrorInterceptor(logger),
      if (logger.level == Level.debug) 
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          logPrint: (object) => logger.d(object),
        ),
    ]);

    return dio;
  }
}
```

### 7. Service Layer Integration

#### Service Implementation
```dart
// lib/business/[feature]/[feature]_service.dart
import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import 'package:app/access/[feature]/[feature]_repository.dart';
import 'package:app/access/exceptions/api_exceptions.dart';
import 'package:app/business/[feature]/user.dart';

abstract interface class UserService implements Disposable {
  factory UserService(
    UserRepository repository,
    Logger logger,
  ) = _UserService;

  Stream<List<User>> get usersStream;
  Future<List<User>> getUsers({
    int page = 1,
    String? search,
    String? sortBy,
  });
  Future<User> getUser(String id);
  Future<User> createUser(CreateUserRequest request);
  Future<User> updateUser(String id, UpdateUserRequest request);
  Future<void> deleteUser(String id);
}

final class _UserService implements UserService {
  final UserRepository _repository;
  final Logger _logger;
  final BehaviorSubject<List<User>> _usersSubject = BehaviorSubject.seeded([]);

  _UserService(UserRepository repository, Logger logger)
      : _repository = repository,
        _logger = logger {
    _loadInitialData();
  }

  @override
  Stream<List<User>> get usersStream => _usersSubject.stream;

  @override
  Future<List<User>> getUsers({
    int page = 1,
    String? search,
    String? sortBy,
  }) async {
    try {
      _logger.d('Fetching users: page=$page, search=$search, sortBy=$sortBy');

      final response = await _repository.getUsers(
        page: page,
        search: search,
        sortBy: sortBy,
      );

      final users = response.data.map(_mapToUser).toList();
      
      if (page == 1) {
        // Replace current users for first page
        _usersSubject.add(users);
      } else {
        // Append for pagination
        final currentUsers = List<User>.from(_usersSubject.value);
        currentUsers.addAll(users);
        _usersSubject.add(currentUsers);
      }

      _logger.i('Successfully loaded ${users.length} users');
      return users;

    } on ApiException catch (e) {
      _logger.e('API error while fetching users', e);
      throw ServiceException('Failed to load users: ${e.message}', e);
    } catch (e, stackTrace) {
      _logger.e('Unexpected error while fetching users', e, stackTrace);
      throw ServiceException('An unexpected error occurred while loading users');
    }
  }

  @override
  Future<User> getUser(String id) async {
    try {
      _logger.d('Fetching user: $id');
      
      final userData = await _repository.getUser(id);
      final user = _mapToUser(userData);
      
      _logger.i('Successfully loaded user: ${user.email}');
      return user;

    } on NotFoundException catch (e) {
      _logger.w('User not found: $id');
      throw ServiceException('User not found', e);
    } on ApiException catch (e) {
      _logger.e('API error while fetching user: $id', e);
      throw ServiceException('Failed to load user: ${e.message}', e);
    } catch (e, stackTrace) {
      _logger.e('Unexpected error while fetching user: $id', e, stackTrace);
      throw ServiceException('An unexpected error occurred while loading user');
    }
  }

  @override
  Future<User> createUser(CreateUserRequest request) async {
    try {
      _logger.d('Creating user: ${request.email}');

      final requestData = CreateUserRequestData(
        firstName: request.firstName,
        lastName: request.lastName,
        email: request.email,
        password: request.password,
      );

      final userData = await _repository.createUser(requestData);
      final user = _mapToUser(userData);

      // Add to current users list
      final currentUsers = List<User>.from(_usersSubject.value);
      currentUsers.insert(0, user); // Add at beginning
      _usersSubject.add(currentUsers);

      _logger.i('Successfully created user: ${user.email}');
      return user;

    } on ValidationException catch (e) {
      _logger.w('Validation failed for user creation: ${e.fieldErrors}');
      throw ServiceException('Invalid user data: ${e.message}', e);
    } on ApiException catch (e) {
      _logger.e('API error while creating user', e);
      throw ServiceException('Failed to create user: ${e.message}', e);
    } catch (e, stackTrace) {
      _logger.e('Unexpected error while creating user', e, stackTrace);
      throw ServiceException('An unexpected error occurred while creating user');
    }
  }

  User _mapToUser(UserResponseData data) {
    return User(
      id: data.id,
      firstName: data.firstName,
      lastName: data.lastName,
      email: data.email,
      avatarUrl: data.avatarUrl,
      createdAt: data.createdAt,
      isActive: data.isActive,
    );
  }

  Future<void> _loadInitialData() async {
    try {
      await getUsers();
    } catch (e) {
      _logger.w('Failed to load initial user data', e);
      // Don't throw here - let the UI handle the empty state
    }
  }

  @override
  FutureOr onDispose() async {
    await _usersSubject.close();
  }
}

// Service exception wrapper
class ServiceException implements Exception {
  final String message;
  final Exception? cause;

  const ServiceException(this.message, [this.cause]);

  @override
  String toString() => 'ServiceException: $message';
}

// Request models for service layer
class CreateUserRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const CreateUserRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}

class UpdateUserRequest {
  final String? firstName;
  final String? lastName;
  final String? email;

  const UpdateUserRequest({
    this.firstName,
    this.lastName,
    this.email,
  });
}
```

### 8. Dependency Injection Setup

#### GetIt Registration
```dart
// lib/access/di/api_module.dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/access/http/dio_client.dart';
import 'package:app/access/[feature]/[feature]_repository.dart';
import 'package:app/business/[feature]/[feature]_service.dart';

class ApiModule {
  static Future<void> register() async {
    final getIt = GetIt.instance;

    // HTTP Client
    getIt.registerSingleton<Dio>(
      DioClient.createDioClient(
        baseUrl: 'https://api.example.com/v1',
        prefs: getIt<SharedPreferences>(),
        logger: getIt<Logger>(),
        defaultHeaders: {
          'X-API-Version': '1.0',
          'X-Client-Platform': 'flutter',
        },
      ),
    );

    // Repositories
    getIt.registerSingleton<UserRepository>(
      UserRepository(getIt<Dio>()),
    );

    // Services
    getIt.registerSingleton<UserService>(
      UserService(
        getIt<UserRepository>(),
        getIt<Logger>(),
      ),
    );
  }
}
```

### 9. Testing API Integration

#### Repository Tests
```dart
// test/access/user_repository_test.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'user_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('UserRepository', () {
    late UserRepository repository;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      repository = UserRepository(mockDio);
    });

    group('getUsers', () {
      test('should return paginated users on successful response', () async {
        // Arrange
        final responseData = {
          'data': [
            {
              'id': '1',
              'first_name': 'John',
              'last_name': 'Doe',
              'email': 'john@example.com',
              'created_at': '2023-01-01T00:00:00Z',
              'is_active': true,
            }
          ],
          'meta': {
            'page': 1,
            'per_page': 20,
            'total': 1,
            'total_pages': 1,
          }
        };

        when(mockDio.get(
          '/users',
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/users'),
        ));

        // Act
        final result = await repository.getUsers();

        // Assert
        expect(result.data, hasLength(1));
        expect(result.data.first.firstName, equals('John'));
        expect(result.meta.total, equals(1));
        
        verify(mockDio.get('/users', queryParameters: anyNamed('queryParameters'))).called(1);
      });

      test('should handle network errors', () async {
        // Arrange
        when(mockDio.get(
          '/users',
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/users'),
          type: DioExceptionType.connectionTimeout,
        ));

        // Act & Assert
        expect(
          () => repository.getUsers(),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('createUser', () {
      test('should create user successfully', () async {
        // Arrange
        final requestData = CreateUserRequestData(
          firstName: 'Jane',
          lastName: 'Smith',
          email: 'jane@example.com',
          password: 'password123',
        );

        final responseData = {
          'id': '2',
          'first_name': 'Jane',
          'last_name': 'Smith',
          'email': 'jane@example.com',
          'created_at': '2023-01-01T00:00:00Z',
          'is_active': true,
        };

        when(mockDio.post(
          '/users',
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/users'),
        ));

        // Act
        final result = await repository.createUser(requestData);

        // Assert
        expect(result.firstName, equals('Jane'));
        expect(result.email, equals('jane@example.com'));
        
        verify(mockDio.post('/users', data: anyNamed('data'))).called(1);
      });
    });
  });
}
```

#### Service Tests with API Mocking
```dart
// test/business/user_service_test.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import 'user_service_test.mocks.dart';

@GenerateMocks([UserRepository, Logger])
void main() {
  group('UserService', () {
    late UserService service;
    late MockUserRepository mockRepository;
    late MockLogger mockLogger;

    setUp(() {
      mockRepository = MockUserRepository();
      mockLogger = MockLogger();
      service = UserService(mockRepository, mockLogger);
    });

    tearDown(() async {
      await service.onDispose();
    });

    group('getUsers', () {
      test('should transform repository data correctly', () async {
        // Arrange
        final repositoryResponse = PaginatedResponse(
          data: [
            UserResponseData(
              id: '1',
              firstName: 'John',
              lastName: 'Doe',
              email: 'john@example.com',
              createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
              isActive: true,
            ),
          ],
          meta: PaginationMeta(
            page: 1,
            perPage: 20,
            total: 1,
            totalPages: 1,
          ),
        );

        when(mockRepository.getUsers(
          page: anyNamed('page'),
          search: anyNamed('search'),
          sortBy: anyNamed('sortBy'),
        )).thenAnswer((_) async => repositoryResponse);

        // Act
        final result = await service.getUsers();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.firstName, equals('John'));
        expect(result.first.fullName, equals('John Doe'));
        
        verify(mockRepository.getUsers(
          page: 1,
          search: null,
          sortBy: null,
        )).called(1);
      });

      test('should handle API exceptions gracefully', () async {
        // Arrange
        final apiException = NetworkException('Connection failed');
        when(mockRepository.getUsers(
          page: anyNamed('page'),
          search: anyNamed('search'),
          sortBy: anyNamed('sortBy'),
        )).thenThrow(apiException);

        // Act & Assert
        expect(
          () => service.getUsers(),
          throwsA(isA<ServiceException>()),
        );
        
        verify(mockLogger.e('API error while fetching users', apiException)).called(1);
      });
    });

    group('stream behavior', () {
      test('should emit users when loaded successfully', () async {
        // Arrange
        final repositoryResponse = PaginatedResponse(
          data: [
            UserResponseData(
              id: '1',
              firstName: 'John',
              lastName: 'Doe',
              email: 'john@example.com',
              createdAt: DateTime.now(),
              isActive: true,
            ),
          ],
          meta: PaginationMeta(page: 1, perPage: 20, total: 1, totalPages: 1),
        );

        when(mockRepository.getUsers(
          page: anyNamed('page'),
          search: anyNamed('search'),
          sortBy: anyNamed('sortBy'),
        )).thenAnswer((_) async => repositoryResponse);

        // Act
        final stream = service.usersStream;
        await service.getUsers();

        // Assert
        await expectLater(
          stream,
          emits(predicate<List<User>>((users) => 
            users.length == 1 && users.first.firstName == 'John'
          )),
        );
      });
    });
  });
}
```

### 10. Performance Considerations

#### Request Optimization
```dart
// Implement request batching for multiple related calls
class BatchRequestService {
  final Dio _dio;
  final Logger _logger;

  BatchRequestService(this._dio, this._logger);

  Future<Map<String, dynamic>> batchUserRequests(List<String> userIds) async {
    try {
      final futures = userIds.map((id) => _dio.get('/users/$id'));
      final responses = await Future.wait(futures);
      
      final results = <String, dynamic>{};
      for (int i = 0; i < userIds.length; i++) {
        results[userIds[i]] = responses[i].data;
      }
      
      return results;
    } catch (e) {
      _logger.e('Batch request failed', e);
      rethrow;
    }
  }
}

// Implement request debouncing for search
class DebouncedSearchService {
  final UserRepository _repository;
  Timer? _debounceTimer;
  
  DebouncedSearchService(this._repository);

  Future<List<User>> searchUsers(String query) {
    final completer = Completer<List<User>>();
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () async {
      try {
        final response = await _repository.getUsers(search: query);
        final users = response.data.map(_mapToUser).toList();
        completer.complete(users);
      } catch (e) {
        completer.completeError(e);
      }
    });
    
    return completer.future;
  }
}
```

## API Integration Checklist

### Setup & Configuration
- [ ] **Data models** defined with proper JSON serialization
- [ ] **Repository interface** created with Retrofit annotations
- [ ] **Error handling** implemented with custom exceptions
- [ ] **Authentication** handled with interceptors
- [ ] **Caching strategy** implemented where appropriate
- [ ] **Dio client** configured with proper timeouts and headers

### Error Handling
- [ ] **Network errors** properly mapped to user-friendly messages
- [ ] **HTTP status codes** handled appropriately
- [ ] **Validation errors** properly structured and displayed
- [ ] **Rate limiting** handled with retry logic
- [ ] **Authentication failures** trigger token refresh or re-login

### Testing
- [ ] **Repository tests** cover success and error scenarios
- [ ] **Service tests** verify business logic and transformations
- [ ] **Mock implementations** available for development and testing
- [ ] **Integration tests** validate end-to-end API flows
- [ ] **Error scenarios** thoroughly tested

### Performance
- [ ] **Request/response** sizes optimized
- [ ] **Caching** implemented for appropriate endpoints
- [ ] **Pagination** used for large datasets
- [ ] **Request batching** considered for multiple related calls
- [ ] **Background sync** implemented where needed

### Security
- [ ] **Authentication tokens** properly stored and managed
- [ ] **Sensitive data** not logged or cached inappropriately
- [ ] **HTTPS** enforced for all API calls
- [ ] **Certificate pinning** considered for production
- [ ] **Input validation** performed before API calls

## Common API Integration Anti-Patterns

1. **Blocking UI Thread** - Always use async/await properly
2. **Poor Error Handling** - Don't ignore network errors
3. **Missing Loading States** - Always show loading indicators
4. **Overfetching Data** - Request only what you need
5. **No Offline Support** - Consider offline scenarios
6. **Hardcoded URLs** - Use configuration for different environments
7. **Missing Request Timeouts** - Always set appropriate timeouts
8. **Poor Cache Management** - Implement proper cache invalidation
9. **Insecure Token Storage** - Use secure storage for sensitive data
10. **No Request Retry Logic** - Implement retry for transient failures