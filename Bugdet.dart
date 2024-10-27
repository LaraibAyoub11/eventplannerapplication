import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  final String eventName;

  BudgetScreen({required this.eventName});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  double totalBudget = 0.0;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchTotalBudget();
  }

  Future<void> _fetchTotalBudget() async {
    final budgetDoc =
        await firestore.collection('budgets').doc(widget.eventName).get();
    if (budgetDoc.exists) {
      setState(() {
        totalBudget = budgetDoc['totalBudget'];
      });
    } else {
      _askForTotalBudget(); // Prompt for budget if it’s not set yet
    }
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
                firestore.collection('budgets').doc(widget.eventName).set({
                  'totalBudget': initialBudget,
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
        onPressed: _showAddTransactionDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildTransactionList() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('budgets')
          .doc(widget.eventName)
          .collection('transactions')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No transactions yet. Add one using the button below.'),
          );
        }

        final transactions = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...transactions.map((transaction) {
              final data = transaction.data() as Map<String, dynamic>;
              return ListTile(
                leading: Icon(Icons.monetization_on, color: Colors.purple),
                title: Text(data['category']),
                trailing: Text(
                  'PKR ${data['amount'].toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }).toList(),
          ],
        );
      },
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (category.isNotEmpty && amount > 0) {
                  _addTransaction(category, amount);
                  Navigator.of(context).pop();
                } else {
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

  Future<void> _addTransaction(String category, double amount) async {
    await firestore
        .collection('budgets')
        .doc(widget.eventName)
        .collection('transactions')
        .add({
      'category': category,
      'amount': amount,
    });
    // Update the total budget in Firestore
    setState(() {
      totalBudget -= amount;
    });
    await firestore.collection('budgets').doc(widget.eventName).update({
      'totalBudget': totalBudget,
    });
  }
}
