## Mobile (Flutter) — scaffold

This repo includes a Flutter app scaffold focused on architecture and Android alarm/notification integration.

### Prereqs
- Flutter SDK installed (`flutter --version`)
- Android Studio + Android SDK

### Bootstrap (first time)
Because this environment may not have Flutter installed, generate platform folders locally:

```bash
cd mobile
flutter create .
flutter pub get
```

Then keep the `lib/` folder structure in this repo and re-apply any Android manifest / receiver changes described in `docs/android_exact_alarm_setup.md`.

### Running

```bash
flutter run
```



###### run
/Users/ayushwgadre/Library/Android/sdk/platform-tools/adb devices -l
flutter pub get
flutter run
flutter run -d chrome


f flutter run fails with a Gradle/Java issue, set Java 17 once:

flutter config --jdk-dir="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Co
