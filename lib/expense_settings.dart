import 'package:expense_tracker/expense_manager.dart';
import 'package:flutter/material.dart';

class ExpenseSettings extends StatefulWidget {

  final BuildContext context;
  final ExpenseManager expenseManager;

  static _ExpenseSettings of(BuildContext context) => context.findAncestorStateOfType<_ExpenseSettings>();

  ExpenseSettings(this.context, this.expenseManager);

  @override
  _ExpenseSettings createState() => _ExpenseSettings(context, expenseManager);
}

class _ExpenseSettings extends State<ExpenseSettings> {
  BuildContext context;
  ExpenseManager expenseManager;
  String yourName = "", yourEmail = "", monthly_expense_cap = "", weekly_expense_cap = "", daily_expense_cap = "";
  bool is_mounted = true;

  _ExpenseSettings(this.context, this.expenseManager);

  @override
  void dispose() {
    is_mounted = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // get required settings from database
    this.expenseManager.settings_get("your_name").then((val) {
      if(val != null && val.length > 0) {  yourName = val[0]["value"];  } else {  yourName = ""; }
      return this.expenseManager.settings_get("your_email");
    }).then((val) {
      if(val != null && val.length > 0) {  yourEmail = val[0]["value"];  } else {  yourEmail = "";  }
      return this.expenseManager.settings_get("monthly_expense_cap");
    }).then((val) {
      if(val != null && val.length > 0) {  monthly_expense_cap = val[0]["value"];  } else {  monthly_expense_cap = "";  }
      return this.expenseManager.settings_get("weekly_expense_cap");
    }).then((val) {
      if(val != null && val.length > 0) {  weekly_expense_cap = val[0]["value"];  } else {  weekly_expense_cap = "";  }
      return this.expenseManager.settings_get("daily_expense_cap");
    }).then((val) {
      if(val != null && val.length > 0) {  daily_expense_cap = val[0]["value"];  } else {  daily_expense_cap = "";  }
      if(!is_mounted || !mounted) { return; }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // set default values
    final TextEditingController yourNameController = TextEditingController();
    yourNameController.text = yourName;
    final TextEditingController yourEmailController = TextEditingController();
    yourEmailController.text = yourEmail;
    final TextEditingController monthlyLimitController = TextEditingController();
    monthlyLimitController.text = monthly_expense_cap;
    final TextEditingController weeklyLimitController = TextEditingController();
    weeklyLimitController.text = weekly_expense_cap;
    final TextEditingController dailyLimitController = TextEditingController();
    dailyLimitController.text = daily_expense_cap;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
        TextField(
          
          keyboardType: TextInputType.text,
            controller: yourNameController,
            decoration: new InputDecoration(
              hintText: "Your Name"
            ),
            style: TextStyle(
              fontSize: 20
            )
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: TextField(
              keyboardType: TextInputType.emailAddress,
              controller: yourEmailController,
              decoration: new InputDecoration(
                hintText: "Your Email"
              ),
              style: TextStyle(
                fontSize: 20
              )
            )
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Text("Your Monthly Limit (\$)",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: monthlyLimitController,
                  decoration: new InputDecoration(
                    hintText: "Monthly Limit"
                  ),
                  style: TextStyle(
                    fontSize: 20
                  )
                ),
              ]
            )
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Text("Your Weekly Limit (\$)",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: weeklyLimitController,
                  decoration: new InputDecoration(
                    hintText: "Weekly Limit"
                  ),
                  style: TextStyle(
                    fontSize: 20
                  )
                ),
              ]
            )
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Text("Your Daily Limit (\$)",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: dailyLimitController,
                  decoration: new InputDecoration(
                    hintText: "Daily Limit"
                  ),
                  style: TextStyle(
                    fontSize: 20
                  )
                ),
              ]
            )
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: RaisedButton(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color(0xFF0D47A1),
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(left: 40, right: 40, top: 12, bottom: 12),
                child: Text("Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                )
              ),
              onPressed: () {
                // get values from textfield
                yourName = yourNameController.text.toString();
                yourEmail = yourEmailController.text.toString();
                monthly_expense_cap = monthlyLimitController.text.toString();
                weekly_expense_cap = weeklyLimitController.text.toString();
                daily_expense_cap = dailyLimitController.text.toString();

                // save settings to database
                expenseManager.settings_set("your_name", yourName).then((_) {
                  return expenseManager.settings_set("your_email", yourEmail);
                }).then((_) {
                  expenseManager.settings_set("monthly_expense_cap", monthly_expense_cap);
                }).then((_) {
                  return expenseManager.settings_set("weekly_expense_cap", weekly_expense_cap);
                }).then((_) {
                  return expenseManager.settings_set("daily_expense_cap", daily_expense_cap);
                }).then((_) {
                  if(!is_mounted) { return; }
                  setState(() {});
                });
              },
              )
          )
        ]
      )
    );
  }
}