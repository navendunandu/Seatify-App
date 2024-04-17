import 'dart:ui'; // Import this to use ImageFilter for blur effect
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EachBooking extends StatefulWidget {
  final String id;
  const EachBooking({Key? key, required this.id}) : super(key: key);

  @override
  State<EachBooking> createState() => _EachBookingState();
}

class _EachBookingState extends State<EachBooking> {
  late Map<String, dynamic> bookingData = {};

  @override
  void initState() {
    super.initState();
    fetchBookingData(widget.id).then((data) {
      if (data != null) {
        setState(() {
          bookingData = data;
        });
      } else {
        print('Booking data not found');
      }
    });
  }

  Future<Map<String, dynamic>?> fetchBookingData(String bookingId) async {
    try {
      String ttime = "";
      String tdis = "";
      String ftime = "";
      String fdis = "";
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('tbl_booking')
          .doc(bookingId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> bookingData =
            snapshot.data() as Map<String, dynamic>;

        var count = 0;
        List<String> seats = [];
        QuerySnapshot seatSnapshot = await FirebaseFirestore.instance
            .collection('tbl_seat')
            .where('booking_id', isEqualTo: bookingId)
            .get();
        for (var doc in seatSnapshot.docs) {
          seats.add(doc["seat_no"]);
          count = count + 1;
        }
        bookingData['numberOfSeats'] = count;
        String seatsString = seats.join(", ");
        bookingData['seatNumbers'] = seatsString;

        String scheduleId = bookingData['schedule_id'];
        DocumentSnapshot scheduleSnapshot = await FirebaseFirestore.instance
            .collection('tbl_schedule')
            .doc(scheduleId)
            .get();

        if (scheduleSnapshot.exists) {
          Map<String, dynamic> scheduleData =
              scheduleSnapshot.data() as Map<String, dynamic>;
          bookingData['schedDate'] = scheduleData['date_scheduled'];
          bookingData['schedTime'] = scheduleData['time_scheduled'];
          bookingData['route_id'] = scheduleData['route_id'];
          bookingData['bus_name'] = scheduleData['bus_name'];
        }

        String routeId = bookingData['route_id'];
        DocumentSnapshot fromRouteSnapshot = await FirebaseFirestore.instance
            .collection('tbl_route')
            .doc(routeId)
            .get();

        if (fromRouteSnapshot.exists) {
          Map<String, dynamic> fromRouteData =
              fromRouteSnapshot.data() as Map<String, dynamic>;
          bookingData['Route_Name'] = fromRouteData['route_name'];
        }

        String fromPlaceId = bookingData['fromplace'];
        DocumentSnapshot fromPlaceSnapshot = await FirebaseFirestore.instance
            .collection('tbl_place')
            .doc(fromPlaceId)
            .get();

        if (fromPlaceSnapshot.exists) {
          QuerySnapshot fromStopSnapshot = await FirebaseFirestore.instance
              .collection('tbl_stop')
              .where('stopname_id', isEqualTo: fromPlaceId)
              .where('route_id', isEqualTo: bookingData['route_id'])
              .limit(1)
              .get();

          if (fromStopSnapshot.docs.isNotEmpty) {
            Map<String, dynamic>? fromStopData =
                fromStopSnapshot.docs.first.data() as Map<String, dynamic>?;

            if (fromStopData != null) {
              ftime = fromStopData["stop_time"];
              fdis = fromStopData["stop_distance"];

              Map<String, dynamic> fromPlaceData =
                  fromPlaceSnapshot.data() as Map<String, dynamic>;
              bookingData['fromPlace'] = fromPlaceData['place_name'];
            }
          }
        }

        String toPlaceId = bookingData['toplace'];
        DocumentSnapshot toPlaceSnapshot = await FirebaseFirestore.instance
            .collection('tbl_place')
            .doc(toPlaceId)
            .get();

        if (toPlaceSnapshot.exists) {
          QuerySnapshot toStopSnapshot = await FirebaseFirestore.instance
              .collection('tbl_stop')
              .where('stopname_id', isEqualTo: toPlaceId)
              .where('route_id', isEqualTo: bookingData['route_id'])
              .limit(1)
              .get();

          if (toStopSnapshot.docs.isNotEmpty) {
            Map<String, dynamic>? fromStopData =
                toStopSnapshot.docs.first.data() as Map<String, dynamic>?;

            if (fromStopData != null) {
              ttime = fromStopData["stop_time"];
              tdis = fromStopData["stop_distance"];

              Map<String, dynamic> toPlaceData =
                  toPlaceSnapshot.data() as Map<String, dynamic>;
              bookingData['toPlace'] = toPlaceData['place_name'];
            }
          }
        }
        num distance = int.parse(tdis) - int.parse(fdis);
        String? timeScheduled = bookingData['schedTime'];
        int fstime = int.parse(ftime);
        int stopTime = int.parse(ttime);
        DateTime scheduledDateTime = DateFormat.Hm().parse(timeScheduled!);
        DateTime departureTime =
            scheduledDateTime.add(Duration(minutes: fstime));
        DateTime arrivalTime =
            scheduledDateTime.add(Duration(minutes: stopTime));
        String formattedDepartureTime = DateFormat.Hm().format(departureTime);
        String formattedArrivalTime = DateFormat.Hm().format(arrivalTime);

        bookingData['Departure'] = formattedDepartureTime;
        bookingData['Arrival'] = formattedArrivalTime;
        bookingData['Distance'] = distance;

        print(bookingData);
        return bookingData;
      }
    } catch (e) {
      print('Error fetching booking data: $e');
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (bookingData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Bus Ticket'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Ticket'),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, 
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Designer.png'), // Add your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9), // Semi-transparent white background
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BUS TICKET',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color:  const Color.fromARGB(255, 20, 86, 80),
                  ),
                ),
                SizedBox(height: 10),
                Text('From: ${bookingData['fromPlace']}'),
              Text('To: ${bookingData['toPlace']}'),
              Text(
                'Bus : ${bookingData['bus_name']}',
                style: TextStyle(
                  color:Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              Text('Route: ${bookingData['Route_Name']}'),
              Text('Number of Seats Booked: ${bookingData['numberOfSeats']}'),
              Text('Seat Numbers: ${bookingData['seatNumbers']}'),
              Text(
                'Price: ${bookingData['booking_price']}/-',
                style: TextStyle(
                  color: Color.fromARGB(255, 32, 187, 27),
                  fontSize: 16.0,
                ),
              ),
              Text('Departure Time: ${bookingData['Departure']}'
              ,
                style: TextStyle(
                 fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),),
              Text('Arrival Time: ${bookingData['Arrival']}'
              ,
                style: TextStyle(
                 fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
