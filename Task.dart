import 'package:flutter/material.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // List to store tasks
  List<Map<String, dynamic>> tasks = [];

  // Search Controller
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Method to filter tasks based on search query
  List<Map<String, dynamic>> get filteredTasks {
    if (searchQuery.isEmpty) {
      return tasks;
    } else {
      return tasks
          .where((task) =>
              task['title'].toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
  }

  // Method to open dialog and add a new task
  void _openAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController titleController = TextEditingController();
        return AlertDialog(
          title: Text('Add Task'),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Task Title',
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
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    tasks.add({
                      'title': titleController.text,
                      'isCompleted': false,
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
            'To-Do List',
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
                labelText: 'Search tasks',
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
            // Task List
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return _buildTaskTile(task);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  // Method to build each task tile
  Widget _buildTaskTile(Map<String, dynamic> task) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color:
            task['isCompleted'] ? Colors.green.shade100 : Colors.grey.shade300,
      ),
      child: ListTile(
        title: Text(
          task['title'],
          style: TextStyle(
            color: task['isCompleted'] ? Colors.green : Colors.black,
            decoration: task['isCompleted'] ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Icon(
          task['isCompleted'] ? Icons.check_circle : Icons.check_circle_outline,
          color: task['isCompleted'] ? Colors.green : Colors.grey,
        ),
        onTap: () {
          setState(() {
            // Toggle the completion status of the task when tapped
            task['isCompleted'] = !task['isCompleted'];
          });
        },
      ),
    );
  }
}
