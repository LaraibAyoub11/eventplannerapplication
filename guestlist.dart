import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GuestListScreen extends StatefulWidget {
  @override
  _GuestListScreenState createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  // Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Search Controller
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Method to filter guests based on search query
  List<DocumentSnapshot> filterGuests(List<DocumentSnapshot> guests) {
    if (searchQuery.isEmpty) {
      return guests;
    } else {
      return guests
          .where((guest) =>
              guest['name'].toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
  }

  // Method to open dialog and add a new guest
  void _openAddGuestDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        return AlertDialog(
          title: Text('Add Guest'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Guest Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // Add guest to Firestore
                  firestore.collection('guests').add({
                    'name': nameController.text,
                    'status': 'pending',
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
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
            'Event Guest Manager',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search guests',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16),
            // Guest List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('guests').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: const Text('No guests added yet!'));
                  }

                  final filteredGuests = filterGuests(snapshot.data!.docs);

                  return ListView.builder(
                    itemCount: filteredGuests.length,
                    itemBuilder: (context, index) {
                      final guest = filteredGuests[index];
                      return _buildGuestTile(guest);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddGuestDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  // Method to build each guest tile with color change on confirmed
  Widget _buildGuestTile(DocumentSnapshot guest) {
    final guestData = guest.data() as Map<String, dynamic>;
    final guestStatus = guestData['status'];
    final guestName = guestData['name'];

    // Change tile color to pink if confirmed
    Color tileColor =
        guestStatus == 'confirmed' ? Colors.purple : Colors.grey.shade300;

    IconData statusIcon =
        guestStatus == 'confirmed' ? Icons.check_circle : Icons.access_time;
    Color iconColor = guestStatus == 'confirmed'
        ? Color.fromARGB(255, 197, 45, 172)
        : Colors.grey;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: Text(
          guestName,
          style: TextStyle(
              color: guestStatus == 'confirmed'
                  ? const Color.fromARGB(255, 235, 233, 235)
                  : Color.fromARGB(255, 11, 11, 11)),
        ),
        trailing: Icon(statusIcon, color: iconColor),
        onTap: () {
          // Toggle the status of the guest when tapped and update Firestore
          final newStatus = guestStatus == 'pending' ? 'confirmed' : 'pending';
          firestore.collection('guests').doc(guest.id).update({
            'status': newStatus,
          });
        },
      ),
    );
  }
}
