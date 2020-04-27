import 'package:expense_tracker/expense.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/expense_manager.dart';
import 'package:expense_tracker/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';


class ExpenseDataWidget extends StatefulWidget {

  final BuildContext context;
  final ExpenseManager expenseManager;
  final MyHomePageState homePageState;

  static _ExpenseDataWidget of(BuildContext context) => context.findAncestorStateOfType<_ExpenseDataWidget>();

  ExpenseDataWidget(this.context, this.expenseManager, this.homePageState);

  @override
  _ExpenseDataWidget createState() => _ExpenseDataWidget(context, expenseManager, homePageState);
}

class _ExpenseDataWidget extends State<ExpenseDataWidget> {
  String _date;
  BuildContext context;
  ExpenseManager expenseManager;
  String expense_type = "Groceries";
  MyHomePageState homePageState;

  _ExpenseDataWidget(this.context, this.expenseManager, this.homePageState);

  @override
  void initState() {
    super.initState();
    DateTime date = DateTime.now();
    String m_str = date.month.toString();
    m_str = m_str.length == 1 ? "0"+m_str : m_str;
    String d_str = date.day.toString();
    d_str = d_str.length == 1 ? "0"+d_str : d_str;
    _date = date.year.toString() + "-" + m_str + "-" + d_str;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController expenseNameController = TextEditingController();
    TextEditingController expensePriceController = TextEditingController();
    TextEditingController expenseDescriptionController = TextEditingController();

    return AlertDialog(
      title: Text("New Expense"),
      actions: <Widget>[
        FlatButton(child: Text("Cancel"), onPressed: () { Navigator.of(context).pop(); },),
        FlatButton(child: Text("Create"), onPressed: () {
          double price;
          try {
            price = double.parse(expensePriceController.text.toString());
          } on FormatException {
            return;
          }
          String name = expenseNameController.text.toString();
          String description = expenseDescriptionController.text.toString();
          Expense expense = Expense(name, expense_type, price, description, _date);
          expenseManager.insert(expense).then((_) {
            return expenseManager.getExpensesOfToday();
          }).then((val) {
            homePageState.setState(() {});
          });
          Navigator.of(context).pop();
        },)
      ],
      
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [ Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  controller: expenseNameController,
                  decoration: new InputDecoration(
                    hintText: "Name"
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.0),
                          border: Border.all(
                            color: Colors.grey, style: BorderStyle.solid, width: 0.80),
                        ),
                        child: DropdownButton<String>(
                          value: expense_type,
                          items: <String>['Groceries', 'Personal care items', 'Fuel', 'Parking', 'Clothing', 'Eating out', 'Entertainment', 'Tobacco / Alchohol', 'Lottery', 'Others'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (String newValue) {
                            expense_type = newValue;
                            setState(() {});
                          },
                        ),
                      ),
                    ]
                  ),
                ),
                TextField(
                  controller: expensePriceController,
                  decoration: new InputDecoration(
                    hintText: "Price"
                  ),
                  keyboardType: TextInputType.number,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    elevation: 4.0,
                    onPressed: () {
                      DatePicker.showDatePicker(context,
                        theme: DatePickerTheme(
                          containerHeight: 210.0,
                        ),
                        showTitleActions: true,
                        minTime: DateTime(2000, 1, 1),
                        maxTime: DateTime(2022, 12, 31),
                        onConfirm: (date) {
                          String m_str = date.month.toString();
                          m_str = m_str.length == 1 ? "0"+m_str : m_str;
                          String d_str = date.day.toString();
                          d_str = d_str.length == 1 ? "0"+d_str : d_str;
                          _date = date.year.toString() + "-" + m_str + "-" + d_str;
                          setState(() { });
                        },
                        currentTime: DateTime.now(), locale: LocaleType.en);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.date_range,
                                      size: 18.0,
                                      color: Colors.indigo,
                                    ),
                                    Text(
                                      " $_date",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Text(
                            "  Change",
                            style: TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                          ),
                        ],
                      ),
                    ),
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: TextField(
                    controller: expenseDescriptionController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: "Description",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Colors.amber,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    maxLines: null,
                    minLines: 2,
                  )
                )]
              ),
          )]
        )
      )
    );
  }
}