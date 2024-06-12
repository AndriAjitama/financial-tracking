// ignore_for_file: library_private_types_in_public_api, use_super_parameters, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinancialTrackingSummaryCard extends StatefulWidget {
  const FinancialTrackingSummaryCard({Key? key}) : super(key: key);

  @override
  _FinancialTrackingSummaryCardState createState() =>
      _FinancialTrackingSummaryCardState();
}

class _FinancialTrackingSummaryCardState
    extends State<FinancialTrackingSummaryCard> {
  double totalIncome = 0;
  double totalExpenses = 0;
  double balance = 0;

  @override
  void initState() {
    super.initState();
    _calculateFinancialSummary();
  }

  Future<void> _calculateFinancialSummary() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('FinancialTracking').get();
    double income = 0;
    double expenses = 0;

    for (var doc in querySnapshot.docs) {
      double amount = double.parse(doc['amount'].replaceAll('.', ''));
      if (doc['type'] == 'Income') {
        income += amount;
      } else if (doc['type'] == 'Expense') {
        expenses += amount;
      }
    }

    setState(() {
      totalIncome = income;
      totalExpenses = expenses;
      balance = income - expenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(7.0),
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Rp. ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(balance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('assets/images/income.png', 'Income',
                  totalIncome, Colors.white),
              _buildSummaryItem('assets/images/expense.png', 'Expense',
                  totalExpenses, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String iconPath, String label, double amount, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          child: Image.asset(
            iconPath,
            height: 35,
            width: 35,
            // color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          NumberFormat.decimalPattern('id').format(amount),
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
