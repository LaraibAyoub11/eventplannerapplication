import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/Bugdet.dart';
import 'package:event/Task.dart';
import 'package:event/guestlist.dart';
import 'package:flutter/material.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventName;
  final Uint8List imageBytes;
  final String eventDate;

  EventDetailScreen({
    required this.eventName,
    required this.imageBytes,
    required this.eventDate,
  });

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  DateTime selectedDate = DateTime.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchEventData(); // Load event data from Firestore when the screen loads
  }

  // Function to fetch event data from Firestore
  Future<void> _fetchEventData() async {
    DocumentSnapshot snapshot =
        await firestore.collection('events').doc(widget.eventName).get();
    if (snapshot.exists) {
      setState(() {
        selectedDate = (snapshot['selectedDate'] as Timestamp).toDate();
      });
    }
  }

  // Function to update the event date in Firestore
  Future<void> _updateEventDate() async {
    await firestore.collection('events').doc(widget.eventName).update({
      'selectedDate': selectedDate,
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _updateEventDate(); // Save the updated date to Firestore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            widget.eventName,
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.memory(
                widget.imageBytes,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Date with Calendar Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedDate.toLocal()}'.split(' ')[0],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                        ),
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Additional Sections (Guests, Tasks, Budget)
                  _buildSection(
                    title: 'Guests',
                    subtitle: 'List of people invited',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GuestListScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _buildSection(
                    title: 'Tasks',
                    subtitle: 'To-do list',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TaskListScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _buildSection(
                    title: 'Budget',
                    subtitle: 'Spending',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BudgetScreen(
                            eventName: widget.eventName,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each section with an aesthetic approach
  Widget _buildSection({
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: onPressed,
            child: Text('Manage'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueGrey,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
