# Forced Update

The forced update feature is for when you want to force the user to update the app.
You could use this, for example, when the backend changes and you do not want the users to still use the old API.

To force an update, we wait for a `Future` `checkUpdateRequired()` to be resolved from the `UpdateRequiredservice` in the [main file of the app.](../src/app/lib/main.dart).

This will redirect the user to a page from which they cannot navigate back. The page will contain a button that leads them to the appropriate page for updating the app, with the links defined in [appsettings.env](../src/app/appsettings.env).
