import 'package:flutter/material.dart';
import 'package:expense_tracker/expense_manager.dart';
import 'package:expense_tracker/home/pie_chart.dart' as pie_chart;


class ExpenseHistory extends StatefulWidget {

  final BuildContext context;
  final ExpenseManager expenseManager;

  static ExpenseHistoryState of(BuildContext context) => context.findAncestorStateOfType<ExpenseHistoryState>();

  ExpenseHistory(this.context, this.expenseManager);

  @override
  ExpenseHistoryState createState() => ExpenseHistoryState(context, expenseManager);
}

class ExpenseHistoryState extends State<ExpenseHistory> {
  BuildContext context;
  ExpenseManager expenseManager;
  bool is_mounted = true;
  String selectedMode = "Day";
  List<Map> allExpenses;
  String lookBy = "Look by Types", daily_expense_cap = "";
  List<Color> allColorsList;

  ExpenseHistoryState(this.context, this.expenseManager);

  @override
  void dispose() {
    is_mounted = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // retrieve all settings keys required and refresh
    allExpenses = null;
    expenseManager.getAllExpenses().then((val) {
      allExpenses = val;
      return expenseManager.settings_get("daily_expense_cap");
    }).then((val) {
      if(val != null && val.length > 0) {
        daily_expense_cap = val[0]["value"];
      }
      if(!is_mounted) { return; }
      setState(() {});
    });

    // distinct colors for piechart
    allColorsList = <Color>[
      Color.fromRGBO(255, 255, 0, 1),
      Color.fromRGBO(0, 234, 255, 1),
      Color.fromRGBO(170, 0, 255, 1),
      Color.fromRGBO(255, 127, 0, 1),
      Color.fromRGBO(191, 255, 0, 1),
      Color.fromRGBO(255, 0, 0, 1),
      Color.fromRGBO(0, 149, 255, 1),
      Color.fromRGBO(255, 0, 170, 1),
      Color.fromRGBO(255, 212, 0, 1),
      Color.fromRGBO(0, 64, 255, 1),
      Color.fromRGBO(237, 185, 185, 1),
      Color.fromRGBO(185, 215, 237, 1),
      Color.fromRGBO(231, 233, 185, 1),
      Color.fromRGBO(143, 35, 35, 1),
      Color.fromRGBO(35, 98, 143, 1),
      Color.fromRGBO(143, 106, 35, 1),
      Color.fromRGBO(107, 35, 143, 1),
      Color.fromRGBO(79, 143, 35, 1),
      Color.fromRGBO(115, 115, 0, 1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: this.buildChildren()
      )
    );
  }

  List<Widget> buildChildren() {
    // Prepare `Day` and `Month` tabs
    List<Widget> children = new List<Widget>();
    Row buttonRow = Row(children: <Widget>[
      buildButton("Day", selectedMode == "Day"),
      buildButton("Month", selectedMode == "Month")
    ]);

    children.add(buttonRow);

    if(allExpenses == null || allExpenses.length == 0) {
      children.add(noExpensesWidget());
      return children;
    }

    if(selectedMode == "Day") {
      buildHistoryForDay(children);
    } else if(selectedMode == "Month") {
      buildHistoryForMonth(children);
    }

    return children;
  }

  buildButton(String text, bool selected) {
    // disable button, if not selected
    if(selected) {
      return ButtonTheme(
          minWidth: MediaQuery.of(context).size.width * 0.5 - 12,
          child: RaisedButton(
            textColor: Colors.white,
            onPressed: () { selectedMode = text; setState(() {}); },
            child: Text(text)
          ),
        );
    } else {
      return ButtonTheme(
          minWidth: MediaQuery.of(context).size.width * 0.5 - 12,
          child: FlatButton(
            color: Colors.grey[300],
            onPressed: () { selectedMode = text; setState(() {}); },
            child: Text(text)
          ),
        );
    }
  }

