import 'package:equatable/equatable.dart';

final class BugseeConfigState extends Equatable {
  /// Indicate if the app require a restart to reactivate the bugsee configurations
  ///
  /// `true` only if `isConfigurationValid == true` and bugsee is turned on
  bool isRestartRequired;

  /// Indicate if bugsee is enabled or not
  /// by default bugsee is enabled if `isConfigurationValid == true`.
  bool isBugseeEnabled;

  /// Indicate whether video capturing is enabled or not.
  /// enabled by default if `isBugseeEnabled == true`.
  ///
  /// cannot be true if `isBugseeEnabled == false`.
  bool isVideoCaptureEnabled;

  /// Indicate if bugsee configuration is valid
  /// config is valid if app in release mode and the provided token is valid
  /// following the [bugseeTokenFormat] regex.
  bool isConfigurationValid;

  /// Indicate whether data is obscured in report videos
  ///
  /// cannot be true if `isBugseeEnabled == false`.
  bool isDataObscured;

  /// Indicate whether log will be collected during Bugsee reporting or not
  /// by default logs are collected but filterd.
  ///
  /// This value is initialized from [dotenv.env] and shared prefs storage.
  bool isLogCollectionEnabled;

  /// Indicate whether log will be filterd or not
  /// by default all logs are filted using [bugseeFilterRegex] defined in [BugseeManager]
  ///
  /// This value is initialized from [dotenv.env] map and shared prefs storage.
  bool isLogFilterEnabled;

  BugseeConfigState({
    this.isRestartRequired = false,
    this.isBugseeEnabled = false,
    this.isVideoCaptureEnabled = false,
    this.isConfigurationValid = false,
    this.isDataObscured = false,
    this.isLogCollectionEnabled = false,
    this.isLogFilterEnabled = false,
  });

  BugseeConfigState copyWith({
    bool? isRestartRequired,
    bool? isBugseeEnabled,
    bool? isVideoCaptureEnabled,
    bool? isConfigurationValid,
    bool? isDataObscured,
    bool? isLogCollectionEnabled,
    bool? isLogFilterEnabled,
  }) =>
      BugseeConfigState(
        isRestartRequired: isRestartRequired ?? this.isRestartRequired,
        isBugseeEnabled: isBugseeEnabled ?? this.isBugseeEnabled,
        isConfigurationValid: isConfigurationValid ?? this.isConfigurationValid,
        isDataObscured: isDataObscured ?? this.isDataObscured,
        isLogFilterEnabled: isLogFilterEnabled ?? this.isLogFilterEnabled,
        isLogCollectionEnabled:
            isLogCollectionEnabled ?? this.isLogCollectionEnabled,
        isVideoCaptureEnabled:
            isVideoCaptureEnabled ?? this.isVideoCaptureEnabled,
      );

  @override
  List<Object?> get props => [
        isRestartRequired,
        isBugseeEnabled,
        isVideoCaptureEnabled,
        isConfigurationValid,
        isDataObscured,
      ];
}
