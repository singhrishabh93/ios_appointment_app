import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  late TextEditingController _emailController;
  late TextEditingController _contactNumberController;
  late TextEditingController _helpController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _contactNumberController = TextEditingController();
    _helpController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _contactNumberController.dispose();
    _helpController.dispose();
    super.dispose();
  }

  Future<void> _sendHelpRequest() async {
    String email = _emailController.text.trim();
    String contactNumber = _contactNumberController.text.trim();
    String help = _helpController.text.trim();
    String ticketNumber = Random().nextInt(999999).toString().padLeft(6, '0');

    // Generate a random ticket number
    String docId = 'ticket$ticketNumber';

    await FirebaseFirestore.instance.collection('help').doc(docId).set({
      'email': email,
      'contactNumber': contactNumber,
      'help': help,
      'ticketNumber': ticketNumber,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Help request sent successfully. Your ticket number is $ticketNumber')),
    );

    // Clear text fields after sending the help request
    _emailController.clear();
    _contactNumberController.clear();
    _helpController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help', style: TextStyle(color: Colors.yellow
        ),),
        backgroundColor: Color(0xFF273671),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        )//
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email Address:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your email address',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Contact Number:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            TextField(
              controller: _contactNumberController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your contact number',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Help/Query:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            TextField(
              controller: _helpController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your message',
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF273671),
                ),
                onPressed: _sendHelpRequest,
                child: Text('Submit',style: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
