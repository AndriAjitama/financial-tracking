// ignore_for_file: unnecessary_const, use_super_parameters, prefer_const_literals_to_create_immutables, sort_child_properties_last, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_tracking/pages/money/add_money.dart';
import 'package:financial_tracking/pages/money/edit_money.dart';
import 'package:financial_tracking/service/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoneyTab extends StatelessWidget {
  const MoneyTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 50,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green.shade100,
                border: Border.all(color: Colors.green),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicator: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(fontSize: 12),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Cash'),
                    Tab(text: 'Account'),
                    Tab(text: 'Investment'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            const TotalAmountSummary(),
            Expanded(
              child: const TabBarView(
                children: [
                  MoneyList(type: null),
                  MoneyList(type: 'Cash'),
                  MoneyList(type: 'Account'),
                  MoneyList(type: 'Investment'),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMoney()),
            );
          },
          heroTag: 'addMoney',
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}

class TotalAmountSummary extends StatelessWidget {
  const TotalAmountSummary({Key? key}) : super(key: key);

  Stream<Map<String, double>> _calculateTotalPerType() {
    return FirebaseFirestore.instance
        .collection('Money')
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs;

      Map<String, double> totalPerType = {
        'All': 0,
        'Cash': 0,
        'Account': 0,
        'Investment': 0,
      };

      for (var doc in docs) {
        final type = doc['type'] ?? 'All';
        final amount = (doc['amount'] as num).toDouble();
        totalPerType['All'] = totalPerType['All']! + amount;
        if (totalPerType.containsKey(type)) {
          totalPerType[type] = totalPerType[type]! + amount;
        }
      }

      return totalPerType;
    });
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: StreamBuilder<Map<String, double>>(
        stream: _calculateTotalPerType(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final totals = snapshot.data!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                currencyFormat.format(totals['All']),
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                currencyFormat.format(totals['Cash']),
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                currencyFormat.format(totals['Account']),
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                currencyFormat.format(totals['Investment']),
                style: const TextStyle(fontSize: 11),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MoneyList extends StatefulWidget {
  final String? type;
  final String? category;
  const MoneyList({Key? key, this.type, this.category}) : super(key: key);

  @override
  _MoneyListState createState() => _MoneyListState();
}

class _MoneyListState extends State<MoneyList> {
  late Stream<QuerySnapshot<Object?>> moneyStream;

  @override
  void initState() {
    super.initState();
    moneyStream = widget.type == null
        ? FirebaseFirestore.instance.collection('Money').snapshots()
        : FirebaseFirestore.instance
            .collection('Money')
            .where('type', isEqualTo: widget.type)
            .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Object?>>(
      stream: moneyStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final money = snapshot.data!.docs;
        if (money.isEmpty) {
          return const Center(
            child: Text(
              'No items found',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          );
        }

        money.sort((a, b) {
          DateTime dateA = (a['date'] as Timestamp).toDate();
          DateTime dateB = (b['date'] as Timestamp).toDate();
          return dateA.compareTo(dateB);
        });

        return ListView.builder(
          itemCount: money.length,
          itemBuilder: (context, index) {
            final ds = money[index];
            return MoneyListItem(
              moneyData: ds,
              onEdit: () => _onEdit(context, ds),
              onDelete: () => _onDelete(context, ds),
            );
          },
        );
      },
    );
  }

  void _onEdit(BuildContext context, DocumentSnapshot ds) {
    TextEditingController titleController =
        TextEditingController(text: ds['title']);
    TextEditingController amountController =
        TextEditingController(text: ds["amount"].toString());
    TextEditingController descriptionController =
        TextEditingController(text: ds['description']);
    TextEditingController dateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy')
            .format((ds['date'] as Timestamp).toDate()));

    EditMoney(
      context,
      ds.id,
      ds['type'],
      ds['category'],
      titleController,
      amountController,
      descriptionController,
      dateController,
      selectDate,
    );
  }

  void _onDelete(BuildContext context, DocumentSnapshot ds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Delete Confirmation",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),
        ),
        content: const Text(
          "Apakah Anda yakin akan menghapus data ini?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue,
              ),
              child: const Text("Cancel",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              DatabaseMethods().deleteMoney(ds.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.red,
              ),
              child: const Text("Delete",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class MoneyListItem extends StatelessWidget {
  final DocumentSnapshot moneyData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final Map<String, String> categoryImages = {
    'Wallet': 'assets/images/wallet.png',
    'Savings': 'assets/images/savings.png',
    'Bank BCA': 'assets/images/bca.png',
    'Bank BRI': 'assets/images/bri.png',
    'Bank BTN': 'assets/images/btn.png',
    'Bank BNI': 'assets/images/bni.png',
    'Bank Jago': 'assets/images/jago.png',
    'Bank Mandiri': 'assets/images/mandiri.png',
    'Gopay': 'assets/images/gopay.png',
    'Dana': 'assets/images/dana.png',
    'ShopeePay': 'assets/images/shopeepay.png',
    'SeaBank': 'assets/images/seabank.png',
    'E-Money': 'assets/images/emoney.png',
    'RDN Wallet': 'assets/images/jago.png',
    'Bibit': 'assets/images/bibit.png',
    'Stockbit': 'assets/images/stockbit.png',
    'Crypto': 'assets/images/crypto.png',
    'Gold': 'assets/images/gold.png',
    'Property': 'assets/images/property.png',
  };

  MoneyListItem({
    Key? key,
    required this.moneyData,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Container(
                width: 15,
                height: 135,
                color: _getTypeColor(moneyData['type']),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          moneyData['category'],
                          style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: onEdit,
                              child: const Icon(Icons.edit,
                                  color: Colors.orange, size: 23),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: onDelete,
                              child: const Icon(Icons.delete,
                                  color: Colors.red, size: 23),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 15,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                            color: Colors.transparent,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(0),
                              child: Image.asset(
                                categoryImages[moneyData['category']] ??
                                    'assets/images/rupiah.png',
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Rp ${NumberFormat.decimalPattern('id').format(moneyData['amount'])}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(moneyData['title'],
                            style: TextStyle(
                                fontSize: 17, color: Colors.green.shade400)),
                        Text(
                          DateFormat('dd-MM-yyyy').format(
                              (moneyData['date'] as Timestamp).toDate()),
                          style:
                              const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                    Text(moneyData['description'],
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Cash':
        return Colors.green.shade300;
      case 'Account':
        return Colors.green.shade600;
      case 'Investment':
        return Colors.green.shade800;
      default:
        return Colors.grey;
    }
  }
}

Future<void> selectDate(
    BuildContext context, TextEditingController controller) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: Colors.blue),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue)),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    controller.text = DateFormat('dd-MM-yyyy').format(picked);
  }
}
