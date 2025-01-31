// ignore_for_file: prefer_const_literals_to_create_immutables, unused_element, avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_tracking/service/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddMoney extends StatefulWidget {
  const AddMoney({super.key});

  @override
  State<AddMoney> createState() => _AddMoneyState();
}

class _AddMoneyState extends State<AddMoney> {
  String _selectedType = 'Cash';
  String _selectedCategory = 'Wallet';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Daftar kategori berdasarkan jenis transaksi
  final Map<String, List<String>> _categories = {
    'Cash': ['Wallet', 'Savings'],
    'Account': [
      'Bank BCA',
      'Bank BRI',
      'Bank BTN',
      'Bank BNI',
      'Bank Jago',
      'Bank Mandiri',
      'Gopay',
      'Dana',
      'ShopeePay',
      'SeaBank',
      'E-Money',
      'RDN Wallet'
    ],
    'Investment': ['Bibit', 'Stockbit', 'Crypto', 'Gold', 'Property'],
  };

  void _updateCategoryList() {
    setState(() {
      // Tetapkan kategori pertama dari jenis transaksi yang dipilih sebagai default
      _selectedCategory = _categories[_selectedType]!.first;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
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

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

// Styling for TextFields and Buttons
  InputDecoration _inputDecoration(String labelText, [BuildContext? context]) {
    return InputDecoration(
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade600, width: 1.0),
        borderRadius: BorderRadius.circular(8),
      ),
      labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 16),
      floatingLabelStyle: TextStyle(color: Colors.blue, fontSize: 14),
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      suffixIcon: context != null
          ? IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context, _dateController),
            )
          : null,
    );
  }

  // Styling for Dropdown and Button
  BoxDecoration _dropdownDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade600, width: 1),
      borderRadius: BorderRadius.circular(8),
    );
  }

  BoxDecoration _buttonDecoration() {
    return BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(50),
    );
  }

  bool _validateInputs() {
    if (_selectedType.isEmpty ||
        _selectedCategory.isEmpty ||
        _titleController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _dateController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Semua kolom wajib diisi!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (!_validateInputs()) return;

    try {
      String id = randomAlphaNumeric(10);
      int amount =
          int.parse(_amountController.text.replaceAll(RegExp(r'\D'), ''));
      DateTime date = DateFormat('dd-MM-yyyy').parse(_dateController.text);

      Map<String, dynamic> moneyInfoMap = {
        'id': id,
        'type': _selectedType,
        'category': _selectedCategory,
        'title': _titleController.text.trim(),
        'amount': amount,
        'description': _descriptionController.text.trim(),
        'date': Timestamp.fromDate(date),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await DatabaseMethods().addMoney(moneyInfoMap, id);

      Fluttertoast.showToast(
        msg: "Data berhasil disimpan!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14,
      );

      setState(() {
        _selectedType = 'Cash';
        _selectedCategory = 'Wallet';
        _titleController.clear();
        _amountController.clear();
        _descriptionController.clear();
        _dateController.clear();
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Terjadi kesalahan: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 16),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('My',
                style: TextStyle(
                    color: Colors.purple,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Text('Money',
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Stack(
                  children: [
                    Container(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.grey.shade600, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                menuMaxHeight: 350,
                                borderRadius: BorderRadius.circular(10),
                                isExpanded: true,
                                value: _selectedType,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                dropdownColor: Colors.white,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedType = newValue;
                                    });
                                    _updateCategoryList();
                                  }
                                },
                                items: <String>[
                                  'Cash',
                                  'Account',
                                  'Investment'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  final isSelected = value == _selectedType;
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.green.shade100
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.black,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: -6,
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                'Select Type',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              Container(
                child: Stack(
                  children: [
                    Container(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.grey.shade600, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                menuMaxHeight: 350,
                                borderRadius: BorderRadius.circular(10),
                                isExpanded: true,
                                value: _selectedCategory,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                dropdownColor: Colors.white,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedCategory = newValue;
                                    });
                                  }
                                },
                                items: _categories[_selectedType]!
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  final isSelected = value == _selectedCategory;
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.green.shade100
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.black,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: -6,
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                'Select Category',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              TextField(
                  controller: _titleController,
                  decoration: _inputDecoration('Title')),
              SizedBox(height: 20),
              TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Amount'),
                  onChanged: (text) => _formatAmount()), // Apply format
              SizedBox(height: 20),
              TextField(
                  controller: _descriptionController,
                  decoration: _inputDecoration('Description')),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context, _dateController),
                child: AbsorbPointer(
                  child: TextField(
                      controller: _dateController,
                      decoration: _inputDecoration('Select Date', context)),
                ),
              ),
              SizedBox(height: 30),
              // Submit Button
              GestureDetector(
                onTap: _submitForm,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: _buttonDecoration(),
                  child: Center(
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
