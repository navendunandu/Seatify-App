import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  XFile? _selectedImage;
  String? _imageUrl;
  String? filePath;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? _selectedPlace;
  String? _selectedDistrict;
  String? selectedGender;
  List<Map<String, dynamic>> district = [];
  List<Map<String, dynamic>> place = [];
  
 
  Future<void> fetchDistrict() async {
    try {
      _selectedDistrict = null;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await db.collection('tbl_district').where('state_id', isEqualTo: "W0uxFyeWbPsgapYAJM0w").get();

      List<Map<String, dynamic>> dist = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'district': doc['district_name'].toString(),
              })
          .toList();
      setState(() {
        district = dist;
      });
    } catch (e) {
      print('Error fetching district data: $e');
    }
  } 

   Future<void> fetchPlace(String id) async {
    try {
      _selectedPlace = null;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await db.collection('tbl_place').where('district_id', isEqualTo: id).get();
      List<Map<String, dynamic>> plc = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'place': doc['place_name'].toString(),
              })
          .toList();
      setState(() {
        place = plc;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _registerUser() async {
    try {
        UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text,
      );

     if (userCredential != null) {
        await _storeUserData(userCredential.user!.uid);
        }
    } catch (e) {
     
      print("Error registering user: $e");
      // Handle error, show message, or take appropriate action
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ));
  }

  Future<void> _storeUserData(String userId) async {
    try {
      await db.collection('tbl_user').add({
        'user_id': userId,
        'user_name': _nameController.text,
        'user_email': _emailController.text,
        'user_dob': _dobController.text,
        'user_address': _addressController.text,
        'user_contact': _contactController.text,
        'place_id': _selectedPlace,
        'user_gender': selectedGender,
        'user_photo':""
        // Add more fields as needed
      });

      await _uploadImage(userId);
    } catch (e) {
      print("Error storing user data: $e");
      // Handle error, show message or take appropriate action
    }
  }

  Future<void> _uploadImage(String userId) async {
  try {
    if (_selectedImage != null) {
       final Reference ref =
                FirebaseStorage.instance.ref().child('user_photo/$userId.jpg');
            await ref.putFile(File(_selectedImage!.path));
            final imageUrl = await ref.getDownloadURL();

      // Check if the document exists before updating
      await db.collection('tbl_user')
          .where('user_id', isEqualTo: userId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.update({
            'user_photo': imageUrl,
          });
        });
      });
    }
  } catch (e) {
    print("Error uploading image: $e");
    // Handle error, show message or take appropriate action
  }
}


  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile.path);
      });
    }
    print(_selectedImage?.path);
  }

  void login() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUp(),
        ));
  }

 

  @override
  void initState() {
    super.initState();
    fetchDistrict();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Blur
          Positioned.fill(
            child: Image.asset(
              'assets/bus.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color:
                    Colors.black.withOpacity(0.5), // Adjust opacity as needed
              ),
            ),
          ),

          // Login Form
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'Seatify',
                          style: TextStyle(
                            fontSize: 60,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Seatify',
                            color: Colors.white,
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor:
                                    Color.fromARGB(255, 84, 115, 120),
                                backgroundImage: _selectedImage != null
                                    ? FileImage(File(_selectedImage!.path))
                                    : _imageUrl != null
                                        ? NetworkImage(_imageUrl!)
                                        : const AssetImage(
                                                'assets/default.jpg')
                                            as ImageProvider,
                                child: _selectedImage == null &&
                                        _imageUrl == null
                                    ? const Icon(
                                        Icons.add,
                                        size: 40,
                                        color:
                                            Color.fromARGB(255, 240, 239, 239),
                                      )
                                    : null,
                              ),
                              if (_selectedImage != null || _imageUrl != null)
                                const Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 18,
                                    child: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Color.fromARGB(255, 238, 231, 231),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Full Name'),
                          labelStyle:
                              TextStyle(color: Colors.tealAccent.shade100),
                          hintText: 'Enter Full Name',
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(
                                  255, 249, 249, 249), // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          labelStyle:
                              TextStyle(color: Colors.tealAccent.shade100),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 50,
                      ),
                        TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: _contactController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Contact'),
                          labelStyle:
                              TextStyle(color: Colors.tealAccent.shade100),
                          hintText: 'Enter contact',
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: _dobController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter dob';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          label: const Text('DOB'),
                          labelStyle:
                              TextStyle(color: Colors.tealAccent.shade100),
                          hintText: 'Enter Date of Birth',
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Gender: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  fillColor:
                                      MaterialStatePropertyAll(Colors.white),
                                  value: 'Male',
                                  groupValue: selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value!;
                                    });
                                  },
                                ),
                                const Text('Male',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  fillColor:
                                      MaterialStatePropertyAll(Colors.white),
                                  value: 'Female',
                                  groupValue: selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value!;
                                    });
                                  },
                                ),
                                const Text('Female',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                           
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),

                        DropdownButtonFormField<String>(
                          dropdownColor: Color.fromARGB(220, 60, 87, 87),
                          value: _selectedDistrict,
                          decoration: InputDecoration(
                            label: const Text('District'),
                            labelStyle:
                                TextStyle(color: Colors.tealAccent.shade100),
                            hintText: 'Select district',
                            hintStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDistrict = newValue;
                              fetchPlace(newValue!);
                            });
                          },
                          isExpanded: true,
                          items: district.map<DropdownMenuItem<String>>(
                          (Map<String, dynamic> dist) {
                            return DropdownMenuItem<String>(
                              value: dist['id'],
                              child: Text(dist['district'],style:TextStyle(color: Colors.tealAccent.shade100),),
                            );
                          },
                        ).toList(),
                      
                          ),


                      SizedBox(
                        height: 50,
                      ), 

                        DropdownButtonFormField<String>(
                          dropdownColor: Color.fromARGB(220, 60, 87, 87),
                          value: _selectedPlace,
                          decoration: InputDecoration(
                            label: const Text('Place'),
                            labelStyle:
                                TextStyle(color: Colors.tealAccent.shade100),
                            hintText: 'Select Place',
                            hintStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white, // Default border color
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedPlace = newValue;
                              
                            });
                          },
                          isExpanded: true,
                          items: place.map<DropdownMenuItem<String>>(
                          (Map<String, dynamic> pl) {
                            return DropdownMenuItem<String>(
                              value: pl['id'],
                              child: Text(pl['place'],style:TextStyle(color: Colors.tealAccent.shade100),),
                            );
                          },
                        ).toList(),
                      
                          ), 

                      SizedBox(
                        height: 50,
                      ),

                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: _addressController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          label: const Text('Address'),
                          labelStyle:
                              TextStyle(color: Colors.tealAccent.shade100),
                          hintText: 'Enter Address',
                          hintStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: _passController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          labelStyle:
                              TextStyle(color: Colors.tealAccent.shade100),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _registerUser();
                        },
                        icon: const Icon(Icons.account_circle_outlined),
                        label: const Text('SIGN UP'),
                      ),
                    ],
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