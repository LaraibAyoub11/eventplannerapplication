import 'package:event/login.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'Dashboard.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _eventRoleController = TextEditingController();
  final AuthService _authService = AuthService();

  void _signup() async {
    print('Attempting to sign up with email: ${_emailController.text}');
    try {
      final user = await _authService.signUp(
        _nameController.text,
        _phoneController.text,
        _eventRoleController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        print('Signup successful');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        print('Signup failed with unknown error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed with unknown error')),
        );
      }
    } catch (e) {
      print('Signup error caught: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: _eventRoleController,
                decoration: InputDecoration(
                    labelText: 'Event Role (e.g., Organizer, Guest)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Sign Up', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Text(
                  'Already have an account? Login',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
