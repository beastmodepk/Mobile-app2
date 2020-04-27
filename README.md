# Expense Tracker

This is an app to track one's expenditures. So as to visualise and identify all the places where we might be spending too much.



## Supported Functionalities
- Creation and deletion of expense

- A type/category for grouping similar expenses

- A profile where one will be able to store the user's name and email id

- Limits which would remind people of their excessive expenses

- Charts where people can visual their usage according to the daily, weekly and monthly caps

- Pie Charts which enable us to visualise and see on which category we are spending too much.




## Build & Run
Make sure you flutter is properly installed with the required SDKs.
Use th below command to check whether flutter is configured correctly -
```
flutter doctor
```

Check for updates in SDK -
```
flutter upgrade
```

The pubspec.yaml file contains all the dependencies required to build this app. All the commands from now onwards assume that you are currently in the "expense_tracker" project directory.

Collect the dependencies -
```
flutter packages get
```

Finally,.the project can be run. This project needs to be run using "--release" switch. Se of its features do not work in debug mode. So, make sure either emulator is running or a device is connected with USB debugging "On". Then just run the command below -

```
flutter run --release
```

After sometime, the app will be installed and ready to test on the phone/emulator.
