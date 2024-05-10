import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User? _user;
  late String _email;
  TextEditingController? _nameController;
  TextEditingController? _ageController;
  TextEditingController? _contactNumberController;
  TextEditingController? _organizationController;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      setState(() {
        _email = _user!.email!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile', style: TextStyle(color: Colors.yellow),),
        backgroundColor: Color(0xFF273671), 
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        )// Instagram-like color
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.grey[200], // Light grey background color
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(_email).get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (!snapshot.hasData || snapshot.data!.data() == null) {
                return Text('No data found for this user');
              }

              Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

              _nameController = TextEditingController(text: userData['Name'] ?? '');
              _ageController = TextEditingController(text: userData['age'] ?? '');
              _contactNumberController = TextEditingController(text: userData['contactNumber'] ?? '');
              _organizationController = TextEditingController(text: userData['organization'] ?? '');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   'Profile Information',
                  //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(height: 20),
                  _buildProfileItem('Email', _email),
                  _buildEditableProfileItem('Name', _nameController!),
                  _buildEditableProfileItem('Age', _ageController!),
                  _buildEditableProfileItem('Contact Number', _contactNumberController!),
                  _buildEditableProfileItem('Organization', _organizationController!),
                  SizedBox(height: 20),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text('Save', style: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.w500)),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF273671), // Instagram-like blue color for the button
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label + ':',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProfileItem(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + ':',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              fillColor: Colors.white, // White background for text field
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(_email).set({
      'Name': _nameController!.text.trim(),
      'age': _ageController!.text.trim(),
      'contactNumber': _contactNumberController!.text.trim(),
      'organization': _organizationController!.text.trim(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile Updated Successfully')),
    );
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _ageController?.dispose();
    _contactNumberController?.dispose();
    _organizationController?.dispose();
    super.dispose();
  }
}
