# Testing
For more documentation on testing, read the references listed at the bottom.

## Unit Testing
- We use [flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) to create tests. You can create a test like this :
    
    ```bash
    // Import the test package
    import 'package:test/test.dart';
    
    void main() {
      test('X should do something', () {
        ...
      });
    }
    ```
    
- To assert the result of a test, use `expect()`
    
    ```dart
    /* 
    void expect(
      // actual value to be verified
    	dynamic actual,
      // characterises the expected result
    	dynamic matcher, {
    	// added in case of failure
    	String? reason,
    	// true or a String with the reasion to skip
    	dynamic skip,
    	}
    )
    */
    
    expect(actual, value);
    expect(actual, isNull);
    expect(actual, isNotNull);

    ... and many more 
    ```
    
    [Read more : Assertions in Dart and Flutter tests: an (almost) ultimate cheat sheet](https://invertase.io/blog/assertions-in-dart-and-flutter-tests-an-ultimate-cheat-sheet)
    
- We use [Mockito](https://pub.dev/packages/mockito) to mock classes.
    
    ```dart
	import 'package:mockito/annotations.dart';
	import 'package:mockito/mockito.dart';

	// Annotation which generates the cat.mocks.dart library and the MockCat class.
	@GenerateNiceMocks([MockSpec<Cat>()])
	import 'cat.mocks.dart';

	// Real class
	class Cat {
	String sound() => "Meow";
	bool eatFood(String food, {bool? hungry}) => true;
	Future<void> chew() async => print("Chewing...");
	int walk(List<String> places) => 7;
	void sleep() {}
	void hunt(String place, String prey) {}
	int lives = 9;
	}

	void main() {
	// Create mock object.
	var cat = MockCat();
	}
    ```
    
- We use [http-mock-adapter](https://pub.dev/packages/http_mock_adapter) to mock request-response communication with Dio.
    
    ```dart
    void main() {
    	test('get example', () async {
    		// Arrange
    		final dio = Dio(BaseOptions());
    	  final dioAdapter = DioAdapter(dio: dio);
    
    	  const path = 'https://example.com';
    
    	  dioAdapter.onGet(
    	    path,
    	    (server) => server.reply(
    	      200,
    	      {'message': 'Success!'},
    	      // Reply would wait for one-sec before returning data.
    	      delay: const Duration(seconds: 1),
    	    ),
    	  );
    
    		// Act
    	  final response = await dio.get(path);
    
    		// Assert
    		expect(response.data, {'message': 'Success!'});
    	});	
    }
    ```

## Code coverage
You can collect the code coverage locally using the following command lines.

### Installing lcov/genhtml

In order to visualize the test coverage you need to install lcov and by extension genhtml.

On windows you need chocolatey and run this command
```bash
chocolatey install lcov
```

on macOS you need to have lcov installed on your system (`brew install lcov`) to use the `genhtml` command.

Then you need to add the genhtml path to your environment variables. Go to the properties of your pc then go to advanced system settings -> Environment variables, then in system variables find the 
path variable and edit it. Add this path C:\ProgramData\chocolatey\lib\lcov\tools\bin and now open a git bash terminal against your src/app folder and enter these commands

```bash
# Generate `coverage/lcov.info` file
flutter test --coverage
# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
```

It should have created an html folder in your coverage folder where you can open the index.html file and see a visualization of your test coverage.

The report created can then be used to drill into different files and see what lines are covered or not (blue means covered, red means uncovered).

![coverage_visualization_example](https://github.com/nventive/FlutterApplicationTemplate/assets/72167772/b9c3906a-7122-4e7e-9f5e-b6d42b5dba2b)

There’s also a couple of VSCode extensions you can use to visualize your coverage if you want. 

[Flutter Coverage](https://marketplace.visualstudio.com/items?itemName=Flutterando.flutter-coverage) (Not working at the moment) will add a new section to your `Testing` tab.

![flutter_coverage_demo](https://github.com/nventive/FlutterApplicationTemplate/assets/72167772/ed686bbc-828c-411d-b819-26813b5c2c77)

[Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters) will show you which lines in your code isn’t covered by a test.

![coverage_gutters_demo](https://github.com/nventive/FlutterApplicationTemplate/assets/72167772/66b5724e-6f8d-42d1-b4da-d9e4810f06b7)

For both of these extensions to work, you must generate a `lcov.info` file before hand, or whenever you make a change and want to see your coverage.

## Naming
In general, test files should reside inside a `test` folder located at the root of your Flutter application or package. Test files should always end with `_test.dart`, this is the convention used by the test runner when searching for tests.

Your file structure should look like this:
```
FlutterApplicationTemplate/
	src/app/
		lib/
			business/
				dad_jokes_service.dart
		test/
			business/
				dad_jokes_service_test.dart
```

As for the tests themselves their names should indicate either the expected result with or without a condition or the action performed. 

For example : 
```dart
test('Get all favorite jokes', () async {
  var result = await SUT.getFavoriteDadJokes();
  var mockedJokesList = getFavoriteDadJokesList()
	  .map(
		(favoriteDadJoke) => DadJoke.fromData(
		  favoriteDadJoke,
		  isFavorite: true,
		),
	  )
	  .toList();

  expect(result, mockedJokesList);
});
```

## References
- [Read more : Assertions in Dart and Flutter tests: an (almost) ultimate cheat sheet](https://invertase.io/blog/assertions-in-dart-and-flutter-tests-an-ultimate-cheat-sheet)
- [Mockito](https://pub.dev/packages/mockito)
- [Mocking and Testing Shared Preferences in Flutter Unit Tests](https://blog.victoreronmosele.com/mocking-shared-preferences-flutter)