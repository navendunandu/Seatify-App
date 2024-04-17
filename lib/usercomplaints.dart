import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_form/viewcomplaints.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Complaints',
      home: UserComplaints(),
    );
  }
}

class UserComplaints extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('complaint'),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove app bar shadow
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/debg7.jpg'), // Provide your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: 450.0, // Adjust the height of the card as needed
                child: ComplaintsFormCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ComplaintsFormCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Colors.white.withOpacity(0.7), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: ComplaintsForm(),
      ),
    );
  }
}

class ComplaintsForm extends StatefulWidget {
  @override
  _ComplaintsFormState createState() => _ComplaintsFormState();
}

class _ComplaintsFormState extends State<ComplaintsForm> {
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _complainttitleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
         QuerySnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('tbl_user').where('user_id', isEqualTo: userId).get();
                  String uDoc = userSnapshot.docs.first.id;
        final complaintContent = _complaintController.text.trim();
        final complainttitle = _complainttitleController.text.trim();
        try {
          // Add the complaint to Firestore
          await FirebaseFirestore.instance.collection('tbl_complaints').add({
            'user_id': uDoc,
            'complaint_title': complainttitle,
            'complaint_content': complaintContent,
            // Add a timestamp if needed
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Complaint submitted successfully.'),
            ),
          );
          _complaintController.clear();
          _complainttitleController.clear();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting complaint: $e'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not logged in.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ' complaints here...',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w500,
                
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _complainttitleController,
              maxLines: null,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Enter your complaint title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return 'Please enter a complaint title';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _complaintController,
              maxLines: null,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your complaint content',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return 'Please enter a complaint content';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: _submitComplaint,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 26, 101, 96)),
                  ),
                  child: Text('Submit',
                   style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
              ),),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewComplaints()),
              );
            },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 220, 130, 26)),
                  ),
                  child: Text('View Complaints',
                   style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}