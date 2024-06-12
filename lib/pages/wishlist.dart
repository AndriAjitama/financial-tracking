// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:financial_tracking/pages/wishlist/list_wishlist.dart';
import 'package:flutter/material.dart';

class Wishlist extends StatelessWidget {
  const Wishlist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F3F9),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'My',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Wishlist',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: const WishlistTab(),
      ),
    );
  }
}
