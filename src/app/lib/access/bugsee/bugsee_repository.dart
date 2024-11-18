import 'package:app/access/bugsee/bugsee_configuration_data.dart';
import 'package:app/access/persistence_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class BugseeRepository {
  factory BugseeRepository() = _BugseeRepository;

  /// Load the current bugsee configuration stored in shared prefs.
  Future<BugseeConfigurationData> getBugseeConfiguration();

  /// Update the current Bugsee enabled flag in shared prefs.
  Future setIsBugseeEnabled(bool isBugseeEnabled);

  /// Update the current video captured or not flag in shared prefs.
  Future setIsVideoCaptureEnabled(bool isVideoCaptureEnabled);

  /// Update whether data is obscure in shared prefs.
  Future setIsDataObscure(bool isDataObscure);
}

final class _BugseeRepository implements BugseeRepository {
  final String _bugseeEnabledKey = 'bugseeEnabledKey';
  final String _videoCaptureKey = 'videoCaptureKey';
  final String _dataObscureKey = 'dataObscureKey';

  @override
  Future<BugseeConfigurationData> getBugseeConfiguration() async {
    final sharedPrefInstance = await SharedPreferences.getInstance();
    return BugseeConfigurationData(
      isBugseeEnabled: sharedPrefInstance.getBool(_bugseeEnabledKey),
      isVideoCaptureEnabled: sharedPrefInstance.getBool(_videoCaptureKey),
      isDataObscrured: sharedPrefInstance.getBool(_dataObscureKey),
    );
  }

  @override
  Future setIsBugseeEnabled(bool isBugseeEnabled) async {
    final sharedPrefInstance = await SharedPreferences.getInstance();

    bool isSaved = await sharedPrefInstance.setBool(
      _bugseeEnabledKey,
      isBugseeEnabled,
    );

    if (!isSaved) {
      throw PersistenceException(
        message: 'Error while setting $_bugseeEnabledKey $isBugseeEnabled',
      );
    }
  }

  @override
  Future setIsVideoCaptureEnabled(bool isVideoCaptureEnabled) async {
    final sharedPrefInstance = await SharedPreferences.getInstance();

    bool isSaved = await sharedPrefInstance.setBool(
      _videoCaptureKey,
      isVideoCaptureEnabled,
    );

    if (!isSaved) {
      throw PersistenceException(
        message: 'Error while setting $_videoCaptureKey $isVideoCaptureEnabled',
      );
    }
  }

  @override
  Future setIsDataObscure(bool isDataObscured) async {
    final sharedPrefInstance = await SharedPreferences.getInstance();

    bool isSaved = await sharedPrefInstance.setBool(
      _dataObscureKey,
      isDataObscured,
    );

    if (!isSaved) {
      throw PersistenceException(
        message: 'Error while setting $_dataObscureKey $isDataObscured',
      );
    }
  }
}
