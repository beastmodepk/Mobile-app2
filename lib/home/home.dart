import 'dart:async';

import 'package:expense_tracker/expense.dart';
import 'package:expense_tracker/expense_manager.dart';
import 'package:expense_tracker/home/pie_chart.dart' as pie_chart;
import 'package:flutter/material.dart';

class HomeWidget extends StatefulWidget {
  final BuildContext context;
  final ExpenseManager expenseManager;
  HomeWidgetState homeWidgetState;

  static HomeWidgetState of(BuildContext context) => context.findAncestorStateOfType<HomeWidgetState>();

  HomeWidget(this.context, this.expenseManager) {
    homeWidgetState = HomeWidgetState(context, expenseManager);
  }

  void callSetState() {
    homeWidgetState.callSetState();
  }

  @override
  HomeWidgetState createState() => homeWidgetState;
}

class HomeWidgetState extends State<HomeWidget> {
  BuildContext context;
  ExpenseManager expenseManager;
  String monthly_expense_cap = "";
  String daily_expense_cap = "";
  String weekly_expense_cap = "";
  List<Map> expensesOfToday = null;
  double totalExpensesOfMonth = 0.0, totalExpensesOfWeek = 0.0, totalExpensesOfToday = 0.0;
  bool is_mounted = true;
  String dropDownValue = "Monthly Expenses";

  @override
  void dispose() {
    is_mounted = false;
    super.dispose();
  }

  void callSetState() {
    setState(() {});
  }


  HomeWidgetState(this.context, this.expenseManager) {
    expenseManager.onConnected(() {
      expenseManager.settings_get("monthly_expense_cap").then((val) {
        if(val != null && val.length > 0) {
          monthly_expense_cap = val[0]["value"];
        }
        return expenseManager.settings_get("weekly_expense_cap");
      }).then((val) {
        if(val != null && val.length > 0) {
          weekly_expense_cap = val[0]["value"];
        }
        return expenseManager.settings_get("daily_expense_cap");
      }).then((val) {
        if(val != null && val.length > 0) {
          daily_expense_cap = val[0]["value"];
        }
        return expenseManager.getTotalExpensesOfMonth();
      }).then((val) {
        totalExpensesOfMonth = 0.0;
        if(val != null && val.length > 0) {
          totalExpensesOfMonth = val[0]["total"];
          if(totalExpensesOfMonth == null) { totalExpensesOfMonth = 0; }
        }
        return expenseManager.getTotalExpensesOfWeek();
      }).then((val) {
        totalExpensesOfWeek = 0.0;
        if(val != null && val.length > 0) {
          totalExpensesOfWeek = val[0]["total"];
          if(totalExpensesOfWeek == null) { totalExpensesOfWeek = 0; }
        }
        return expenseManager.getExpensesOfToday();
      }).then((val) {
        expensesOfToday = val;
        if(expensesOfToday != null && expensesOfToday.length > 0) {
          for(int i=0; i<expensesOfToday.length; i++) {
            totalExpensesOfToday += expensesOfToday[i]["price"];
          }
        }
        if(!is_mounted || !mounted) { return; }
        this.setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = new Map<String, double>();
    double used = 0.0, available = 100.0;
    if(dropDownValue == "Monthly Expenses") {
      if(monthly_expense_cap == null || monthly_expense_cap.length == 0) {
        available = -1;
      } else {
        available = double.parse(monthly_expense_cap);
      }
      used = totalExpensesOfMonth;
    } else if(dropDownValue == "Weekly Expenses") {
      if(weekly_expense_cap == null || weekly_expense_cap.length == 0) {
        available = -1;
      } else {
        available = double.parse(weekly_expense_cap);
      }
      used = totalExpensesOfWeek;
    } else if(dropDownValue == "Daily Expenses") {
      if(daily_expense_cap == null || daily_expense_cap.length == 0) {
        available = -1;
      } else {
        available = double.parse(daily_expense_cap);
      }
      used = totalExpensesOfToday;
    }

    if(used == 0) {
      available = 100;
    }
    if(available == -1) {
      used = 0;
      available = 100;
    }

    if(used >= available) {
      used = 100;
      available = 0;
    } else {
      available = available - used;
    }
    dataMap.putIfAbsent("Used", () => used);
    dataMap.putIfAbsent("Available", () => available);

    List<Color> colorList = new List<Color>();
    colorList.add((available * 100.0) / (available + used) < 10 ? Color.fromRGBO(255, 127, 80, 1) : Color.fromRGBO(76, 139, 245, 1));
    colorList.add((available * 100.0) / (available + used) < 10 ? Color.fromRGBO(222, 82, 70, 1) : Color.fromRGBO(52, 168, 83, 1));

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: new EdgeInsets.all(20),
            child: DropdownButton<String>(
              value: dropDownValue,
              items: <String>['Monthly Expenses', 'Weekly Expenses', "Daily Expenses"].map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 22,
                fontWeight: FontWeight.bold
              ),
              onChanged: (String newValue) {
                dropDownValue = newValue;
                setState(() {});
              },
            )
          ),

          Padding(
            padding: new EdgeInsets.only(bottom: 50, left: 30, right: 30),
            child: pie_chart.BuildPieChart(context, dataMap, colorList)
          ),

          SizedBox(
            width: double.maxFinite,
            child: PhysicalModel(
              borderRadius: BorderRadius.circular(25.0),
              color: Color.fromRGBO(113, 82, 255, 1),
              child: Column(
                children: buildExpensesOfToday(),
              )
            )
          )
        ],
      )
    );
  }

  List<Widget> buildExpensesOfToday() {
    if(expensesOfToday == null || expensesOfToday.isEmpty) {
      return <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 18, top: 14),
          child: Text("Today's Expenses",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(255, 255, 255, 1)
            )
          )
        ),
        SizedBox(
          width: double.maxFinite,
          child: Padding(
            padding: EdgeInsets.only(top: 18, bottom: 8, left: 25, right: 25),
            child: PhysicalModel(
              color: Color.fromARGB(80, 0, 0, 0),
              borderRadius: BorderRadius.circular(5.0),
              child: Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("No Expenses Yet  ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    Text("😊",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white
                      )
                    )
                  ]
                )
              )
            )
          )
        )
      ];
    } else {
      List<Widget> widgets = <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 10, top: 12),
          child: Text("Today's Expenses",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(255, 255, 255, 1)
            )
          )
        )
      ];
      expensesOfToday.forEach((elem) {
        widgets.add(buildExpense(elem));
      });
      return widgets;
    }
  }

  Widget buildExpense(Map elem) {
    return SizedBox(
      width: double.maxFinite,
      child: Padding(
        padding: EdgeInsets.only(top: 0, bottom: 8, left: 25, right: 25),
        child: PhysicalModel(
          color: Color.fromARGB(80, 0, 0, 0),
          borderRadius: BorderRadius.circular(5.0),
          child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                
                Row(
                  children: <Widget>[
                    Text(elem["name"],
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8, top: 2),
                      child: Container(
                        child: Text(elem["expense_type"], style: TextStyle(color: Colors.grey)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.black87, spreadRadius: 3),
                          ],
                        ),
                      )
                    )
                  ]
                ),
                Text("\$" + elem["price"].toString(),
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.blue
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}