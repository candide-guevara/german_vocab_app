# german_vocab_app

An app to learn german.

## Directory structure

* `word_list_builder` utils to build the dictionary embedded in the app.
* `flutter` the app code.

## Flutter and Debian are a pain

To make this work on a chromebook using crostini you need:

* [`apt install` base packages](https://docs.flutter.dev/get-started/install/linux/desktop#development-tools)
* [Install android studio](https://wiki.debian.org/AndroidStudio): should contain android-sdk, do not install via `apt`
* [Install android-sdk CLI](https://developer.android.com/studio#command-tools)
* [Install flutter](https://docs.flutter.dev/get-started/install/linux/desktop#development-tools)
  * Run `flutter doctor` and fix stuff.
* [Install vscode](https://wiki.debian.org/VisualStudioCode)
  * Install flutter extension in vscode.
* Modify `$PATH` to include `/Android/Sdk/platform-tools:~/Android/Sdk/cmdline-tools/latest/bin:~/flutter/bin`

```
flutter create --empty --template=app --platforms=android,linux \
  --project-name=$FLUTTER_PROJECT_ROOT $FLUTTER_PROJECT_ROOT
pushd $FLUTTER_PROJECT_ROOT
flutter emulators --launch flutter_emulator
flutter run
adb emu kill
```

### BE CAREFUL it is a trap!

For some f\*\*king reason the [env variables](https://developer.android.com/tools/variables) got messed up
and `$ANDROID_AVD_HOME` points to a different place to where `flutter emulators` creates the device.
You must manually `ln -sT` to make this work...

