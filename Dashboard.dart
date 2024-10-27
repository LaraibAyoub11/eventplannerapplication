import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading assets
import 'DetailScreen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Uint8List? selectedImageBytes;
  String selectedEventType = 'Wedding';
  final TextEditingController organizerNameController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  // Function to open the dialog to add a new event
  Future<void> _showAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedEventType,
                  items: <String>[
                    'Wedding',
                    'Birthday',
                    'Engagement',
                    'Graduation Party',
                    'Farewell'
                  ].map((String eventType) {
                    return DropdownMenuItem<String>(
                      value: eventType,
                      child: Text(eventType),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    setDialogState(() {
                      selectedEventType = value!;
                    });
                    selectedImageBytes =
                        await _getImageBytesForEventType(selectedEventType);
                    setDialogState(
                        () {}); // Update dialog UI after loading image
                  },
                  decoration: InputDecoration(labelText: 'Event Type'),
                ),
                TextField(
                  controller: organizerNameController,
                  decoration:
                      const InputDecoration(labelText: 'Organizer Name'),
                ),
                if (selectedImageBytes !=
                    null) // Display the selected image preview
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.memory(selectedImageBytes!,
                        height: 100, fit: BoxFit.cover),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (organizerNameController.text.isNotEmpty &&
                    selectedImageBytes != null) {
                  // Add event to Firestore
                  await firestore.collection('events').add({
                    'eventType': selectedEventType,
                    'organizer': organizerNameController.text,
                    'createdAt': DateTime.now(),
                  });
                  Navigator.pop(context);
                  setState(() {}); // Update UI after adding
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to get image bytes for each event type from assets
  Future<Uint8List> _getImageBytesForEventType(String eventType) async {
    String assetPath = 'assets/images/'; // Base path for assets

    switch (eventType) {
      case 'Wedding':
        assetPath += '1.jpg';
        break;
      case 'Birthday':
        assetPath += '2.jpg';
        break;
      case 'Engagement':
        assetPath += '3.jpg';
        break;
      case 'Graduation Party':
        assetPath += '4.jpg';
        break;
      case 'Farewell':
        assetPath += '5.jpg';
        break;
    }

    // Load the image from assets and convert it to Uint8List
    final byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('events')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: const Text('No events added yet!'));
          }

          final events = snapshot.data!.docs;

          return GridView.builder(
            itemCount: events.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final eventData = events[index].data() as Map<String, dynamic>;
              return _buildEventCard(
                eventData['eventType'] ?? 'Unknown',
                eventData['organizer'] ?? 'Organizer',
                selectedImageBytes!,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _buildEventCard(
      String eventName, String organizer, Uint8List imageBytes) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              eventName: eventName,
              imageBytes: imageBytes,
              eventDate: '2024-10-22',
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.memory(
                imageBytes,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text(
                eventName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
