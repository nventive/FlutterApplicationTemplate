# Dependency injection

We use [GetIt](https://pub.dev/packages/get_it) for any IoC related work.

## Registering

- You can register a singleton service using `GetIt.I.registerSingleton<IService>(ServiceImplementation())`. This service will be accessible from anywhere.

- You can register a service that will be created everytime you request it by using `GetIt.I.registerFactory<IService>(() => ServiceImplementation())`. 

## Resolving

- Dependencies are injected manually into the constructors of the registered services.

  ``` dart
  GetIt.I.registerSingleton<MyOtherService>(MyOtherService());
  GetIt.I.registerSingleton<MyService>(MyService(myOtherService: GetIt.I<MyOtherService>()));

  class MyService
  {
    final MyOtherService _myOtherService;

    MyService({MyOtherService myOtherService}) : _myOtherService = myOtherService;
  }
  ```

- If you can't use manual constructor injection, you can use `GetIt.I<IService>()` to resolve a service.
This will throw an exception if the type `IService` is not registered.

- Circular dependencies will not work with this container. If you do have them, you might get an exception or an infinite loop.

- You can access the service provider **statically** using `GetIt.I`.
