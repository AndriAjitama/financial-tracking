// ignore_for_file: unnecessary_const, use_super_parameters, prefer_const_literals_to_create_immutables, sort_child_properties_last, library_private_types_in_public_api, unnecessary_to_list_in_spreads, unrelated_type_equality_checks

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_tracking/pages/transaction/add_transaction.dart';
import 'package:financial_tracking/pages/transaction/edit_transaction.dart';
import 'package:financial_tracking/service/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTab extends StatelessWidget {
  const TransactionTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
                  labelStyle: TextStyle(fontSize: 12),
                  tabs: [
                    Tab(text: 'All'),
                    Tab(text: 'Income'),
                    Tab(text: 'Expense'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: const TabBarView(
            children: [
              TransactionList(type: null),
              TransactionList(type: 'Income'),
              TransactionList(type: 'Expense'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTransaction()),
            );
          },
          heroTag: 'addTransaction',
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}

class TransactionList extends StatefulWidget {
  final String? type;
  final String? category;

  const TransactionList({Key? key, this.type, this.category}) : super(key: key);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  late Stream<QuerySnapshot<Object?>> transactionStream;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    transactionStream = widget.type == null
        ? FirebaseFirestore.instance.collection('Transaction').snapshots()
        : FirebaseFirestore.instance
            .collection('Transaction')
            .where('type', isEqualTo: widget.type)
            .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          child: SizedBox(
            height: 40,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.green, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot<Object?>>(
            stream: transactionStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final transactions = snapshot.data!.docs;

              if (transactions.isEmpty) {
                return const Center(
                  child: Text(
                    'No items found',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                );
              }

              // Sort transactions by date descending
              transactions.sort((a, b) {
                DateTime dateA = (a['date'] as Timestamp).toDate();
                DateTime dateB = (b['date'] as Timestamp).toDate();
                return dateB.compareTo(dateA);
              });

              // Filter and group transactions by month
              Map<String, List<DocumentSnapshot>> groupedTransactions = {};
              Map<String, Map<String, double>> totalsPerMonth = {};

              for (var transaction in transactions) {
                DateTime date = (transaction['date'] as Timestamp).toDate();
                String key = DateFormat('MMMM yyyy').format(date);

                final matchesSearch = searchQuery.isEmpty ||
                    transaction['description']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery) ||
                    transaction['category']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery);

                if (!groupedTransactions.containsKey(key)) {
                  groupedTransactions[key] = [];
                  totalsPerMonth[key] = {'income': 0, 'expense': 0};
                }

                if (matchesSearch) {
                  groupedTransactions[key]!.add(transaction);

                  // Calculate totals
                  String type = transaction['type'];
                  double amount = transaction['amount'].toDouble();

                  if (type == 'Income') {
                    totalsPerMonth[key]!['income'] =
                        (totalsPerMonth[key]!['income'] ?? 0) + amount;
                  } else if (type == 'Expense') {
                    totalsPerMonth[key]!['expense'] =
                        (totalsPerMonth[key]!['expense'] ?? 0) + amount;
                  }
                }
              }

              final groupedKeys = groupedTransactions.keys.toList();

              return ListView.builder(
                itemCount: groupedKeys.length,
                itemBuilder: (context, index) {
                  final monthKey = groupedKeys[index];
                  final monthTransactions = groupedTransactions[monthKey]!;
                  final totals = totalsPerMonth[monthKey]!;
                  final currencyFormatter = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  );
                  // Skip months with no matching transactions
                  if (monthTransactions.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with totals
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              monthKey,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            Row(
                              children: [
                                // Income dengan warna hijau
                                Text(
                                  currencyFormatter.format(totals['income']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                // Expense dengan warna abu-abu
                                Text(
                                  currencyFormatter.format(totals['expense']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Transaction List
                      ...monthTransactions.map((transaction) {
                        return TransactionListItem(
                          transactionData: transaction,
                          onEdit: () => _onEdit(context, transaction),
                          onDelete: () => _onDelete(context, transaction),
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _onEdit(BuildContext context, DocumentSnapshot ds) {
    TextEditingController amountController =
        TextEditingController(text: ds["amount"].toString());
    TextEditingController descriptionController =
        TextEditingController(text: ds['description']);
    TextEditingController dateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy')
            .format((ds['date'] as Timestamp).toDate()));

    EditTransaction(
      context,
      ds.id,
      ds['type'],
      ds['category'],
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
              DatabaseMethods().deleteTransaction(ds.id);
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

class TransactionListItem extends StatelessWidget {
  final DocumentSnapshot transactionData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionListItem({
    Key? key,
    required this.transactionData,
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
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: Image.asset(
                  transactionData['type'] == 'Income'
                      ? 'assets/images/income.png'
                      : 'assets/images/expense.png',
                  height: 35,
                  width: 33,
                ),
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
                          transactionData['category'],
                          style: const TextStyle(
                              fontSize: 22,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd-MM-yyyy').format(
                              (transactionData['date'] as Timestamp).toDate()),
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(transactionData['type'],
                            style: const TextStyle(fontSize: 15)),
                        Text(
                          '${_getTypeAmountPrefix(transactionData['type'])} Rp ${NumberFormat.decimalPattern('id').format(transactionData['amount'])}',
                          style: TextStyle(
                              fontSize: 20,
                              color:
                                  _getTypeAmountColor(transactionData['type']),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                    const SizedBox(height: 0),
                    Text(transactionData['description'],
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeAmountColor(String type) {
    switch (type) {
      case 'Income':
        return Colors.green;
      case 'Expense':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getTypeAmountPrefix(String type) {
    switch (type) {
      case 'Income':
        return "";
      case 'Expense':
        return "-";
      default:
        return "N/A";
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
