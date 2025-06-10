# macro_mate

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running Tests

1. Install the Flutter SDK version used for this project:

```bash
./scripts/setup_flutter.sh
```

2. Add the SDK to your PATH as indicated by the script output or run:

```bash
export PATH="$(pwd)/flutter_sdk/bin:$PATH"
```

3. Run the tests:

```bash
flutter test
```

## Building for iOS (free provisioning)

To run the app on an iOS device without a paid developer account, follow these steps:

1. In the project root, run:

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

This generates the `Runner.xcworkspace` used by Xcode.

2. Open the workspace:

```bash
open ios/Runner.xcworkspace
```

3. In Xcode, sign in with your Apple ID under **Preferences > Accounts**.
4. Select the `Runner` target and choose your account under **Signing & Capabilities → Team**. Keep **Automatically manage signing** enabled.
5. Connect your device and press **Run** (`⌘R`) to build and install the app.

The certificate created this way is valid for seven days. After it expires you must rebuild the app from Xcode.

