import 'package:flutter/material.dart';

class Booking extends StatefulWidget {
  @override
  _BookingState createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  List<bool> seatSelected = List.generate(40, (index) => false); // Initialize all seats as unselected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1, // Aspect ratio of each grid item
        ),
        itemCount: 44, // 40 seats + 1 driver's seat + 1 gap + 1 at the end
        itemBuilder: (context, index) {
          if (index == 40) {
            // Add a gap after 20 seats (index 40)
            return SizedBox.shrink();
          } else if (index == 41) {
            // Driver's seat
            return buildSeatIcon(Icons.directions_car, 'Driver');
          } else if (index == 42) {
            // Add a gap before the end
            return SizedBox.shrink();
          } else {
            // Regular seats
            return buildSeatIcon(Icons.event_seat, '${index + 1}');
          }
        },
      ),
    );
  }

  Widget buildSeatIcon(IconData icon, String seatNumber) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle seat selection
          seatSelected[int.parse(seatNumber) - 1] = !seatSelected[int.parse(seatNumber) - 1];
        });
      },
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: seatSelected[int.parse(seatNumber) - 1] ? Colors.green : Colors.blueGrey.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                seatNumber,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}