
class Expense {

  String name, description, date, expense_type;
  double price;

  Expense(String name, String expense_type, double price, String description, String date) {
    this.expense_type = expense_type;
    this.name = name;
    this.description = description;
    this.price = price;
    this.date = date;
  }

}