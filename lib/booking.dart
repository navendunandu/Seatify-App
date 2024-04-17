import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form/payment.dart';
import 'package:rxdart/rxdart.dart';

class Booking extends StatefulWidget {
  final String sid;
  final String amt;
  final String fid;
  final String tid;

  const Booking(
      {super.key,
      required this.sid,
      required this.amt,
      required this.fid,
      required this.tid});
  @override
  _BookingState createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final List<bool> _selectedSeats =
      List.generate(40, (_) => false); // Initialize all seats as unselected
  List<String> _bookedSeats = [];
  List<String> _selectedSeatNumbers = [];
  Future<void> confirm() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('tbl_user')
            .where('user_id', isEqualTo: userId)
            .limit(1)
            .get();

    final doc = querySnapshot.docs.first;
    final userDocumentId = doc.id; // Get the document ID

    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('tbl_booking')
        .add({
      'booking_price': int.parse(widget.amt),
      'booking_status': 0,
      'booking_timestamp': DateTime.now(),
      'fromplace': widget.fid,
      'toplace': widget.tid,
      'schedule_id': widget.sid,
      'user_id': userDocumentId, // Use the user document ID
    });

    // Get the generated document ID
    String documentId = docRef.id;

    for (var seat in _selectedSeatNumbers) {
      await FirebaseFirestore.instance.collection('tbl_seat').add({
        'booking_id': documentId,
        'seat_no': seat.toString(),
        'seat_status': 0
      });
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(bid: documentId),
      ),
    );
  } catch (e) {
    print("Error: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Seating'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/2/2087.png',
                  height: 40,
                ),
                const SizedBox(
                  width: 30,
                )
              ],
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tbl_booking')
                    .where('schedule_id', isEqualTo: widget.sid)
                    .snapshots()
                    .map((querySnapshot) {
                  List<String> bookingIds =
                      querySnapshot.docs.map((doc) => doc.id).toList();
                  print("bid: $bookingIds");
                  return FirebaseFirestore.instance
                      .collection('tbl_seat')
                      .where("booking_id", whereIn: bookingIds)
                      .snapshots();
                }).flatMap((query) => query),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  _bookedSeats = snapshot.data!.docs
                      .map((doc) => doc.get('seat_no') as String)
                      .toList();

                  print("seats: $_bookedSeats");
                  print("id: ${widget.sid}");

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: 40,
                    itemBuilder: (context, index) {
                      int row = index ~/ 5;
                      int col = index % 5;
                      int seatNumber = row * 5 + col + 1;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: col == 1 ? 16.0 : 0.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (!_bookedSeats.contains(seatNumber.toString())) {
                              setState(() {
                                _selectedSeats[index] = !_selectedSeats[index];
                                if (_selectedSeats[index]) {
                                  _selectedSeatNumbers
                                      .add(seatNumber.toString());
                                } else {
                                  _selectedSeatNumbers
                                      .remove(seatNumber.toString());
                                }
                              });
                              // Add logic to update the Firestore database
                            }
                          },
                          child: Container(
                            width: 60.0,
                            height: 60.0,
                            decoration: BoxDecoration(
                              color:
                                  _bookedSeats.contains(seatNumber.toString())
                                      ? Colors.red
                                      : _selectedSeats[index]
                                          ? Colors.green
                                          : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.chair),
                                Text(
                                  '$seatNumber',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _bookedSeats
                                            .contains(seatNumber.toString())
                                        ? Colors.white
                                        : _selectedSeats[index]
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                    onPressed: () {
                      confirm();
                    },
                    child: Text('Confirm Booking'))),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16.0,
                      height: 16.0,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Text('Available'),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 16.0,
                      height: 16.0,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Text('Selected'),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 16.0,
                      height: 16.0,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Text('Booked'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
