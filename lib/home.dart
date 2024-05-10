import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';
import 'package:ios_appointment_app/forgot_password.dart';
import 'package:ios_appointment_app/help_page.dart';
import 'package:ios_appointment_app/login.dart';
import 'package:ios_appointment_app/profile_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          "My Appointments",
          style:
              TextStyle(color: Color(0xFF273671), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200],
        child: ScheduledAppointments(),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            SizedBox(
              height: 50,
            ),
            ListTile(
              title: Text('Profile Settings'),
              onTap: () {
                Get.to(() => ProfilePage());
              },
            ),
            ListTile(
              title: Text('Manage Password'),
              onTap: () {
                Get.to(() => ForgotPassword());
              },
            ),
            ListTile(
              title: Text('Help'),
              onTap: () {
                Get.to(() => HelpPage());
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LogIn()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return ScheduleAppointmentForm();
            },
          );
        },
        child: Icon(Icons.add, color: Color(0xFF273671)),
      ),
    );
  }
}

class ScheduledAppointments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String email = FirebaseAuth.instance.currentUser!.email!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .collection('appointment')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text(
                  'No appointments scheduled. Click on \nthe + button to schedule an appointment'));
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return AppointmentCard(data: data);
          }).toList(),
        );
      },
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AppointmentCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = data['Title'];
    String date = data['Date'];
    String time = data['Time'];
    String location = data['Location'];
    String description = data['Description'];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Color(0xFF273671),
        elevation: 5,
        child: ListTile(
          title: Text(title,
              style:
                  TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: $date', style: TextStyle(color: Colors.white)),
              Text('Time: $time', style: TextStyle(color: Colors.white)),
              Text('Location: $location',
                  style: TextStyle(color: Colors.white)),
              Text('Description: $description',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  // Edit button logic
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EditAppointmentDialog(data: data);
                    },
                  );
                },
                icon: Icon(Icons.edit, color: Colors.blue),
              ),
              IconButton(
                onPressed: () {
                  // Delete button logic
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Delete'),
                        content: Text(
                            'Are you sure you want to delete this appointment?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(
                                      FirebaseAuth.instance.currentUser!.email!)
                                  .collection('appointment')
                                  .doc(title)
                                  .delete()
                                  .then((value) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    "Appointment Deleted Successfully",
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                ));
                                Navigator.pop(context); // Close the dialog
                              }).catchError((error) {
                                print("Failed to delete appointment: $error");
                              });
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
          onTap: () {
            // Handle onTap if needed
          },
        ),
      ),
    );
  }
}

class EditAppointmentDialog extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditAppointmentDialog({Key? key, required this.data}) : super(key: key);

  @override
  _EditAppointmentDialogState createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<EditAppointmentDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _title;
  late String _location;
  late String _description;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _title = widget.data['Title'];
    _location = widget.data['Location'];
    _description = widget.data['Description'];
    _selectedDate = DateFormat('dd/MM/yyyy').parse(widget.data['Date']);
    _selectedTime =
        TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(widget.data['Time']));
    _titleController.text = _title;
    _locationController.text = _location;
    _descriptionController.text = _description;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit Appointment',
        style: TextStyle(color: Color(0xFF273671), fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title/Name'),
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(
                            text:
                                DateFormat('dd/MM/yyyy').format(_selectedDate)),
                        decoration: InputDecoration(
                          labelText: 'Date',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(
                            text: _selectedTime.format(context)),
                        decoration: InputDecoration(
                          labelText: 'Time',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
              onChanged: (value) {
                setState(() {
                  _location = value;
                });
              },
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description/Notes'),
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(
                color: Color(0xFF273671), fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Color(0xFF273671)),
          ),
          onPressed: () {
            // Update data to Firestore
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.email!)
                .collection('appointment')
                .doc(_title)
                .set({
              'Date': DateFormat('dd/MM/yyyy').format(_selectedDate),
              'Time': _selectedTime.format(context),
              'Location': _location,
              'Description': _description,
              'Title': _title,
            }).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  "Appointment Updated Successfully",
                  style: TextStyle(fontSize: 18.0),
                ),
              ));
              Navigator.pop(context); // Close the dialog
            }).catchError((error) {
              print("Failed to update appointment: $error");
            });
          },
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class ScheduleAppointmentForm extends StatefulWidget {
  @override
  State<ScheduleAppointmentForm> createState() =>
      _ScheduleAppointmentFormState();
}

class _ScheduleAppointmentFormState extends State<ScheduleAppointmentForm> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String title = "";
  String location = "";
  String description = "";

  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: ListView(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
            onChanged: (value) {
              setState(() {
                title = value;
              });
            },
          ),
          SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(
                          text: DateFormat('dd/MM/yyyy').format(_selectedDate)),
                      decoration: InputDecoration(
                        labelText: 'Date',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(
                          text: _selectedTime.format(context)),
                      decoration: InputDecoration(
                        labelText: 'Time',
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF273671)),
              ),
              onPressed: () {
                // Upload data to Firestore
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.email!)
                    .collection('appointment')
                    .doc(title)
                    .set({
                  'Date': DateFormat('dd/MM/yyyy').format(_selectedDate),
                  'Time': _selectedTime.format(context),
                  'Location': location,
                  'Description': description,
                  'Title': title,
                }).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "Appointment Scheduled Successfully",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ));
                  Navigator.pop(context); // Close the bottom sheet
                }).catchError((error) {
                  print("Failed to schedule appointment: $error");
                });
              },
              child: Text(
                'Schedule Appointment',
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
