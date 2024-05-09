import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
        title: Text("Appointments"),
        centerTitle: true,
      ),
      body: ScheduledAppointments(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return ScheduleAppointmentForm();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ScheduledAppointments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc('appointment')
          .collection('active')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No appointments scheduled'));
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5,
                child: ListTile(
                  title: Text(data['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${data['date']}'),
                      Text('Time: ${data['time']}'),
                      Text('Location: ${data['location']}'),
                      Text('Description: ${data['description']}'),
                    ],
                  ),
                  onTap: () {
                    // Handle onTap if needed
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
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
            decoration: InputDecoration(labelText: 'Title/Name'),
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
          ElevatedButton(
            onPressed: () {
              // Upload data to Firestore
              FirebaseFirestore.instance
                  .collection('users')
                  .doc('appointment')
                  .collection('active')
                  .doc(title)
                  .set({
                'date': DateFormat('dd/MM/yyyy').format(_selectedDate),
                'time': _selectedTime.format(context),
                'location': location,
                'description': description,
                'title': title,
              }).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                  "Appointment Scheduled Successfully",
                  style: TextStyle(fontSize: 18.0),
                )));
                Navigator.pop(context); // Close the bottom sheet
              }).catchError((error) {
                print("Failed to schedule appointment: $error");
              });
            },
            child: Text('Schedule Appointment'),
          ),
        ],
      ),
    );
  }
}
