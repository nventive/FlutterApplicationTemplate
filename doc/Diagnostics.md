# Diagnostic Tools

This template comes with multiple built-in diagnostic tools.
This is not available in the prod environment.

## Diagnostics Overlay

When you start the application, you'll notice a box on the side of the screen.
This overlay shows a few buttons.
The overlay is accessible from anywhere in your app.
This is useful when you want to see something happening live.

![Diagnostic](https://github.com/nventive/FlutterApplicationTemplate/assets/90481654/cd481d4b-79c5-4a06-bf2f-dce22e42e8b6)

The default buttons include commands such as the following.
- **Expand/Minimize** opens or closes the expanded view of the overlay.
- **Move** moves the overlay left or right.
- **X** hides the overlay for the remaining of the app cycle.
    - If you want to permanently hide the diagnostic, go to the environment section within the expanded overlay.

## Expanded overlay widgets

The expanded diagnostics overlay has by default two widgets.

The navigation widget has some buttons with commands on them that allow you to do some navigation in the app.
The DeviceInfo widgets contains some information on the device and the app.
The environment widget which lets the user change the environment. See [Environment.md](./Environment.md) for more details.
The loggers widget which lets the user test logging and modify logging configuration. See [Logging.md](./Logging.md) for more details.