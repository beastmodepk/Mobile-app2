# Expense Tracker

This is an app made for Mobile App2 class for my school. This app is build to keep track one's expenditures. It helps visualise the expense using a pie chart and user can also add expense cap.



## Supported Functionalities
- Creation and deletion of expense

- A type/category for grouping similar expenses

- A profile where one will be able to store the user's name and email id

- Limits which would remind people of their excessive expenses

- Charts where people can visualize their usage according to the daily, weekly and monthly caps

- Pie Charts which enable us to visualise and see on which category we are spending too much.




## Build & Run

This app is made using flutter framework. Please go [here](https://flutter.dev/docs/get-started/install) to install flutter.

Make sure you flutter is properly installed with the required SDKs.

Use the command below to check whether flutter is configured correctly -
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

Finally, you have the enviroment to run this app. This project needs to be run using "--release" switch. Some of its features do not work in debug mode. So, make sure either emulator is running or a device is connected with USB debugging "On". Then just run the command below -

```
flutter run --release
```

The app does take a long time to run. If you are using a phone instead of emulator, the app should automatically pop up when it is ready

Below are the screenshots of different pages 


![homeimage](images/)
![new expense](images/)
![settings](images/)
![History](images/)
[!Daily History](images/)
[!Monthly History](images/)
