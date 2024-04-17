import 'package:flutter/material.dart';

class TopNav extends StatefulWidget implements PreferredSizeWidget {
  const TopNav({super.key});

  @override
   _TopNavState createState() => _TopNavState();
   @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
   class _TopNavState extends State<TopNav>{
   @override
     Widget build(BuildContext context) {
    return AppBar(
            title: const Text(
                          'Seatify',
                          style: TextStyle(
                            fontSize: 30,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Seatify',
                            color: Color.fromARGB(255, 9, 89, 100),
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
            
          );
   }
}
