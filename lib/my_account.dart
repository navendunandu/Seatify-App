import 'package:flutter/material.dart';
import 'package:flutter_form/usercomplaints.dart';
import 'package:flutter_form/userfeedback.dart';
import 'my_profile.dart';

class MyAccount extends StatelessWidget {
  const MyAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/debg.jpg', // Adjust the path to your image
            fit: BoxFit.cover,
          ),
        ),
        // Content
        Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.transparent, // Set transparent color for the container
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(10.0),
                
                child: Text(
                  'My Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255), // Text color
                  ),
                ),
              ),
              SizedBox(height: 16), // Add some spacing

              // ListTiles for different options
              ListTile(
                title: Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 20, 121, 113), // Text color
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyProfile()),
                  );
                },
              ),
              Divider(
                color: Color.fromARGB(255, 20, 121, 113),
              ), // Add a divider for separation
              ListTile(
                title: Text(
                  'Complaints',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 20, 121, 113), // Text color
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserComplaints()),
                  );// Handle Complaints option
                },
              ),
              Divider(
                color: Color.fromARGB(255, 20, 121, 113),
              ),
              ListTile(
                title: Text(
                  'Feedbacks',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 20, 121, 113), // Text color
                  ),
                ),
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserFeedback()),
                  );/// Handle Feedbacks option
                },
              ),
              Divider(
                color: Color.fromARGB(255, 20, 121, 113),
              ),
              ListTile(
                title: Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 20, 121, 113), // Text color
                  ),
                ),
                onTap: () {
                  // Handle About option
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
