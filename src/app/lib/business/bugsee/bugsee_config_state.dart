import 'package:equatable/equatable.dart';

final class BugseeConfigState extends Equatable {
  /// indicate if the app require a restart to reactivate the bugsee configurations
  ///
  /// `true` only if `isConfigurationValid == true` and bugsee is turned on
  bool isRestartRequired;

  /// indicate if bugsee is enabled or not
  /// by default bugsee is enabled if `isConfigurationValid == true`.
  bool isBugseeEnabled;

  /// indicate whether video capturing is enabled or not.
  /// enabled by default if `isBugseeEnabled == true`.
  ///
  /// cannot be true if `isBugseeEnabled == false`.
  bool isVideoCaptureEnabled;

  /// indicate if bugsee configuration is valid
  /// config is valid if app in release mode and the provided token is valid
  /// following the [bugseeTokenFormat] regex.
  bool isConfigurationValid;

  /// indicate whether data is obscured in report videos
  ///
  /// cannot be true if `isBugseeEnabled == false`.
  bool isDataObscured;

  BugseeConfigState({
    this.isRestartRequired = false,
    this.isBugseeEnabled = false,
    this.isVideoCaptureEnabled = false,
    this.isConfigurationValid = false,
    this.isDataObscured = false,
  });

  BugseeConfigState copyWith({
    bool? isRestartRequired,
    bool? isBugseeEnabled,
    bool? isVideoCaptureEnabled,
    bool? isConfigurationValid,
    bool? isDataObscured,
  }) =>
      BugseeConfigState(
        isRestartRequired: isRestartRequired ?? this.isRestartRequired,
        isBugseeEnabled: isBugseeEnabled ?? this.isBugseeEnabled,
        isConfigurationValid: isConfigurationValid ?? this.isConfigurationValid,
        isDataObscured: isDataObscured ?? this.isDataObscured,
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
