// ignore_for_file: prefer_interpolation_to_compose_strings, use_super_parameters, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryTransaction extends StatelessWidget {
  const SummaryTransaction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Transaction').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Inisialisasi total
        double totalIncome = 0;
        double totalExpenses = 0;

        // Hitung total income dan expenses
        for (var doc in snapshot.data!.docs) {
          double amount = 0;

          if (doc['amount'] is String) {
            amount = double.parse(doc['amount'].replaceAll('.', ''));
          } else if (doc['amount'] is int) {
            amount = doc['amount'].toDouble();
          } else if (doc['amount'] is double) {
            amount = doc['amount'];
          }

          if (doc['type'] == 'Income') {
            totalIncome += amount;
          } else if (doc['type'] == 'Expense') {
            totalExpenses += amount;
          }
        }

        double totalBalance = totalIncome - totalExpenses;

        // Bangun UI berdasarkan data
        return Container(
          padding:
              const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
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
              const SizedBox(height: 0),
              Text(
                'Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(totalBalance)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
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
      },
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
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Rp ' + NumberFormat.decimalPattern('id').format(amount),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