  Widget noExpensesWidget() {
    return Center(
      child: SizedBox(
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
    );
  }

  void buildHistoryForDay(List<Widget> children) {
    Map<String, List<Map>> history = new Map<String, List<Map>>();
    Map temp;
    String date, new_date;
    for(int i=0; i<allExpenses.length; i++) {
      temp = allExpenses[i];
      date = temp["expense_date"];
      new_date = parse_month(date) + " - " + parse_day(date) + " - " + parse_year(date);
      history.putIfAbsent(new_date, () => new List<Map>());
      history[new_date].add(temp);
    }

    buildHistoryForMap(children, history);
  }


  void buildHistoryForMonth(List<Widget> children) {
    Map<String, List<Map>> history = new Map<String, List<Map>>();
    Map temp;
    String date, month;
    for(int i=0; i<allExpenses.length; i++) {
      temp = allExpenses[i];
      date = temp["expense_date"];
      month = parse_month(date) + " - " + parse_year(date);
      history.putIfAbsent(month, () => new List<Map>());
      history[month].add(temp);
    }
    buildHistoryForMap(children, history);
  }

  void buildHistoryForMap(List<Widget> children, Map<String, List<Map>> history) {
    List<String> all_keys = history.keys.toList();
    all_keys.sort((b, a) => a.compareTo(b));
    String key;
    List<Map> group;

    for(int i=0; i<all_keys.length; i++) {
      key = all_keys[i];
      group = history[key];

      children.add(buildTrigger(key, group));
    }
  }

  Widget buildTrigger(String key, List<Map> group) {

    return Center(

      child: SizedBox(
          width: double.maxFinite,
          child: Padding(
            padding: EdgeInsets.only(top: 18, bottom: 8, left: 25, right: 25),
            child: PhysicalModel(
              color: Color.fromARGB(192, 160, 160, 160),
              borderRadius: BorderRadius.circular(5.0),
              child: InkWell(
                splashColor: Colors.black,
                onTap: () {
                  showDialog(context: context, builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        Map<String, double> dataMap = new Map<String, double>();
                        List<Color> colorList = new List<Color>();
                        double used = 0.0, available = 100.0;
                        if(lookBy.substring(8) == "Types") {
                          for(int j=0; j< group.length; j++) {
                            Map elem = group[j];

                            dataMap.putIfAbsent(elem["expense_type"], () => 0.0);
                            dataMap[elem["expense_type"]] += elem["price"];
                          }
                        } else if(lookBy.substring(8) == "Transactions") {
                          if(daily_expense_cap == null || daily_expense_cap.length == 0) {
                            available = -1;
                          } else {
                            available = double.parse(daily_expense_cap);
                          }

                          for(int j=0; j< group.length; j++) {
                            Map elem = group[j];
                            used += elem["price"];
                          }

                          if(used == 0) {
                            available = 100;
                          }
                          if(available == -1) {
                            used = 0;
                            available = 100;
                          }

                          dataMap.putIfAbsent("Used", () => used);
                          dataMap.putIfAbsent("Available", () => available);

                          colorList.add((available * 100.0) / (available + used) < 10 ? Color.fromRGBO(255, 127, 80, 1) : Color.fromRGBO(76, 139, 245, 1));
                          colorList.add((available * 100.0) / (available + used) < 10 ? Color.fromRGBO(222, 82, 70, 1) : Color.fromRGBO(52, 168, 83, 1));
                        }

                        List<Widget> popUpBody = <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(lookBy.substring(8),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),

                            Padding(
                              padding: new EdgeInsets.only(bottom: 50, left: 30, right: 30),
                              child: pie_chart.BuildPieChart(context, dataMap, lookBy.substring(8) == "Types" ? allColorsList : colorList)
                            ),

                            Padding(
                            padding: new EdgeInsets.only(bottom: 10),
                            child: DropdownButton<String>(
                              value: lookBy,
                              items: <String>['Look by Types', 'Look by Transactions'].map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 22,
                              ),
                              onChanged: (String newValue) {
                                lookBy = newValue;
                                setState(() {});
                              },
                            )
                          ),
                        ];

                        for(int j=0; j< group.length; j++) {
                          Map elem = group[j];
                          popUpBody.add(buildChild(elem));
                        }

                        return AlertDialog(
                        title: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: PhysicalModel(
                            color: Color.fromARGB(192, 64, 128, 192),
                            borderRadius: BorderRadius.circular(20.0),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(key,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Close"),
                            onPressed: () { Navigator.of(context).pop(); },
                          )
                        ],
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: popUpBody
                          )
                        )
                      );
                    });
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 25),
                  child: Text(key,
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white
                    )
                  )
                ),
              )
            )
          )
        )
      );
  }

  String parse_year(String dt) {
    return dt.substring(0, 4);
  }

  String parse_month(String dt) {
    return dt.substring(5, 7);
  }

  String parse_day(String dt) {
    return dt.substring(8);
  }

  Widget buildChild(Map elem) {
    return SizedBox(
      width: double.maxFinite,
      child: Padding(
        padding: EdgeInsets.only(top: 0, bottom: 8, left: 25, right: 25),
        child: PhysicalModel(
          color: Color.fromARGB(255, 180, 180, 180),
          borderRadius: BorderRadius.circular(5.0),
          child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    ),
                  ]
                ),
                Row(
                  children: <Widget> [
                    Container(
                        child: Text("\$" + elem["price"].toString(),
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.blue
                          )
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.white, spreadRadius: 4),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: MaterialButton(
                          minWidth: 0,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Delete - " + elem["name"]),
                                  content: Text("Are you sure, you want to delete this Expense?"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("Yes"),
                                      onPressed: () {
                                        expenseManager.delete(elem["id"]).then((_) {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          setState(() {});
                                        });
                                      },
                                    ),
                                    FlatButton(
                                      child: Text("No"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              }
                            );
                          },
                          color: Colors.red,
                          textColor: Colors.white,
                          child: Icon(Icons.close),
                          shape: CircleBorder()
                        )
                      )
                    ]
                  ),
              ]
            )
          )
        )
      )
    );
  }
  
}