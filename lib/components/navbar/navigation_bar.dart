// ignore_for_file: use_key_in_widget_constructors

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:financial_tracking/pages/financial.dart';
import 'package:financial_tracking/pages/home.dart';
import 'package:financial_tracking/pages/task.dart';
import 'package:financial_tracking/pages/profile.dart';
import 'package:financial_tracking/pages/wishlist.dart';
import 'package:flutter/material.dart';

class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key});

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _page = 0;

  final List<Widget> _pages = [
    Home(),
    Financial(),
    Wishlist(),
    Tasks(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_page], // Menampilkan halaman yang sesuai
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.green,
        color: Colors.green,
        height: 63,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home, size: 25, color: Colors.white), // Home
          Icon(Icons.wallet,
              size: 25, color: Colors.white), // Financial Tracking
          Icon(Icons.shopping_cart, size: 25, color: Colors.white), // Wishlist
          Icon(Icons.speaker_notes, size: 25, color: Colors.white), // Notes
          Icon(Icons.person, size: 25, color: Colors.white), // Profile
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
    );
  }
}
