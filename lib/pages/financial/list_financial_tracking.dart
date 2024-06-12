// ignore_for_file: use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, use_super_parameters, await_only_futures, avoid_function_literals_in_foreach_calls, sort_child_properties_last, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_tracking/pages/financial/add_financial_tracking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:financial_tracking/service/database.dart';
import 'package:financial_tracking/pages/financial/edit_financial_tracking.dart';

class Tabs extends StatelessWidget {
  const Tabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFF1F3F9),
          title: const Text(
            'Transactions',
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green.shade100,
                border: Border.all(
                  color: Colors.green,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicator: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: TextStyle(
                    fontSize: 15,
                  ),
                  tabs: [
                    Tab(
                      text: 'All',
                    ),
                    Tab(
                      text: 'Income',
                    ),
                    Tab(
                      text: 'Expense',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Container(
          color: Color(0xFFF1F3F9),
          child: TabBarView(
            children: [
              FinancialTrackingList(type: null),
              FinancialTrackingList(type: 'Income'),
              FinancialTrackingList(type: 'Expense'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddFinancialTracking()),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}

class FinancialTrackingList extends StatefulWidget {
  final String? type;

  const FinancialTrackingList({Key? key, this.type}) : super(key: key);

  @override
  State<FinancialTrackingList> createState() => _FinancialTrackingListState();
}

class _FinancialTrackingListState extends State<FinancialTrackingList> {
  Stream? financialStream;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _selectedType = 'Income';
  String _selectedCategory = 'Gaji';
  final Map<String, List<String>> _categories = {
    'Income': ['Gaji', 'Dikasih', 'BeaSiswa', 'Penjualan Aset', 'Lainnya'],
    'Expense': [
      'Roko',
      'Bensin',
      'Makan',
      'Minum',
      'Keperluan Pribadi',
      'Transportasi',
      'Komunikasi',
      'Pendidikan',
      'Kesehatan',
      'Hiburan',
      'Donasi',
      'Lainnya'
    ],
  };

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getontheload();
    _amountController.addListener(_formatAmount);
  }

  void _formatAmount() {
    String currentText = _amountController.text;
    if (currentText.isNotEmpty) {
      String digitsOnly = currentText.replaceAll(RegExp(r'\D'), '');
      int? number = int.tryParse(digitsOnly);
      if (number != null) {
        String formatted = NumberFormat.decimalPattern('id').format(number);
        _amountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  getontheload() async {
    financialStream = await FirebaseFirestore.instance
        .collection('FinancialTracking')
        .orderBy('timestamp', descending: true)
        .snapshots();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: financialStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No items found',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          );
        }
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No items found',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    );
                  }
                  if (widget.type != null && ds['type'] != widget.type) {
                    return SizedBox.shrink();
                  }

                  IconData icon = ds['type'] == 'Income'
                      ? Icons.arrow_downward_outlined
                      : Icons.arrow_upward_outlined;

                  String iconPath = ds['type'] == 'Income'
                      ? 'assets/images/income.png'
                      : 'assets/images/expense.png';

                  Color amountColor =
                      ds['type'] == 'Income' ? Colors.green : Colors.grey;
                  String amountPrefix = ds['type'] == 'Income' ? '' : '-';

                  return Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
                                  child: Image.asset(
                                    iconPath,
                                    height: 35,
                                    width: 33,
                                    // color: amountColor,
                                  ),
                                  // child: Icon(
                                  //   icon,
                                  //   size: 28,
                                  //   color: amountColor,
                                  // ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              ds['category'],
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedType =
                                                          ds['type'];
                                                      _amountController.text =
                                                          ds['amount'];
                                                      _descriptionController
                                                              .text =
                                                          ds['description'];
                                                      _dateController.text =
                                                          ds['date'];
                                                      _categories.forEach(
                                                          (key, value) {
                                                        if (value.contains(
                                                            ds['category'])) {
                                                          _selectedType = key;
                                                          _selectedCategory =
                                                              ds['category'];
                                                        }
                                                      });
                                                    });

                                                    EditFinancialTracking(
                                                      context,
                                                      ds["id"],
                                                      _selectedType,
                                                      _selectedCategory,
                                                      _categories,
                                                      _amountController,
                                                      _descriptionController,
                                                      _dateController,
                                                      _selectDate,
                                                      _formatAmount,
                                                    );
                                                  },
                                                  child: const Icon(
                                                    Icons.edit,
                                                    color: Colors.orange,
                                                    size: 23,
                                                  ),
                                                ),
                                                const SizedBox(width: 7),
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                            "Delete Confirmation",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          content: Text(
                                                            "Apakah Anda yakin akan menghapus data ini?",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20,
                                                                        vertical:
                                                                            10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  color: Colors
                                                                      .blue,
                                                                ),
                                                                child: Text(
                                                                  "Cancel",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                DatabaseMethods()
                                                                    .deleteFinancialDetails(
                                                                        ds["id"]);
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20,
                                                                        vertical:
                                                                            10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                child: Text(
                                                                  "Delete",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                    size: 23,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              ds['date'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              ds['type'],
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              '$amountPrefix Rp.${ds['amount']}',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: amountColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                ds['description'],
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }
}
