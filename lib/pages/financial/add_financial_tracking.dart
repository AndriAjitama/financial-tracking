// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, depend_on_referenced_packages, unnecessary_new, unnecessary_import, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_tracking/service/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddFinancialTracking extends StatefulWidget {
  const AddFinancialTracking({super.key});

  @override
  State<AddFinancialTracking> createState() => _AddFinancialTrackingState();
}

class _AddFinancialTrackingState extends State<AddFinancialTracking> {
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
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F3F9),
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F3F9),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue!;
                      _selectedCategory = _categories[_selectedType]![0];
                    });
                  },
                  items: <String>['Income', 'Expense']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  underline: SizedBox(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Category',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items: _categories[_selectedType]!
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  underline: SizedBox(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Amount',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter your amount',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Description',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Enter your description',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Date',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    hintText: 'Select a date',
                    border: InputBorder.none,
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 40),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  width: double.maxFinite,
                  child: ElevatedButton(
                    onPressed: () async {
                      String id = randomAlphaNumeric(10);
                      Map<String, dynamic> financialInfoMap = {
                        'id': id,
                        'type': _selectedType,
                        'category': _selectedCategory,
                        'amount': _amountController.text,
                        'description': _descriptionController.text,
                        'date': _dateController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      };
                      try {
                        await DatabaseMethods()
                            .addFinancialDetails(financialInfoMap, id);
                        Fluttertoast.showToast(
                          msg: "Created Successfully!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: "Failed to create: $e",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.only(top: 12, bottom: 12)),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
