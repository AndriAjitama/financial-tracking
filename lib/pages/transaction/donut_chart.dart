// ignore_for_file: use_super_parameters, library_private_types_in_public_api, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DonutChartPage extends StatefulWidget {
  const DonutChartPage({Key? key}) : super(key: key);

  @override
  _DonutChartPageState createState() => _DonutChartPageState();
}

class _DonutChartPageState extends State<DonutChartPage> {
  final Map<String, List<String>> categories = {
    'Income': [
      'Salary',
      'Gift',
      'Asset Sales',
      'Business',
      'Freelance',
      'Other',
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

  // Daftar warna yang tetap
  final List<Color> incomeColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
  ];
  final List<Color> expenseColors = [
    Colors.red,
    Colors.blueGrey,
    Colors.pink,
    Colors.cyan,
    Colors.indigo,
    Colors.amber,
    Colors.deepOrange,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.yellow,
    Colors.purpleAccent,
    Colors.lime,
    Colors.green,
    Colors.deepPurple,
    Colors.cyanAccent,
    Colors.orangeAccent,
  ];

  @override
  void initState() {
    super.initState();
    _calculateCategoryTotals();
  }

  Future<void> _calculateCategoryTotals() async {
    Map<String, Map<String, double>> tempTotals = {
      'Income': {},
      'Expense': {},
    };

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Transaction').get();

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
      categoryTotals.addAll(tempTotals);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Income & Expense Donut Chart',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: categoryTotals.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDonutChart('Income'),
                    SizedBox(height: 20),
                    _buildDonutChart('Expense'),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDonutChart(String type) {
    final data = categoryTotals[type] ?? {};
    final List<PieChartSectionData> sections = data.entries.map(
      (entry) {
        // Menggunakan urutan kategori dari categories
        final List<String> categoryList = categories[type] ?? [];
        final int index = categoryList.indexOf(entry.key);

        // Pastikan tidak ada indeks yang invalid
        final color = type == 'Income'
            ? (index >= 0 && index < incomeColors.length
                ? incomeColors[index]
                : Colors.grey)
            : (index >= 0 && index < expenseColors.length
                ? expenseColors[index]
                : Colors.grey);

        // Menampilkan jumlah amount pada kategori
        final amountFormatted = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(entry.value);

        return PieChartSectionData(
          color: color,
          value: entry.value,
          title: '$amountFormatted\n${entry.key}',
          radius: 70,
          titleStyle: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        );
      },
    ).toList();

    // Mendapatkan ukuran layar
    double screenWidth = MediaQuery.of(context).size.width;
    double chartWidth = screenWidth * 1;

    return Column(
      children: [
        Text(
          '$type Distribution',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 0),
        Container(
          width: chartWidth,
          height: chartWidth,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 80,
              sectionsSpace: 2,
            ),
          ),
        ),
      ],
    );
  }
}
