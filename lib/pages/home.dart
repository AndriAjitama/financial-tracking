// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:financial_tracking/pages/financial.dart';
import 'package:financial_tracking/pages/financial/financial_list.dart';
import 'package:financial_tracking/pages/financial/financial_tracking_summary_card.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F3F9),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Financial',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tracking',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FinancialTrackingSummaryCard(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Financial()),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'View more',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: FinancialTrackingList(),
            ),
          ],
        ),
      ),
    );
  }
}
