import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  final String eventName;

  BudgetScreen({required this.eventName});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  double totalBudget = 0.0;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    // Show dialog to ask for the total budget when the screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askForTotalBudget();
    });
  }

  void _askForTotalBudget() {
    double initialBudget = 0.0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Total Budget (PKR)'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Total Budget'),
            onChanged: (value) {
              initialBudget = double.tryParse(value) ?? 0.0;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  totalBudget = initialBudget;
                });
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName), // Display the event name dynamically
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.purpleAccent],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Total Budget Section with Purple Gradient
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade800],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'PKR ${totalBudget.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Total Budget',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Transaction List
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildTransactionList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildTransactionList() {
    if (transactions.isEmpty) {
      return Center(
        child: Text('No transactions yet. Add one using the button below.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // Display the list of transactions
        ...transactions.map((transaction) {
          return ListTile(
            leading: Icon(Icons.monetization_on, color: Colors.purple),
            title: Text(transaction['category']),
            trailing: Text(
              'PKR ${transaction['amount'].toStringAsFixed(2)}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }).toList(),
      ],
    );
  }

  Future<void> _showAddTransactionDialog() async {
    String category = '';
    double amount = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Category'),
                onChanged: (value) {
                  category = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Amount (PKR)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (category.isNotEmpty && amount > 0) {
                  setState(() {
                    // Add the transaction to the list
                    transactions.add({
                      'category': category,
                      'amount': amount,
                    });
                    totalBudget -=
                        amount; // Deduct the amount from the total budget
                  });
                  Navigator.of(context).pop();
                } else {
                  // Show error message if category or amount is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Please enter a valid category and amount.'),
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
