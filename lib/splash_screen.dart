import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_form/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
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
          color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
        ),
      ),
    ),
    // Your existing content here, e.g., Centered Text Widget
    Center(
      child: Text(
        'Seatify',
        style: TextStyle(
          fontSize: 70,
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
  ],
)
      ),
    );
  }
}
