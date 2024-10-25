import 'package:flutter/material.dart';

class GuestListScreen extends StatefulWidget {
  @override
  _GuestListScreenState createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  // List to store guests
  List<Map<String, dynamic>> guests = [];

  // Search Controller
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Method to filter guests based on search query
  List<Map<String, dynamic>> get filteredGuests {
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    guests.add({
                      'name': nameController.text,
                      'status': 'pending',
                    });
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
            style: TextStyle(color: Colors.white), // Text color for contrast
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent, // Transparent to show gradient
          elevation: 0, // Remove shadow to keep the gradient clean
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
              child: ListView.builder(
                itemCount: filteredGuests.length,
                itemBuilder: (context, index) {
                  final guest = filteredGuests[index];
                  return _buildGuestTile(guest);
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
  Widget _buildGuestTile(Map<String, dynamic> guest) {
    // Change tile color to pink if confirmed
    Color tileColor = guest['status'] == 'confirmed'
        ? Colors.purple // Use pink color for confirmed guests
        : Colors.grey.shade300; // Use grey for pending guests

    IconData statusIcon =
        guest['status'] == 'confirmed' ? Icons.check_circle : Icons.access_time;
    Color iconColor = guest['status'] == 'confirmed'
        ? Color.fromARGB(255, 197, 45, 172)
        : Colors.grey;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: tileColor, // Use the updated color
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: Text(
          guest['name'],
          style: TextStyle(
              color: guest['status'] == 'confirmed'
                  ? const Color.fromARGB(
                      255, 235, 233, 235) // Use pink color for confirmed guests
                  : Color.fromARGB(255, 11, 11, 11)), // Text color for contrast
        ),
        trailing: Icon(statusIcon, color: iconColor),
        onTap: () {
          setState(() {
            // Toggle the status of the guest when tapped
            guest['status'] =
                guest['status'] == 'pending' ? 'confirmed' : 'pending';
          });
        },
      ),
    );
  }
}
