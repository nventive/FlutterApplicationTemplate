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

  /// Update whether data is obscured in shared prefs.
  Future setIsDataObscure(bool isDataObscure);

  /// Update the logCollection flag in shared prefs.
  Future setIsLogCollectionEnabled(bool isLogCollectionEnabled);

  /// Update the logFilter flag in shared prefs.
  Future setIsLogFilterEnabled(bool isLogFilterEnabled);

  /// Update the attachFile boolean flag in shared prefs.
  Future setAttachLogFileEnabled(bool attachLogFile);
}

final class _BugseeRepository implements BugseeRepository {
  final String _bugseeEnabledKey = 'bugseeEnabledKey';
  final String _bugseeVideoCaptureKey = 'bugseeVideoCaptureKey';
  final String _bugseeDataObscureKey = 'bugseeDataObscureKey';
  final String _bugseeDisableLogCollectionKey = 'bugseeDisableLogCollectionKey';
  final String _bugseeDisableLogFilterKey = 'bugseeDisableLogFilterKey';
  final String _bugseeAttachLogFileKey = 'bugseeAttachLogFileKey';

  @override
  Future<BugseeConfigurationData> getBugseeConfiguration() async {
    final sharedPrefInstance = await SharedPreferences.getInstance();
    return BugseeConfigurationData(
      isBugseeEnabled: sharedPrefInstance.getBool(_bugseeEnabledKey),
      isVideoCaptureEnabled: sharedPrefInstance.getBool(_bugseeVideoCaptureKey),
      isDataObscured: sharedPrefInstance.getBool(_bugseeDataObscureKey),
      isLogCollectionEnabled:
          sharedPrefInstance.getBool(_bugseeDisableLogCollectionKey),
      isLogsFilterEnabled:
          sharedPrefInstance.getBool(_bugseeDisableLogFilterKey),
      attachLogFileEnabled: sharedPrefInstance.getBool(_bugseeAttachLogFileKey),
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
      _bugseeVideoCaptureKey,
      isVideoCaptureEnabled,
    );

    if (!isSaved) {
      throw PersistenceException(
        message:
            'Error while setting $_bugseeVideoCaptureKey $isVideoCaptureEnabled',
      );
    }
  }

  @override
  Future setIsDataObscure(bool isDataObscured) async {
    final sharedPrefInstance = await SharedPreferences.getInstance();

    bool isSaved = await sharedPrefInstance.setBool(
      _bugseeDataObscureKey,
      isDataObscured,
    );

    if (!isSaved) {
      throw PersistenceException(
        message: 'Error while setting $_bugseeDataObscureKey $isDataObscured',
      );
    }
  }

  @override
  Future setIsLogCollectionEnabled(bool isLogCollected) async {
    final sharedPrefInstance = await SharedPreferences.getInstance();

    bool isSaved = await sharedPrefInstance.setBool(
      _bugseeDisableLogCollectionKey,
      isLogCollected,
    );

    if (!isSaved) {
      throw PersistenceException(
        message:
            'Error while setting $_bugseeDisableLogCollectionKey $isLogCollected',
      );
    }
  }

  @override
  Future setIsLogFilterEnabled(bool isLogFilterEnabled) async {
    final sharedPrefInstance = await SharedPreferences.getInstance();

    bool isSaved = await sharedPrefInstance.setBool(
      _bugseeDisableLogFilterKey,
      isLogFilterEnabled,
    );

    if (!isSaved) {
      throw PersistenceException(
        message:
            'Error while setting $_bugseeDisableLogFilterKey $isLogFilterEnabled',
      );
    }
  }

  @override
  Future setAttachLogFileEnabled(bool attachLogFile) async {
    final sharedPrefInstance = await SharedPreferences.getInstance();

    bool isSaved = await sharedPrefInstance.setBool(
      _bugseeAttachLogFileKey,
      attachLogFile,
    );

    if (!isSaved) {
      throw PersistenceException(
        message: 'Error while setting $_bugseeAttachLogFileKey $attachLogFile',
      );
    }
  }
}
