import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String title = "";
  String date = "";
  String time = "";
  String location = "";
  String description = "";

  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title/Name'),
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Date'),
              onChanged: (value) {
                setState(() {
                  date = value;
                });
              },
            ),
            TextField(
              controller: timeController,
              decoration: InputDecoration(labelText: 'Time'),
              onChanged: (value) {
                setState(() {
                  time = value;
                });
              },
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
              onChanged: (value) {
                setState(() {
                  location = value;
                });
              },
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description/Notes'),
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Upload data to Firestore
                FirebaseFirestore.instance
                    .collection('users')
                    .doc('appointment')
                    .collection('active')
                    .doc(title)
                    .set({
                  'date': date,
                  'description': description,
                  'location': location,
                  'time': time,
                  'title': title,
                }).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                    "Appointment Scheduled Successfully",
                    style: TextStyle(fontSize: 18.0),
                  )));
                }).catchError((error) {
                  print("Failed to schedule appointment: $error");
                });
              },
              child: Text('Save/Submit'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: EdgeInsets.all(20.0),
                child: ListView(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: 'Title/Name'),
                      onChanged: (value) {
                        setState(() {
                          title = value;
                        });
                      },
                    ),
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(labelText: 'Date'),
                      onChanged: (value) {
                        setState(() {
                          date = value;
                        });
                      },
                    ),
                    TextField(
                      controller: timeController,
                      decoration: InputDecoration(labelText: 'Time'),
                      onChanged: (value) {
                        setState(() {
                          time = value;
                        });
                      },
                    ),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(labelText: 'Location'),
                      onChanged: (value) {
                        setState(() {
                          location = value;
                        });
                      },
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description/Notes'),
                      onChanged: (value) {
                        setState(() {
                          description = value;
                        });
                      },
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        // Upload data to Firestore
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc('appointment')
                            .collection('active')
                            .doc(title)
                            .set({
                          'date': date,
                          'description': description,
                          'location': location,
                          'time': time,
                          'title': title,
                        }).then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                            "Appointment Scheduled Successfully",
                            style: TextStyle(fontSize: 18.0),
                          )));
                        }).catchError((error) {
                          print("Failed to schedule appointment: $error");
                        });
                      },
                      child: Text('Save/Submit'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
