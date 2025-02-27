## Dad Jokes app example

The `flutter_application_generator` source code includes a complete working example in the `src/app/` folder. It's a simple joke browser app that uses the Reddit API to display jokes posted to the `r/dadjokes` subreddit and allows you to manage favorites (add / remove). It also includes an authentication example.

Before running the example, it's necessary to run the `build_runner` package in order to create the required generated files. Using your terminal of choice, navigate to the `src/app/` folder and run the following:

```bash
dart run build_runner build --delete-conflicting-outputs
```