import 'dart:ui'; // Import this to use ImageFilter for blur effect
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_form/changepassword.dart';
import 'package:flutter_form/editprofile.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  String name = 'Loading...';
  String email = 'Loading...';
  String contact = 'Loading...';
  String address = 'Loading...';
  String image = '';

  Future<void> loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_user')
              .where('user_id', isEqualTo: userId)
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          name = doc['user_name'] ?? 'Error Loading Data';
          email = doc['user_email'] ?? 'Error Loading Data';
          contact = doc['user_contact'] ?? 'Error Loading Data';
          address = doc['user_address'] ?? 'Error Loading Data';
          image = doc['user_photo'];
        });
      } else {
        setState(() {
          name = 'Error Loading Data';
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove app bar shadow
      ),
      extendBodyBehindAppBar: true, // Extend body behind app bar
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/debg7.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blurred Container
          Positioned.fill(
            child: Container(
              color: Colors.black
                  .withOpacity(0.2), // Add a semi-transparent black color
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: 2, sigmaY: 2), // Apply blur effect
                child: Center(
                  child: Container(
                    height: 500,
                    width: 300,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                          0.7), // Add a semi-transparent white color
                      borderRadius:
                          BorderRadius.circular(10.0), // Add rounded corners
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xff4c505b),
                          backgroundImage: image.isNotEmpty
                              ? NetworkImage(image) as ImageProvider
                              : const AssetImage('assets/default.jpg'),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Name: $name',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Email: $email',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Contact: $contact',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Address: $address',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Editprofile(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                  255, 226, 142, 17), // Set background color
                              borderRadius: BorderRadius.circular(
                                  10), // Set border radius
                            ),
                            padding: EdgeInsets.all(
                                10), // Add padding for better appearance
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                  color:
                                      Colors.white), // Set text color to white
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChangePassword(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(
                                  255, 18, 127, 116), // Set background color
                              borderRadius: BorderRadius.circular(
                                  10), // Set border radius
                            ),
                            padding: EdgeInsets.all(
                                10), // Add padding for better appearance
                            child: const Text(
                              'Change Password',
                              style: TextStyle(
                                  color:
                                      Colors.white), // Set text color to white
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
