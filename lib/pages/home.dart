// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:financial_tracking/pages/transaction/bar_chart.dart';
import 'package:financial_tracking/pages/transaction/donut_chart.dart';
import 'package:financial_tracking/pages/transaction/horizontal_bar_chart.dart';
import 'package:financial_tracking/pages/transaction/summary_transaction.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 40,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary section
              const SummaryTransaction(),
              const SizedBox(height: 10),

              // Donut Chart Section
              SizedBox(
                height: 410,
                child: DonutChartPage(),
              ),
              const SizedBox(height: 20),
              // Horizontal Bar Chart Section
              SizedBox(
                height: 700,
                child: HorizontalBarChartPage(),
              ),
              // Bar Chart Section
              SizedBox(
                height: 400,
                child: BarChartPage(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
