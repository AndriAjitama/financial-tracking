// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class BarChartPage extends StatefulWidget {
  const BarChartPage({Key? key}) : super(key: key);

  @override
  _BarChartPageState createState() => _BarChartPageState();
}

class _BarChartPageState extends State<BarChartPage> {
  final Map<String, Map<String, double>> incomeData = {};
  final Map<String, Map<String, double>> expenseData = {};

  @override
  void initState() {
    super.initState();
  }

  // Menggunakan StreamBuilder untuk mendapatkan data secara real-time
  Stream<QuerySnapshot> _getTransactionStream() {
    return FirebaseFirestore.instance.collection('Transaction').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Income vs Expense Per Month',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getTransactionStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Reset data setiap kali data baru diterima
          incomeData.clear();
          expenseData.clear();

          for (var doc in snapshot.data!.docs) {
            String type = doc['type'] ?? '';
            double amount = (doc['amount'] ?? 0).toDouble();
            Timestamp timestamp = doc['date'];
            DateTime date = timestamp.toDate();
            String year = date.year.toString();
            String month = date.month.toString().padLeft(2, '0');

            if (type == 'Income') {
              incomeData[year] ??= {};
              incomeData[year]![month] =
                  (incomeData[year]![month] ?? 0) + amount;
            } else if (type == 'Expense') {
              expenseData[year] ??= {};
              expenseData[year]![month] =
                  (expenseData[year]![month] ?? 0) + amount;
            }
          }

          return ListView(
            padding: const EdgeInsets.only(left: 16, right: 0, top: 0),
            children: [
              for (String year in incomeData.keys) ...[
                Text(
                  'Income vs Expense - $year',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: _buildBarChart(
                      year, incomeData[year] ?? {}, expenseData[year] ?? {}),
                ),
                const SizedBox(height: 32),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildBarChart(
      String year, Map<String, double> income, Map<String, double> expense) {
    final highestValue = _getHighestValue(income, expense);
    final maxY = highestValue + (highestValue * 0.1);

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = rod.y;
              final formattedValue =
                  NumberFormat('#,###', 'en_US').format(value);
              return BarTooltipItem(
                'Rp $formattedValue',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, horizontalInterval: maxY / 5),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(showTitles: false),
          topTitles: SideTitles(
            showTitles: true,
            margin: -10,
            getTextStyles: (context, value) => const TextStyle(
              fontSize: 10,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          rightTitles: SideTitles(
            showTitles: true,
            getTitles: (double value) {
              if (value == maxY) return '100M';
              return NumberFormat.compactCurrency(decimalDigits: 0, symbol: '')
                  .format(value);
            },
            getTextStyles: (context, value) => const TextStyle(
              fontSize: 10,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (double value) {
              final month = value.toInt();
              const monthNames = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec'
              ];
              return monthNames[month - 1];
            },
            getTextStyles: (context, value) => const TextStyle(
              fontSize: 10,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        barGroups: _buildBarGroups(income, expense),
        alignment: BarChartAlignment.spaceBetween,
      ),
    );
  }

  num _getHighestValue(
      Map<String, double> income, Map<String, double> expense) {
    final incomeMax = income.values.isNotEmpty
        ? income.values.reduce((a, b) => a > b ? a : b)
        : 0;
    final expenseMax = expense.values.isNotEmpty
        ? expense.values.reduce((a, b) => a > b ? a : b)
        : 0;
    return incomeMax > expenseMax ? incomeMax : expenseMax;
  }

  List<BarChartGroupData> _buildBarGroups(
      Map<String, double> income, Map<String, double> expense) {
    List<BarChartGroupData> groups = [];
    for (int i = 1; i <= 12; i++) {
      final month = i.toString().padLeft(2, '0');
      final incomeValue = income[month] ?? 0;
      final expenseValue = expense[month] ?? 0;

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: incomeValue,
              colors: [Colors.blue],
              width: 8,
            ),
            BarChartRodData(
              y: expenseValue,
              colors: [Colors.red],
              width: 8,
            ),
          ],
        ),
      );
    }
    return groups;
  }
}
