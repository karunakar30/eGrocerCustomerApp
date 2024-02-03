# greenfield Customer App Maintenance

## Generate Keystore

Create a keystore for the app:

```shell
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass {PASSWORD HERE} -keypass {PASSWORD HERE} -dname "CN={Your Name}, OU={Your Unit}, O={Your Organization}, L={Your Location}, S={Your State}, C={Your Country}" 
```

## Get SHA Keys

To generate sha keys
```shell
cd android
./gradlew signingReport
cd ..
```

## Flutter Clean

To clean the project:

```shell
flutter clean
```

### Clean and Get Dependencies

To clean the project and fetch dependencies:

```shell
flutter clean
flutter pub get
```

### Repair Pub Cache

To repair the pub cache:

```shell
flutter clean
flutter pub cache repair
flutter pub get
```

## Build Android Application

To build the Android application:

```shell
flutter clean
flutter pub get
flutter build apk --split-per-abi
```

## Build Android App Bundle

To build the Android app bundle:

```shell
flutter clean
flutter pub get
flutter build appbundle
```

## Update iOS Pods

Update iOS dependencies:

```shell
cd ios
pod init
pod install
pod update
xed .
cd ..
```

## Clear Derived Cache Data in iOS

To clear derived cache data in iOS:

```shell
rm -rf ~/Library/Developer/Xcode/DerivedData
```

## Publish iOS App

### Publish Without Changing Version

To publish the iOS app without changing the version:

```shell
flutter clean
flutter pub get 
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm ios/podfile.lock
cd ios 
pod install 
pod update 
xed .
```

### Publish With Changing Version

To publish the iOS app with a version change:

```shell
flutter clean
flutter pub get 
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm ios/podfile.lock
cd ios 
pod install 
pod update 
flutter build ios
pod install 
pod update 
xed .
```

## Solve Common iOS Errors

To resolve common iOS errors:

```shell
flutter clean
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm ios/podfile.lock
cd ios 
pod deintegrate
flutter pub cache repair
flutter pub get 
pod install 
pod update 
flutter build ios
pod install 
pod update
xed .
```

## Clean Firebase Data and Cache

To clean old Firebase data and cache from the code:

```shell
rm -rf .metadata
rm -rf .flutter-plugins-dependencies
rm -rf .flutter-plugins
rm -rf .idea
rm -rf .dart_tool
rm -rf build
rm -rf android/app/google-services.json
rm -rf android/.gradle
rm -rf ios/.symlinks
rm -rf ios/Pods
rm -rf ios/Runner/GoogleService-Info.plist
rm -rf ios/firebase_app_id_file.json
rm -rf ios/build
rm -rf ios/Podfile.lock
rm -rf pubspec.lock
rm -rf lib/firebase_options.dart
```


## Clean Temp Cached Files

To clean cache from the code:

```shell
rm -rf .pub-cache/
rm -rf build/
rm -rf .dart_tool/
rm -rf .idea/
rm -rf .vscode/
rm -rf android/.gradle/
rm -rf ios/.symlinks/
rm -rf ios/Pods/
rm -rf ios/Flutter/
rm -rf ios/build/
rm -rf ios/Podfile.lock
rm -rf ios/Pods/
rm -rf pubspec.lock
rm -rf .flutter-plugins
rm -rf .flutter-plugins-dependencies
```
