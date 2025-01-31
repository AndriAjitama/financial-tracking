// ignore_for_file: use_super_parameters

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:financial_tracking/pages/financial.dart';
import 'package:financial_tracking/pages/home.dart';
import 'package:financial_tracking/pages/task.dart';
import 'package:financial_tracking/pages/money.dart';
import 'package:financial_tracking/pages/profile.dart';
import 'package:financial_tracking/pages/transaction.dart';
import 'package:financial_tracking/pages/wishlist.dart';
import 'package:flutter/material.dart';

class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key}) : super(key: key);

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _page = 0;

  final List<Widget> _pages = [
    Home(key: PageStorageKey('Home')),
    // Financial(key: PageStorageKey('Financial')),
    Transaction(key: PageStorageKey('Transaction')),
    Wishlist(key: PageStorageKey('Wishlist')),
    Money(key: PageStorageKey('Money')),
    Tasks(key: PageStorageKey('Tasks')),
    Profile(key: PageStorageKey('Profile')),
  ];

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey =
      GlobalKey<CurvedNavigationBarState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _page,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.green,
        color: Colors.green,
        height: 63,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home, size: 25, color: Colors.white), // Home
          Icon(Icons.wallet, size: 25, color: Colors.white), // Financial
          Icon(Icons.shopping_cart, size: 25, color: Colors.white), // Wishlist
          Icon(Icons.attach_money, size: 25, color: Colors.white), // Money
          Icon(Icons.speaker_notes, size: 25, color: Colors.white), // Notes
          Icon(Icons.person, size: 25, color: Colors.white), // Profile
        ],
        onTap: (index) {
          if (index >= 0 && index < _pages.length) {
            setState(() {
              _page = index;
            });
          }
        },
      ),
    );
  }
}
