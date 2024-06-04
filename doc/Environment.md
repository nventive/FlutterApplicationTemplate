# Environments

We use `.env` files to store environment configuration with the help of [dotenv](https://pub.dev/packages/dotenv).

## Runtime environments

By default, the template offers the following runtime environments, defined by their corresponding `.env` files.

- Development (`.env.dev`)
- Staging (`.env.staging`)
- Production (`.env.prod`)

You can add / remove runtime environments by simply following those steps:
- Add or remove `.env` files (e.g. `.env.myenvironment`).
- Add or remove a value in the [Environment](../src/app/lib/business/environment/environment.dart) enum.
- Add or remove the associated item in `_EnvironmentManager._environmentFileNames`.

This is governed by `EnvironmentManager`. It's initialized in the main method by calling `EnvironmentManager.Load`.
Once initialized, the current environment configuration can be accessed with `dotenv` For example, you can do the following:
```dart
ForcedUpdatePage({super.key}) {
  if (Platform.isIOS) {
    _url = Uri.parse(dotenv.env['APP_STORE_URL_IOS']!);
  } else {
    _url = Uri.parse(dotenv.env['APP_STORE_URL_Android']!);
  }
}
```

- The default runtime environment is set via the environment variable `ENV`.
    - For local deployment, see `toolArgs` inside [launch.json](../.vscode/launch.json).
    - For builds, it's injected in the CI in the Flutter build task.
- You can get the current environment using `EnvironmentManager.current`.
- You can get all the possible environments using `EnvironmentManager.environments`.
- You can set the environment using `environmentManager.setEnvironment`. If the environment doesn't exist, you will get an exception.
  - You can see what will be the next environment using `environmentManager.next` (because `current` might not change instantly).
- When using `_EnvironmentManager` (the default implementation of `EnvironmentManager`), the current environment is persisted into the native storage that is processed at startup.

## Diagnostics

Multiple environment features can be tested from the diagnostics overlay.
This is configured in [EnvironmentPickerWidget](../src/app/lib/presentation/diagnostic/environment_picker_widget.dart).

- You can see the current runtime environment.
- You can see what the environment will be overriden to. 
- You can switch to another runtime environment.
- You can reset the environment to its default value.