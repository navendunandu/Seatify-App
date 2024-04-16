import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_form/booking.dart';


class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  

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
                        bottomLeft: Radius.circular(
                            constraints.maxWidth * 0.2), // Adjust the curve radius as per your preference
                        bottomRight: Radius.circular(
                            constraints.maxWidth * 0.2), // Adjust the curve radius as per your preference
                      ),
                      child: Image.asset(
                        'assets/Designer.png', // Replace this with your image path
                        width: double.infinity, // Make image stretch across the screen width
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 1),
                        child: Container(
                          color: Colors.black.withOpacity(
                              0.1), // Adjust opacity as needed
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + kToolbarHeight, // Position text below the app bar
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
                                'Piravom',
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
                                'Muvattupuzha',
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
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 150, // Adjust the vertical position
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(top: 20),
              color: Colors.transparent, // Set container background color to transparent
              child: ListView(
                children: [
                  buildFlightCard(
                      'Ganga','piravom to munnar', '09:00 AM', '06:00 AM', '104 km', context),
                  buildFlightCard(
                      'Roaming', 'piravom to adimali','10:00 AM', '07:00 AM', '81 km', context),
                  buildFlightCard(
                      'Gayathri', 'Ernakulam to muvattupuzha','11:00 AM', '08:00 AM', '67 km', context),
                  // Add more flight cards here
                ],
              ),
            ),
          ),
          // Text widget at the bottom
         
        ],
      ),
    );
  }

  Widget buildFlightCard(String flightName, String route, String arrivalTime, String departureTime, String distance, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Booking()),
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
                flightName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(route),
              Text('Time of Arrival: $arrivalTime'),
              Text('Time of Departure: $departureTime'),
              Text('Distance: $distance'),
            ],
          ),
        ),
      ),
    );
  }
}