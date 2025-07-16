# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

Prefix your items with `(Template)` if the change is about the template and not the resulting application.

## 0.25.4
- Fix CocoaPods cache and dependency issues in iOS build pipeline.
- Improve CocoaPods deintegration and cache cleaning process in CI/CD.

## 0.25.3
- Add local pub.dev score report.
- Add built-time validation requiring a pub.dev score threshold of 160.

## 0.25.2
- Update iOS & Android minimum version targets.
- Update macOS CI/CD agent.

## 0.25.1
- Update Flutter packages.

## 0.25.0
- Added design system, including color scheme and fonts.

## 0.24.4
- Fix commit validation after a merge.
- Update localization documentation.

## 0.24.3
- Update CLI documentation.

## 0.24.2
- General improvements, including sample documentation (see `src/cli/example/README.md`).
- Update versions of CI/CD tasks.

## 0.24.1
- Add `getFromStream` to have ViewModel properties that automatically update based on `Stream` sources.

## 0.24.0
- Replace Riverpod in favor of a custom MVVM recipe with ViewModels to better align with the recommended [app architecture](https://docs.flutter.dev/app-architecture).

## 0.23.0
- Update Flutter to 3.27.3 and update dependencies.

## 0.22.0
- Moved Android distribution for Staging from App Center to Firebase App Distribution.

## 0.21.1
- Added conventional commit validation stage `stage-build.yml`

## 0.21.0
- Add Bugsee SDK in Flutter template
- Update build stage in `steps-build-android.yml` and `steps-build-ios` providing Bugsee token

## 0.20.4
- Updates to documentation

## 0.20.3
- (CI/CD) Fixes an authentication issue with pub.dev

## 0.20.2
- (Template) Fixes an issue with the CLI in which the build fails during template generation because of a missing required file.

## 0.20.1
- Fix CI/CD artifact name for Android.
- Fix CI/CD to install gcloud CLI Tool.
- Fix CI/CD build number

## 0.20.0
- Configured MobSF security scan on Android and iOS for Staging and Production builds. 

## 0.19.4
- Fix CI/CD artifact name for iOS stage.

## 0.19.3
- Fix CI/CD artifact name for iOS.
- Firebase configuration is now injected by CI/CD.

## 0.19.2
- Cleanup documentation.

## 0.19.1
- Target specific Dart (>=3.4.0 <4.0.0) / Flutter (3.22.1) SDK.

## 0.19.0
- Replaced Powershell Copy Tool by a Dart CLI.

## Before Initial Release
- Added basic project file structure.
- Added basic empty Flutter project.
- Added basic PowerShell script to create project based on this template.
- Added basic documentation based on the `UnoApplicationTemplate`.
- Set minimum version of iOS 15.
- Target Android 14 with a minimum version of Android 11.
- Added empty Azure Pipelines.
- Updated Azure Pipelines (Windows, Android, iOS, Tests).
- Added simple Dad Jokes page.
- Fixed Azure Pipelines (iOS).
- Fixed Android missing Internet permission.
- Fixed Android release on Google Play.
- Fixed PowerShell script that was copying source control.
- Added Navigation to the app.
- Fixed Mergify.
- Added Diagnostic overlay to the app.
- Added examples of unit tests.
- Added Forced update feature to the app.
- Added Environments (Dev, Staging & Prod).
- Added Forced update implementation with Firebase.
- Fix start from VS Code Debug Menu.
- Added Kill Switch feature to the app.
- Added logging to the app.
- Added Firebase implementation of the Kill Switch feature.
- Added Alice as a tool to see logs in app.
- Fix diagnostic overlay dismiss behavior so it's not permanent.
- Added test for the UpdateRequiredService and fixed bug where remote config was not updating correctly.
- Added functionnal tests examples.
- Fixed minor bug where the current path was not being updated properly.
- Added localization.
- Added test for the killswitch.
- Added integration test for forced update.