import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_form/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? _selectedStateFr;
  String? _selectedPlaceFr;
  String? _selectedDistrictFr;
  String? _selectedStateTo;
  String? _selectedPlaceTo;
  String? _selectedDistrictTo;
  List<Map<String, dynamic>> statefr = [];
  List<Map<String, dynamic>> districtfr = [];
  List<Map<String, dynamic>> placefr = [];
  List<Map<String, dynamic>> stateto = [];
  List<Map<String, dynamic>> districtto = [];
  List<Map<String, dynamic>> placeto = [];

  Future<void> fetchStateFr() async {
    try {
      _selectedStateFr = null;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await db.collection('tbl_state').get();

      List<Map<String, dynamic>> stat = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'state': doc['state_name'].toString(),
              })
          .toList();
      setState(() {
        statefr = stat;
      });
    } catch (e) {
      print('Error fetching district data: $e');
    }
  }

  Future<void> fetchDistrictFr(String id) async {
    try {
      _selectedDistrictFr = null;
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
          .collection('tbl_district')
          .where('state_id', isEqualTo: id)
          .get();

      List<Map<String, dynamic>> dist = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'district': doc['district_name'].toString(),
              })
          .toList();
      setState(() {
        districtfr = dist;
      });
    } catch (e) {
      print('Error fetching district data: $e');
    }
  }

  Future<void> fetchPlaceFr(String id) async {
    try {
      _selectedPlaceFr = null;
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
          .collection('tbl_place')
          .where('district_id', isEqualTo: id)
          .get();
      List<Map<String, dynamic>> plc = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'place': doc['place_name'].toString(),
              })
          .toList();
      setState(() {
        placefr = plc;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchStateTo() async {
    try {
      _selectedStateTo = null;
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await db.collection('tbl_state').get();

      List<Map<String, dynamic>> stat = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'state': doc['state_name'].toString(),
              })
          .toList();
      setState(() {
        stateto = stat;
      });
    } catch (e) {
      print('Error fetching district data: $e');
    }
  }

  Future<void> fetchDistrictTo(String id) async {
    try {
      _selectedDistrictTo = null;
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
          .collection('tbl_district')
          .where('state_id', isEqualTo: id)
          .get();

      List<Map<String, dynamic>> dist = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'district': doc['district_name'].toString(),
              })
          .toList();
      setState(() {
        districtto = dist;
      });
    } catch (e) {
      print('Error fetching district data: $e');
    }
  }

  Future<void> fetchPlaceTo(String id) async {
    try {
      _selectedPlaceTo = null;
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
          .collection('tbl_place')
          .where('district_id', isEqualTo: id)
          .get();
      List<Map<String, dynamic>> plc = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'place': doc['place_name'].toString(),
              })
          .toList();
      setState(() {
        placeto = plc;
      });
    } catch (e) {
      print(e);
    }
  }

  void search() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
  }

  @override
  void initState() {
    super.initState();
    fetchStateFr();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/debg5.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blurred Container
          Positioned.fill(
            child: Container(
              color: Colors.black
                  .withOpacity(0.1), // Add a semi-transparent black color
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: 0, sigmaY: 0), // Apply blur effect
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                              0.7), // Add a semi-transparent white color
                          borderRadius: BorderRadius.circular(
                              10.0), // Add rounded corners
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Select Departure:',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                _showDepartureDialog(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Rounded corners
                                  ),
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 145, 72)),
                              child: Text(
                                'Departure',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),

                                // White text color
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Select Destination:',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                _showDestinationDialog(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Rounded corners
                                  ),
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 145, 72)),
                              child: Text(
                                'Destination',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white), // White text color
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Select Date:',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Select Date'),
                                    Icon(Icons.calendar_today),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          search();
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8.0), // Rounded corners
                            ),
                            backgroundColor: Colors.teal.shade300),
                        child: const Text(
                          'Search',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white), // White text color
                        ),
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

  void _showDepartureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Departure'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: Color.fromARGB(220, 60, 87, 87),
                value: _selectedStateFr,
                decoration: InputDecoration(
                  label: const Text('State'),
                  labelStyle:
                      TextStyle(color: const Color.fromARGB(255, 15, 92, 74)),
                  hintText: 'Select state',
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
                    _selectedStateFr = newValue;
                    fetchDistrictFr(newValue!);
                     Navigator.pop(context);
                  });
                  Future.delayed(Duration.zero, () {
                    _showDepartureDialog(context);
                  });
            
                },
                isExpanded: true,
                items: statefr.map<DropdownMenuItem<String>>(
                  (Map<String, dynamic> stat) {
                    return DropdownMenuItem<String>(
                      value: stat['id'],
                      child: Text(
                        stat['state'],
                      ),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(width: 10),
              DropdownButtonFormField<String>(
                dropdownColor: Color.fromARGB(220, 60, 87, 87),
                value: _selectedDistrictFr,
                decoration: InputDecoration(
                  label: const Text('District'),
                  labelStyle:
                      TextStyle(color: const Color.fromARGB(255, 15, 92, 74)),
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
                    _selectedDistrictFr = newValue;
                    fetchPlaceFr(newValue!);
                    Navigator.pop(context);
                  });
                  Future.delayed(Duration.zero, () {
                    _showDepartureDialog(context);
                     Navigator.pop(context);
                  });
                   Future.delayed(Duration.zero, () {
                    _showDepartureDialog(context);
                  });
                },
                isExpanded: true,
                items: districtfr.map<DropdownMenuItem<String>>(
                  (Map<String, dynamic> dist) {
                    return DropdownMenuItem<String>(
                      value: dist['id'],
                      child: Text(
                        dist['district'],
                      ),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(width: 10),
              DropdownButtonFormField<String>(
                dropdownColor: Color.fromARGB(220, 60, 87, 87),
                value: _selectedPlaceFr,
                decoration: InputDecoration(
                  label: const Text('Place'),
                  labelStyle:
                      TextStyle(color: const Color.fromARGB(255, 15, 92, 74)),
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
                    _selectedPlaceFr = newValue;
                  });
                },
                isExpanded: true,
                items: placefr.map<DropdownMenuItem<String>>(
                  (Map<String, dynamic> pl) {
                    return DropdownMenuItem<String>(
                      value: pl['id'],
                      child: Text(
                        pl['place'],
                      ),
                    );
                  },
                ).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDestinationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Destination'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                items: <String>['state 1', 'state 2', 'state 3']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
                hint: const Text('Select state'),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                items: <String>['District 1', 'District 2', 'District 3']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
                hint: const Text('Select District'),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                items: <String>['place 1', 'place 2', 'place 3']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
                hint: const Text('Select place'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  
}
