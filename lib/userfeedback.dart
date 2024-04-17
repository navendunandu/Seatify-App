import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedbacks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserFeedbacks(),
    );
  }
}

class UserFeedbacks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('feedbacks'),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove app bar shadow
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/debg7.jpg'), // Replace with your background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: 250.0, // Adjust the height as needed
                child: FeedbacksFormCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeedbacksFormCard extends StatefulWidget {
  @override
  _FeedbacksFormCardState createState() => _FeedbacksFormCardState();
}

class _FeedbacksFormCardState extends State<FeedbacksFormCard> {
  final TextEditingController _feedbackController = TextEditingController();

  void _submitFeedback() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final feedbackContent = _feedbackController.text.trim();
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('tbl_user')
          .where('user_id', isEqualTo: userId)
          .get();
      String uDoc = userSnapshot.docs.first.id;
      try {
        await FirebaseFirestore.instance.collection('tbl_feedbacks').add({
          'user_id': uDoc,
          'feedback_content': feedbackContent,
          'feedback_time': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully.'),
          ),
        );
        _feedbackController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
          ),
        );
      }
    } else {
      // Handle the case where the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit feedback.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Color.fromARGB(248, 255, 255, 255).withOpacity( 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send your feedbacks...',
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.w500,
           
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _feedbackController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Feedback Content',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _submitFeedback,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 26, 101, 96)),// Background color
              ),
              child: Center(
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 17, // Font size
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}