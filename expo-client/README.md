# About the app
Expo is based on React Native.  This framework allows covering Web, iOS and Android platforms with a shared codebase.  
This project uses expo-router based navigation. [Link]

## Setup
This should have been handled by the Windows or Linux installation scripts in project ai-chat-app.

### Create an empty example app
Useful if you want to start from a blank state:  
```
npx create-expo-app@latest expo-example-app 
```

## Run the app
### Install Expo Go app on your phone (Android/IPhone)
[https://expo.dev/go](https://expo.dev/go)  
Or install directly:  
* [Play Store App](https://play.google.com/store/apps/details?id=host.exp.exponent&hl=en)
* [App Store App](https://apps.apple.com/us/app/expo-go/id982107779)

### Install/update dependencies if needed
Navigate to project directory in CMD/terminal.
```
npm install
npm update
```

### Verify the state of the project
```
npx expo-doctor
```

### Environments
You do not have to use poetry/vu/venv/etc. to manage environment and dependencies (like you have to in Python projects), node installs everything in a local project specific environment by default.  

## Update config.json to add URL of your web-service
You Can use [ngrok](ngrok.com) for making your locally hosted web-service available on the internet.  
Instructions are in `/web-service/README.md`

### Start the app
```
np expo start
```

Follow the instructions you see in the terminal. You will see a QR code, following the link will open your project in Expo Go app./

# Create installation files for smartphones
Ignore this section.  
For now, just use 'Expo Go' to run your app.

* set up Expo Application Service (EAS).  
use `npm install -g eas-cli` or `yarn global add eas-cli`
* `eas login`
Configure your project, create eas.json if you don't have it  
* `eas build:configure`
## use Expo cloud
Expo free plan has a limit of 30 builds (15 max of those can be iOS) per month
### Compile AAB for Google Play Store
* By default, EAS will compile an AAB package.
* `eas build --platform android`

### Compile Android APK
* `eas build --platform android --profile <profile_name>`  
`"distribution": "internal"` means that an APK will be compiled.  
profile_name needs to match a profile in your `eas.json` file. It is `preview` by default. An example is given below:

```
{
  "cli": {
    "version": ">= 7.6.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "profile_name": { // this needs to match <profile_name> in the build command
      "distribution": "internal"
    },
    "production": {}
  },
  "submit": {
    "production": {}
  }
}
```

### Compile IPA for iOS phones and the App Store
This option uses Expo server to compile the app.  
* A specific iOS image has to specified in `eas.json`. If it is not specified, EAS will use a random build server. MacOS versions vary between these servers, I have seen 13.x and 14.x so far. This can result in the build succeeding on one server, and failing on a different one. Specifying the MacOS version fixes this.
```
"production": {
  "ios": {
    "image": "macos-ventura-13.6-xcode-15.2"
  }
}
```
* `eas build --platform ios`  
You need to have a valid Apple Developer account for this to work. And this only works on Linux/MacOS.

To be able to launch the app, there are 2 options:  
* you need to be registered as a Tester on Testflight, and assigned as tester to the app (invite via e-mail)
* your UDID had to specified when the app was compiled: ([learn more here](https://docs.expo.dev/build/internal-distribution/)).

## Compile the files locally
### APK
`eas build -p android --profile <profile_name> --local`

### IPA
Only works on MacOS devices:  
`eas build -p ios --profile <profile_name> --local`

# FAQ
## I see gradle errors when I try to compile APK/AAG/IPA files.
Use `npx expo-doctor` to diagnose issues. Issues shown when running this command will likely block compiling installation files.

## Important!
### Neither of the following guarantee that iOS/Android files can be compiled successfully:
* the app runs via Expo Go
* the web app runs locally via emulator
* `npx expo-doctor` shows no issues  

Testing that APK/AAG can be compiled locally should be done after any changes that introduce new packages, or update package versions.

Also, being able to compile the files does not mean that the app will be accepted by App Store or Play Store.

Use `npx expo-doctor` to check for issues.  
Use `npx expo install --check` to review and upgrade dependencies.  