import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => EditprofileState();
}

class EditprofileState extends State<Editprofile> {
  String imageUrl = 'assets/default.jpg';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      if (userId != null) {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('tbl_user')
                .where('user_id', isEqualTo: userId)
                .limit(1)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          setState(() {
            if (doc['user_photo'] != null) {
              imageUrl = doc['user_photo'];
            }
            _nameController.text = doc['user_name'] ?? '';
            _contactController.text = doc['user_contact'] ?? '';
            _addressController.text = doc['user_address'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          showErrorDialog('User data not found');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        showErrorDialog('User ID is null');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorDialog('Error loading data: $e');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void editProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('tbl_user')
            .where('user_id', isEqualTo: userId)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            final docId = querySnapshot.docs.first.id;
            FirebaseFirestore.instance
                .collection('tbl_user')
                .doc(docId)
                .update({
              'user_name': _nameController.text,
              'user_contact': _contactController.text,
              'user_address': _addressController.text,
            });
            showSuccessDialog('Profile updated successfully');
            photoupdate(userId, docId);
          }
        });
      } catch (e) {
        showErrorDialog('Error updating document: $e');
      }
    } else {
      showErrorDialog('User ID is null');
    }
  }

  void photoupdate(uid, did) async {
    if (_selectedImage != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('tbl_user').doc(did);
      final storage = FirebaseStorage.instance;
      final Reference storageRef = storage.ref().child('user_photo/$uid.jpg');
      final UploadTask uploadTask =
          storageRef.putFile(File(_selectedImage!.path));

      await uploadTask.whenComplete(() async {
        var imageurl = await storageRef.getDownloadURL();
        setState(() {
          imageUrl = imageurl; // Update profileImageUrl with new URL
        });
        print(imageUrl);
        userDoc.update({
          'user_photo': imageUrl,
        });
      });
    }
  }

  XFile? _selectedImage;
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Edit Profile'),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove app bar shadow
      ),
      extendBodyBehindAppBar: true, // Extend body behind app bar
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
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
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                          0.7), // Add a semi-transparent white color
                      borderRadius:
                          BorderRadius.circular(10.0), // Add rounded corners
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            _pickImage(); // Open image picker
                          },
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _selectedImage != null
                                ? FileImage(File(_selectedImage!.path))
                                : (imageUrl != "assets/default.jpg"
                                    ? NetworkImage(imageUrl)
                                    : AssetImage('assets/default.jpg')
                                        as ImageProvider),
                            child: Icon(Icons.edit),
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Name',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _contactController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Contact',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your contact';
                            }
                            // Add additional contact validation if needed
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Address',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            editProfile();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.teal), // Set background color
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.white), // Set text color
                          ),
                          child: const Text('Save'),
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
