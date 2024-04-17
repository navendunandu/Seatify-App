import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_form/booking.dart';
import 'package:intl/intl.dart';

class Search extends StatefulWidget {
  final String selecteddate;
  final String fromplace;
  final String toplace;
  const Search(
      {super.key,
      required this.selecteddate,
      required this.fromplace,
      required this.toplace});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  List<Map<String, dynamic>> busData = [];
  String fromPlace = '';
  String toPlace = '';
  void fetchData() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      String filterdate = widget.selecteddate;

      // Fetch data for fromPlace
      DocumentSnapshot<Map<String, dynamic>> fromPlaceSnapshot =
          await _firestore.collection("tbl_place").doc(widget.fromplace).get();
      String fromPlaceName = fromPlaceSnapshot.data()!['place_name'];

// Fetch data for toPlace
      DocumentSnapshot<Map<String, dynamic>> toPlaceSnapshot =
          await _firestore.collection("tbl_place").doc(widget.toplace).get();
      String toPlaceName = toPlaceSnapshot.data()!['place_name'];
      setState(() {
        fromPlace = fromPlaceName;
        toPlace = toPlaceName;
      });
      // Query for fslist
      QuerySnapshot<Map<String, dynamic>> stopFromQuery = await _firestore
          .collection("tbl_stop")
          .where("stopname_id", isEqualTo: widget.fromplace)
          .get();

      List<Map<String, dynamic>> fslist = [];
      stopFromQuery.docs.forEach((sf) {
        fslist.add({
          "f_id": sf.data()['route_id'],
          "fstop_no": sf.data()['stop_number'],
          "fstop_dis": sf.data()['stop_distance'],
          "fstime": sf.data()['stop_time']
        });
      });

      // Fetch latest price
      QuerySnapshot<Map<String, dynamic>> latestPriceSnapshot = await _firestore
          .collection("tbl_price")
          .orderBy("date_added", descending: true)
          .limit(1)
          .get();
      String priceAsString = latestPriceSnapshot.docs.first.data()['price'];
      double price = double.tryParse(priceAsString) ?? 0.0;

      // Implement remaining logic and queries similarly
      // print('Data: $fslist');
      // print('Price $price');
      // print('From Place: $fromPlaceName');
      // print('To Place: $toPlaceName');

      List<String> fIds = [];
      for (var item in fslist) {
        fIds.add(item['f_id']);
      }
      List<Map<String, dynamic>> dataList = [];
      for (String fId in fIds) {
        QuerySnapshot querySnapshots = await _firestore
            .collection('tbl_stop')
            .where('route_id', isEqualTo: fId)
            .get();

        List<DocumentSnapshot> documents = querySnapshots.docs;

        for (DocumentSnapshot document in documents) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          if (data['stopname_id'] == widget.toplace) {
            data['documentId'] =
                document.id; // Store the document ID along with the data
            dataList.add(data);
          }
        }
        // print('Data2: $dataList');
        List<String> resultList = [];

        for (var item1 in fslist) {
          for (var item2 in dataList) {
            if (item1["f_id"] == item2["route_id"] &&
                int.parse(item1["fstop_no"]) <
                    int.parse(item2["stop_number"])) {
              resultList.add(item1["f_id"]);
            }
          }
        }

        // print('result: $resultList');
        List<Map<String, dynamic>> scheduleList = [];
        String formattedToday =
            DateTime.now().toIso8601String().substring(0, 10);

        QuerySnapshot querySnapshot;

