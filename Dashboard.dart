import 'dart:io';
import 'package:event/DetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, String>> events = [];

  // Function to open the dialog to add a new event
  Future<void> _showAddEventDialog() async {
    final TextEditingController eventNameController = TextEditingController();
    final TextEditingController organizerNameController =
        TextEditingController();
    XFile? selectedImage;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eventNameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: organizerNameController,
                decoration: const InputDecoration(labelText: 'Organizer Name'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  selectedImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (selectedImage != null) {
                    setState(() {}); // Update UI after image selection
                  }
                },
                child: const Text('Upload Image'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (eventNameController.text.isNotEmpty &&
                  organizerNameController.text.isNotEmpty &&
                  selectedImage != null) {
                setState(() {
                  events.add({
                    'eventType': eventNameController.text,
                    'organizer': organizerNameController.text,
                    'image': selectedImage!.path,
                  });
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please complete all fields')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple,
                Colors.purpleAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text('Event Dashboard'),
            backgroundColor: Colors
                .transparent, // Keep background transparent to show gradient
            elevation: 0, // Remove shadow to keep the gradient clean
          ),
        ),
      ),
      body: events.isNotEmpty
          ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 cards per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: EdgeInsets.all(10),
              itemCount: events.length,
              itemBuilder: (context, index) {
                String eventName = events[index]['eventType']!;
                String imagePath = events[index]['image']!;
                return _buildEventCard(eventName, imagePath);
              },
            )
          : Center(child: const Text('No events added yet!')),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple,
              Colors.purpleAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: _showAddEventDialog,
          child: const Icon(Icons.add),
          backgroundColor: Colors.transparent, // Make background transparent
          elevation: 0, // Remove elevation to keep it flat
        ),
      ),
    );
  }

  // Method to build individual event cards
  Widget _buildEventCard(String eventName, String imagePath) {
    return GestureDetector(
      onTap: () {
        // Navigate to Event Detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(
              eventName: eventName,
              imageUrl: imagePath,
              eventDate: '2024-10-22',
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                eventName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
