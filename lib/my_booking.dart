import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_form/eachbooking.dart';

class MyBookings extends StatefulWidget {
  const MyBookings({Key? key}) : super(key: key);

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  List<Map<String, dynamic>> _bookingData1 = [];
  List<Map<String, dynamic>> _bookingData2 = [];
  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String formattedDate; // Declare formattedDate variable

  @override
  void initState() {
    super.initState();
    // Initialize formattedDate here
    DateTime now = DateTime.now();
    formattedDate =
        '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}';
    _fetchBookingData();
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }

  Future<void> _fetchBookingData() async {
  try {
    final user = _auth.currentUser;
    final userId = user?.uid;
    if (userId != null) {
      QuerySnapshot userSnapshot = await db
          .collection('tbl_user')
          .where('user_id', isEqualTo: userId)
          .get();
      if (userSnapshot.docs.isNotEmpty) {
        String uDoc = userSnapshot.docs.first.id;
        // Fetch all bookings for the current user
        QuerySnapshot bookingSnapshot = await db
            .collection('tbl_booking')
            .where('user_id', isEqualTo: uDoc)
            .get();
        // Filter the bookings based on the booking status
        List<Map<String, dynamic>> upcomingBookings = [];
        List<Map<String, dynamic>> previousBookings = [];
        for (var doc in bookingSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['bookingId'] = doc.id; // Add the document ID
          if (data['booking_status'] > 0) {
            DocumentSnapshot scheduleDoc = await db
                .collection('tbl_schedule')
                .doc(data['schedule_id'])
                .get();
            DocumentSnapshot fromplaceDoc =
                await db.collection('tbl_place').doc(data['fromplace']).get();
            if (fromplaceDoc.exists) {
              Map<String, dynamic> fromData =
                  fromplaceDoc.data() as Map<String, dynamic>;
              data['from'] = fromData["place_name"];
            }
            DocumentSnapshot toplaceDoc =
                await db.collection('tbl_place').doc(data['toplace']).get();
            if (toplaceDoc.exists) {
              Map<String, dynamic> toData =
                  toplaceDoc.data() as Map<String, dynamic>;
              data['to'] = toData["place_name"];
            }
            if (scheduleDoc.exists) {
              Map<String, dynamic> scheduleData =
                  scheduleDoc.data() as Map<String, dynamic>;
              data['scheddate'] = scheduleData["date_scheduled"];
              DateTime dataDate = DateTime.parse(data['scheddate']);
              DateTime currentDate = DateTime.parse(formattedDate);
              if (dataDate.isAfter(currentDate)) {
                upcomingBookings.add(data);
              } else {
                previousBookings.add(data);
              }
            }
          }
        }
        setState(() {
          _bookingData1 = upcomingBookings;
          _bookingData2 = previousBookings;
        });
      } else {
        // Handle the case where there is no user document
        print('No user document found');
      }
    } else {
      // Handle the case where the user is not logged in
      print('User is not logged in');
    }
  } catch (e) {
    print('Error fetching booking data: $e');
  }
}

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/debg.jpg'), // Add your image path here
          fit: BoxFit.cover,
        ),
      ),
      child: ListView(
        children: [
          Text(
            '   Upcoming Bookings',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Container(
            padding: EdgeInsets.all(5),
            color:
                Colors.black.withOpacity(0.0), // Adjust the opacity as needed

            child: _bookingData1.isEmpty
                ? Center(
                    child: Text('No bookings found'),
                  )
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _bookingData1.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final booking = _bookingData1[index];
                      // DateTime bookingDate = DateTime.parse();
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () {
                             Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EachBooking(id: booking['bookingId']),
                                ));
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'from ${booking['from']} to ${booking['to']}',
                                    style: TextStyle(
                                      color:
                                          const Color.fromARGB(255, 20, 86, 80),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  Text(
                                    'Scheduled for: ${booking['scheddate']}',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Booking Amount: Rs.${booking['booking_price']}/-',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 17, 135, 82),
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Booking Status: ${_getBookingStatus(booking['booking_status'])}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Text(
            '   Previous Bookings',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Container(
            padding: EdgeInsets.all(5),
            color:
                Colors.black.withOpacity(0.0), // Adjust the opacity as needed

            child: _bookingData2.isEmpty
                ? Center(
                    child: Text('No bookings found'),
                  )
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _bookingData2.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final booking = _bookingData2[index];
                      // DateTime bookingDate = DateTime.parse();
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EachBooking(id: booking['bookingId']),
                                ));
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'from ${booking['from']} to ${booking['to']}',
                                    style: TextStyle(
                                      color:
                                          const Color.fromARGB(255, 20, 86, 80),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  Text(
                                    'Scheduled for: ${booking['scheddate']}',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Booking Amount: Rs.${booking['booking_price']}/-',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 17, 135, 82),
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Booking Status: ${_getBookingStatus(booking['booking_status'])}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getBookingStatus(int status) {
    switch (status) {
      case 1:
        return 'Confirmed';
      case 2:
        return 'cancelled';
      default:
        return 'Unknown';
    }
  }
}
