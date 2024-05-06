# Firebase Remote Configuration

This apps uses firebase for remote configurations, you can learn more about remote configuration [here](https://firebase.google.com/docs/remote-config/get-started?platform=flutter).

To use remoteconfig, you must create a firebase project and link it to this project using the `flutterfire configure --project=yourFireBaseProjectName` CLI command. 
You can look at [this documentation](https://firebase.google.com/docs/flutter/setup?platform=ios) for more details. 

It's important to note that connecting firebase to your project will expose api keys. According to firebase documentation, however, this is not problematic.  You can learn more about it [here](https://firebase.google.com/docs/projects/api-keys).
