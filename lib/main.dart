import 'package:expense_tracker/expense.dart';
import 'package:expense_tracker/expense_create.dart';
import 'package:expense_tracker/expense_manager.dart';
import 'package:expense_tracker/expense_settings.dart';
import 'package:expense_tracker/home/home.dart';
import 'package:expense_tracker/expense_cap.dart';
import 'package:expense_tracker/expense_history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:path/path.dart';

ExpenseManager expenseManager = ExpenseManager();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Expense Tracker'),
    );
  }
}

class _Page {
  _Page({this.widget});
  final Widget widget;
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin {
  TabController _controller;
  List<_Page> _allPages;
  int current_page = 0;
  int last_page = 0;

  ExpenseSettings expenseSettings;

  @override
  void initState() {
    super.initState();
    expenseSettings = ExpenseSettings(this.context, expenseManager);
    expenseManager.connect().then((_) {
      if(expenseManager.firstStart) {
        
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    // If current page is home page, the button will show,
    // history symbol, but when on history page, the button will
    // show the home symbol
    List<Icon> icons = <Icon>[
      Icon(Icons.history),
      Icon(Icons.home)
    ];
    MyHomePageState homePageState = this;
    ExpenseHistory expenseHistoryWidget = ExpenseHistory(this.context, expenseManager);
    _allPages = <_Page>[
      _Page(widget: HomeWidget(this.context, expenseManager)),
      _Page(widget: expenseHistoryWidget),
      _Page(widget: expenseSettings)
    ];
    // assign tab controller for the pages
    _controller = TabController(vsync: this, length: _allPages.length);
    return new Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 4.0,
        icon: const Icon(Icons.add),
        label: const Text('New Expense'),
        onPressed: () {
          showDialog(context: context, builder: (context) {
            return ExpenseDataWidget(context, expenseManager, homePageState);
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _controller,
          children: _allPages.map<Widget>((_Page page) {
            return SafeArea(
              top: false,
              bottom: false,
              child: Container(
                  key: ObjectKey(page.widget),
                  padding: const EdgeInsets.all(12.0),
                  child: page.widget),
            );
          }).toList()),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
                icon: current_page < 2 ? icons[current_page] : icons[last_page],
                onPressed: () {
                  if(current_page == 2) {
                    current_page = last_page;
                    last_page = 2;
                  }
                  if(current_page == 0) {
                    last_page = 0;
                    current_page = 1;
                  } else if(current_page == 1) {
                    last_page = 1;
                    current_page = 0;
                  }
                  _controller.animateTo(current_page);
                  homePageState.setState(() {});
                }),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                if(current_page == 2) {
                  return;
                }
                last_page = 0;
                current_page = 2;
                _controller.animateTo(current_page);
                homePageState.setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}


void historyAndHome(ExpenseManager expenseManager) {
  
}