import 'dart:async';

import 'package:path/path.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/expense.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseManager {
  bool firstStart;
  bool connected;
  Database database;

  MyHomePageState myHomePageState = null;

  ExpenseManager() {
    firstStart = false;
    connected = false;
  }

  Future<void> connect() async {
    // If this was first start, then these tables would be created successfully
    database = await openDatabase("expense.db", version: 1);
    try {
      await database.execute("CREATE TABLE expense(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT, expense_type TEXT, description TEXT, price DOUBLE, expense_date DATE);");
    } on DatabaseException {
      firstStart = true;
    }
    try {
      await database.execute("CREATE TABLE settings(name TEXT, value TEXT);");
    } on DatabaseException {
      firstStart = true;
    }
    List<Map> val = await settings_get("daily_expense_cap");
    if(val.length == 0) {
      await settings_insert("daily_expense_cap", "");
    }
    val = await settings_get("monthly_expense_cap");
    if(val.length == 0) {
      await settings_insert("monthly_expense_cap", "");
    }
    val = await settings_get("weekly_expense_cap");
    if(val.length == 0) {
      await settings_insert("weekly_expense_cap", "");
    }
    val = await settings_get("your_name");
    if(val.length == 0) {
      await settings_insert("your_name", "");
    }
    val = await settings_get("your_email");
    if(val.length == 0) {
      await settings_insert("your_email", "");
    }
    connected = true;
  }

  onConnected(Function func) {
    // wait until, connection was established,
    // once done, call the function
    if(database == null) {
      Timer.periodic(const Duration(milliseconds: 150), (timer) {
        if(connected) {
          func();
          timer.cancel();
        }
      });
    } else {
      func();
    }
  }

  Future<void> insert(Expense expense) async {
    // insert expense into database
    return database.transaction((t) {
      return t.rawInsert(
        "INSERT INTO expense(name, expense_type, price, description, expense_date) VALUES(?, ?, ?, ?, ?);",
        [expense.name, expense.expense_type, expense.price, expense.description, expense.date]
      );
    });
  }

  Future<void> delete(int expenseId) async {
    // run SQL query for delete from expenses
    return await database.delete("expense WHERE id=" + expenseId.toString() + ";");
  }

  Future<List<Map>> getExpensesOfToday() async {
    DateTime date = DateTime.now();
    String m_str = date.month.toString();
    m_str = m_str.length == 1 ? "0"+m_str : m_str;
    String d_str = date.day.toString();
    d_str = d_str.length == 1 ? "0"+d_str : d_str;
    String _date = date.year.toString() + "-" + m_str + "-" + d_str;
    // run SQL query to get all expenses of today
    return await database.rawQuery("SELECT * FROM expense WHERE expense_date = \"" + _date + "\";");
  }

  Future<List<Map>> getAllExpenses() async {
    // run SQL query to get expenses of all time
    return await database.rawQuery("SELECT * FROM expense;");
  }

  Future<List<Map>> getTotalExpensesOfMonth() async {
    return await database.rawQuery("SELECT SUM(price) AS total FROM expense WHERE strftime('%m', 'now') = strftime('%m', expense_date);");
  }

  Future<List<Map>> getTotalExpensesOfWeek() async {
    return await database.rawQuery("SELECT SUM(price) AS total FROM expense WHERE DATE(expense_date) >= DATE('now', 'weekday 0', '-7 days');");
  }

  Future<List<Map>> settings_get(String key) async {
    return await database.rawQuery("SELECT value FROM settings WHERE name=?;", [key]);
  }

  Future<void> settings_set(String key, String value) async {
    return await database.rawUpdate("UPDATE settings SET value=? WHERE name=?;", [value, key]);
  }

  Future<void> settings_insert(String key, String value) async {
    return await database.transaction((t) {
      return t.rawInsert(
        "INSERT INTO settings(name, value) VALUES(?, ?);",
        [key, value]
      );
    });
  }

}