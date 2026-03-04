# Kill Switch

The kill switch feature is for when you want to temporarily lock the user out of the app. 
This could be used for example when the server is down for some time, to avoid the users getting a ton of errors and getting reports from those users.

To trigger the kill switch, we subscribe to the `isKillSwitchActivatedStream` `stream` from the `KillSwitchService` in the [Main](../src/app/lib/main.dart).

If the kill switch is activated, the user is brought to the `KillSwitchPage` where they can see a message that tells them the app is currently unavailable.
If the kill switch is deactivated afterwards, the user is brought back to the initial navigation flow, which means they will be on the login page if they are not connected and on the home page if they are connected. 

Whether the kill switch is activated or not on mobile and web platforms is defined in a [remote config](FirebaseRemoteConfig.md).
