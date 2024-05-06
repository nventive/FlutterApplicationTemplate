# Firebase Remote Configuration

This apps uses Firebase for remote configurations, you can learn more about Firebase remote configurations [here](https://firebase.google.com/docs/remote-config/get-started?platform=flutter).

To use Remote Config, you must create a Firebase project and link it to this project using the `flutterfire configure --project=yourFireBaseProjectName` CLI command. 
You can look at [this documentation](https://firebase.google.com/docs/flutter/setup?platform=ios) for more details. 

It's important to note that connecting Firebase to your project will expose API keys.
According to Firebase documentation, however, this is not problematic.
You can learn more about it [here](https://firebase.google.com/docs/projects/api-keys).
