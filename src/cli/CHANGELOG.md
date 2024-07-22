# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)

Prefix your items with `(Template)` if the change is about the template and not the resulting application.

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