        for (var item2 in resultList) {
          if (filterdate == "null") {
            querySnapshot = await _firestore
                .collection('tbl_schedule')
                .where('route_id', isEqualTo: item2)
                .where('date_scheduled', isGreaterThanOrEqualTo: formattedToday)
                .get();
          } else {
            DateTime selectedDate = DateTime.parse(filterdate);
            String formattedDate =
                "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
            querySnapshot = await _firestore
                .collection('tbl_schedule')
                .where('route_id', isEqualTo: item2)
                .where('date_scheduled', isEqualTo: formattedDate)
                .get();
          }

          List<DocumentSnapshot> documents = querySnapshot.docs;

          for (DocumentSnapshot document in documents) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            data['documentId'] =
                document.id; // Store the document ID along with the data
            scheduleList.add(data);
          }
        }
        // print('From: $fslist');
        // print('To: $dataList');
        // print("Schdule: $scheduleList");
        List<Map<String, dynamic>> finalList = [];

        for (var fromItem in fslist) {
          for (var toItem in dataList) {
            for (var scheduleItem in scheduleList) {
              if (fromItem["f_id"] == toItem["route_id"] &&
                  toItem["route_id"] == scheduleItem["route_id"] &&
                  int.parse(fromItem["fstop_no"]) <
                      int.parse(toItem["stop_number"])) {
                num distance = int.parse(toItem["stop_distance"]) -
                    int.parse(fromItem["fstop_dis"]);
                num distancerate = distance * price;
                String? timeScheduled =
                    (scheduleItem as Map<String, dynamic>)["time_scheduled"];
                int fstime = int.parse(
                    (fromItem as Map<String, dynamic>)['fstime'] ?? '0');
                int stopTime = int.parse(
                    (toItem as Map<String, dynamic>)['stop_time'] ?? '0');
                print(scheduleItem['date_scheduled']);
                print(timeScheduled);
                DateTime scheduledDateTime =
                    DateFormat.Hm().parse(timeScheduled!);
                DateTime departureTime =
                    scheduledDateTime.add(Duration(minutes: fstime));
                DateTime arrivalTime =
                    scheduledDateTime.add(Duration(minutes: stopTime));
                String formattedDepartureTime =
                    DateFormat.Hm().format(departureTime);
                String formattedArrivalTime =
                    DateFormat.Hm().format(arrivalTime);
                CollectionReference routes =
                    FirebaseFirestore.instance.collection('tbl_route');

                // Query Firestore to get the document with the given documentId
                DocumentSnapshot documentSnapshot =
                    await routes.doc(scheduleItem['route_id']).get();
                Map<String, dynamic> data =
                    documentSnapshot.data() as Map<String, dynamic>;
                String routeName = data['route_name'] ?? 'Unknown Route';
                Map<String, dynamic> result = {
                  "distance": distance,
                  "route_id": scheduleItem['route_id'],
                  "schedule_id": scheduleItem['documentId'],
                  "bus_name": scheduleItem['bus_name'],
                  "amount": distancerate.toString(),
                  "departure_time": formattedDepartureTime.toString(),
                  "arrival_time": formattedArrivalTime.toString(),
                  "route_name": routeName,
                  "schedule_date": scheduleItem['date_scheduled'],
                };
                finalList.add(result);
              }
            }
          }
        }
        // print("Final List:$finalList");
        setState(() {
          busData = finalList;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove app bar shadow
      ),
      extendBodyBehindAppBar: true, // Extend body behind app bar
      body: Stack(
        children: [
          // Image with rounded bottom
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(constraints.maxWidth *
                            0.2), // Adjust the curve radius as per your preference
                        bottomRight: Radius.circular(constraints.maxWidth *
                            0.2), // Adjust the curve radius as per your preference
                      ),
                      child: Image.asset(
                        'assets/Designer.png', // Replace this with your image path
                        width: double
                            .infinity, // Make image stretch across the screen width
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 1),
                        child: Container(
                          color: Colors.black
                              .withOpacity(0.1), // Adjust opacity as needed
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top +
                          kToolbarHeight, // Position text below the app bar
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                'From',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold), // Make text bold
                              ),
                              Text(
                                fromPlace,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold), // Make text bold
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          SizedBox(width: 20),
                          Column(
                            children: [
                              Text(
                                'To',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold), // Make text bold
                              ),
                              Text(
                                toPlace,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold), // Make text bold
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Cards with flight details
          Positioned(
            top: MediaQuery.of(context).padding.top +
                kToolbarHeight +
                150, // Adjust the vertical position
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(top: 20),
              color: Colors
                  .transparent, // Set container background color to transparent
              child: busData.isEmpty // Check if busData is empty
                  ? Center(
                      child: Text(
                        'No data found',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: busData.length,
                      itemBuilder: (context, index) {
                        // Access each bus data entry
                        Map<String, dynamic> busEntry = busData[index];

                        // Extract relevant information
                        String departureTime = busEntry['departure_time'];
                        String arrivalTime = busEntry['arrival_time'];
                        String distance = busEntry['distance']
                            .toString(); // Assuming distance is a numeric value
                        String amount = busEntry['amount']
                            .toString(); // Assuming amount is a numeric value
                        // String routeId = busEntry['schedule']['route_id'];
                        // print(routeId);
                        // String scheduleId = busEntry['schedule']['documentId'].toString();
                        // Build and return a FlightCard widget
                        print(busEntry['route_id']);
                        print(busEntry['schedule_id']);
                        print(busEntry['bus_name']);

                        String busName = busEntry['bus_name'];
                        String routeId = busEntry['route_id'];
                        String scheduleId = busEntry['schedule_id'];
                        String routeName = busEntry['route_name'];
                        String routeAmount = busEntry['amount'];
                        String scheduleDate = busEntry['schedule_date'];

                        return buildFlightCard(
                            busName,
                            arrivalTime,
                            departureTime,
                            distance,
                            amount,
                            routeId,
                            scheduleId,
                            routeName,
                            routeAmount,
                            scheduleDate);
                      },
                    ),
            ),
          ),
          // Text widget at the bottom
        ],
      ),
    );
  }

  Widget buildFlightCard(
    String busName,
    String arrivalTime,
    String departureTime,
    String distance,
    String amount,
    String routeId,
    String scheduleId,
    String routeName,
    String routeAmount,
    String scheduleDate,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Booking(
                    sid: scheduleId,
                    amt: amount,
                    fid: widget.fromplace,
                    tid: widget.toplace,
                  )),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        color: Colors.white, // Set card background color to solid white
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                busName,
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 107, 71, 28),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(routeName),
              Text('Date: $scheduleDate'),
              Text(
                'Time of Departure: $departureTime',
                style: TextStyle(
                  color: Color.fromARGB(255, 9, 139, 148),
                ),
              ),
              Text(
                'Time of Arrival: $arrivalTime',
                style: TextStyle(
                  color: Color.fromARGB(255, 9, 139, 148),
                ),
              ),
              Text('Distance: $distance km'),
              Text(
                'Amount: $routeAmount',
                style: TextStyle(
                  color: const Color.fromARGB(255, 21, 63, 137),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
