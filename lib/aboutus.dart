import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Image.asset('assets/bus4.png'),
                
              ),
              Text(
                'About Us',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Seatify is your go-to app for easy bus seat booking. Say goodbye to long queues and phone calls – with Seatify, you can browse, select, and book your bus seat in minutes.\n\nBook your seat with a few taps. Choose from diverse routes and operators. Partnered with trusted operators for safe journeys.\n\nExclusive Deals: Enjoy special offers and discounts. Assistance available anytime, anywhere.\n\nGet Started Today!',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
