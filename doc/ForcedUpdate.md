# Forced Update

The forced update feature is for when you want to force the user to update the app.
You could use this, for example, when the backend changes and you do not want the users to still use the old API.

To force an update, we wait for a `Future` `checkUpdateRequired()` to be resolved from the `UpdateRequiredservice` in the [main file of the app.](../src/app/lib/main.dart).

This will redirect the user to [a page](../src/app/lib/presentation/forced_update/forced_update_page.dart) from which they cannot navigate back. 
The minimum update required is defined in a [firebase remote config](/doc/FirebaseRemoteConfig.md).