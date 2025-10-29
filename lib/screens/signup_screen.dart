import 'package:flutter/material.dart';
import 'success_screen.dart'; // Import for navigation

class SignupScreen extends StatefulWidget {
    @override
    _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
    final TextEditingController _nameController = TextEditingController();

    void _submitForm() {
        // Your form submission logic here
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SuccessScreen(userName: _nameController.text),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        // Your build method implementation here
    }
}