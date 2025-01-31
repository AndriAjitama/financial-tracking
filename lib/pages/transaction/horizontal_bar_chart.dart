// ignore_for_file: use_super_parameters, library_private_types_in_public_api, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HorizontalBarChartPage extends StatefulWidget {
  const HorizontalBarChartPage({Key? key}) : super(key: key);

  @override
  _HorizontalBarChartPageState createState() => _HorizontalBarChartPageState();
}

class _HorizontalBarChartPageState extends State<HorizontalBarChartPage> {
  final Map<String, List<String>> categories = {
    'Income': [
      'Salary',
      'Gift',
      'Asset Sales',
      'Business',
      'Freelance',
      'Other'
    ],
    'Expense': [
      'Cigarette',
      'Fuel',
      'Food',
      'Drink',
      'Bill',
      'Investment',
      'Installment',
      'Housing',
      'Personal Needs',
      'Transportation',
      'Communication',
      'Education',
      'Health & Insurance',
      'Entertainment',
      'Donation',
      'Other',
    ],
  };

  final Map<String, Map<String, double>> categoryTotals = {};
  String? selectedCategory;
  double? selectedAmount;

  @override
  void initState() {
    super.initState();
    // Start listening to the Firestore data stream
    _listenToCategoryTotals();
  }

  // Listen to Firestore updates
  void _listenToCategoryTotals() {
    FirebaseFirestore.instance
        .collection('Transaction')
        .snapshots()
        .listen((querySnapshot) {
      _calculateCategoryTotals(querySnapshot);
    });
  }

  // Calculate totals based on Firestore data
  Future<void> _calculateCategoryTotals(QuerySnapshot querySnapshot) async {
    Map<String, Map<String, double>> tempTotals = {
      'Income': {},
      'Expense': {},
    };

    for (var doc in querySnapshot.docs) {
      String type = doc['type'];
      String category = doc['category'];
      double amount = 0;

      if (doc['amount'] is String) {
        amount = double.parse(doc['amount'].replaceAll('.', ''));
      } else if (doc['amount'] is int) {
        amount = doc['amount'].toDouble();
      } else if (doc['amount'] is double) {
        amount = doc['amount'];
      }

      if (tempTotals[type] != null) {
        tempTotals[type]![category] =
            (tempTotals[type]![category] ?? 0) + amount;
      }
    }

    setState(() {
      categoryTotals.clear();
      categoryTotals.addAll(tempTotals);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Income & Expense Bar Chart',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: categoryTotals.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  _buildBarChart('Income'),
                  const SizedBox(height: 20),
                  _buildBarChart('Expense'),
                  if (selectedCategory != null && selectedAmount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Category: $selectedCategory\nAmount: Rp ${NumberFormat("#,##0").format(selectedAmount)}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildBarChart(String type) {
    final data = categoryTotals[type] ?? {};
    final List<String> categoryList = categories[type] ?? [];

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < categoryList.length; i++) {
      final category = categoryList[i];
      final value = data[category] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: value,
              width: 16,
              colors: [type == 'Income' ? Colors.blue : Colors.red],
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$type Distribution',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 0),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              maxY: data.values.isNotEmpty
                  ? data.values.reduce((a, b) => a > b ? a : b) * 1.2
                  : 1,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: SideTitles(showTitles: false),
                rightTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (context, value) => const TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                topTitles: SideTitles(showTitles: false),
                bottomTitles: SideTitles(
                  showTitles: false,
                  getTitles: (value) {
                    return categoryList[value.toInt()];
                  },
                  reservedSize: 20,
                  interval: 1,
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${categoryList[group.x.toInt()]}\n',
                      const TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: 'Rp ${NumberFormat("#,##0").format(rod.y)}',
                        ),
                      ],
                    );
                  },
                ),
                touchCallback: (event, response) {
                  if (event.isInterestedForInteractions &&
                      response?.spot != null) {
                    final index = response!.spot!.touchedBarGroupIndex;
                    final category = categoryList[index];
                    final amount = data[category] ?? 0;

                    setState(() {
                      selectedCategory = category;
                      selectedAmount = amount;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
