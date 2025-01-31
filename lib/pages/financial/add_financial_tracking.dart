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
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Button text color
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black, // Warna ikon
            size: 16, // Ukuran ikon
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Aksi kembali
          },
        ),
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
          margin: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Stack(
                  children: [
                    Container(
                      child: Stack(
                        clipBehavior: Clip.none, // Menghindari elemen terpotong
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
                                isExpanded: true,
                                value: _selectedType,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                dropdownColor: Colors.white,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedType = newValue!;
                                    _selectedCategory =
                                        _categories[_selectedType]![0];
                                  });
                                },
                                items: <String>[
                                  'Income',
                                  'Expense'
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
                            top: -6, // Pastikan teks muncul sepenuhnya
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
              // Text(
              //   'Type',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: 10),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 10),
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.black),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: DropdownButton<String>(
              //     isExpanded: true,
              //     value: _selectedType,
              //     onChanged: (String? newValue) {
              //       setState(() {
              //         _selectedType = newValue!;
              //         _selectedCategory = _categories[_selectedType]![0];
              //       });
              //     },
              //     items: <String>['Income', 'Expense']
              //         .map<DropdownMenuItem<String>>((String value) {
              //       return DropdownMenuItem<String>(
              //         value: value,
              //         child: Text(value),
              //       );
              //     }).toList(),
              //     underline: SizedBox(),
              //   ),
              // ),
              SizedBox(height: 20),
              Container(
                child: Stack(
                  children: [
                    Container(
                      child: Stack(
                        clipBehavior: Clip.none, // Menghindari elemen terpotong
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
                                isExpanded: true,
                                value: _selectedCategory,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                dropdownColor: Colors.white,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue!;
                                  });
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
                            top: -6, // Pastikan teks muncul sepenuhnya
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
              // Text(
              //   'Category',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: 10),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 10),
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.black),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: DropdownButton<String>(
              //     isExpanded: true,
              //     value: _selectedCategory,
              //     onChanged: (String? newValue) {
              //       setState(() {
              //         _selectedCategory = newValue!;
              //       });
              //     },
              //     items: _categories[_selectedType]!
              //         .map<DropdownMenuItem<String>>((String value) {
              //       return DropdownMenuItem<String>(
              //         value: value,
              //         child: Text(value),
              //       );
              //     }).toList(),
              //     underline: SizedBox(),
              //   ),
              // ),
              SizedBox(height: 20),
              Container(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        'Amount', // Label yang berfungsi sebagai placeholder
                    floatingLabelBehavior:
                        FloatingLabelBehavior.auto, // Transisi otomatis
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey, width: 1.0), // Default border
                      borderRadius: BorderRadius.circular(8), // Sudut border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.blue, width: 2.0), // Border aktif
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey.shade600,
                          width: 1.0), // Border tidak aktif
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey.shade700, // Warna label default
                      fontSize: 16,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.blue, // Warna label saat melayang
                      fontSize: 14, // Ukuran label lebih kecil saat melayang
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15), // Padding teks
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              // Text(
              //   'Amount',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: 10),
              // Container(
              //   padding: EdgeInsets.only(left: 10),
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.black),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: TextField(
              //     controller: _amountController,
              //     keyboardType: TextInputType.number,
              //     decoration: InputDecoration(
              //       hintText: 'Enter your amount',
              //       border: InputBorder.none,
              //     ),
              //   ),
              // ),
              SizedBox(height: 20),
              Container(
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText:
                        'Description', // Label yang berfungsi sebagai placeholder
                    floatingLabelBehavior:
                        FloatingLabelBehavior.auto, // Transisi otomatis
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey, width: 1.0), // Default border
                      borderRadius: BorderRadius.circular(8), // Sudut border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.blue, width: 2.0), // Border aktif
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey.shade600,
                          width: 1.0), // Border tidak aktif
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelStyle: TextStyle(
                      color: Colors.grey.shade700, // Warna label default
                      fontSize: 16,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.blue, // Warna label saat melayang
                      fontSize: 14, // Ukuran label lebih kecil saat melayang
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15), // Padding teks
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              // Text(
              //   'Description',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: 10),
              // Container(
              //   padding: EdgeInsets.only(left: 10),
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.black),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: TextField(
              //     controller: _descriptionController,
              //     decoration: InputDecoration(
              //       hintText: 'Enter your description',
              //       border: InputBorder.none,
              //     ),
              //   ),
              // ),
              SizedBox(height: 20),
              Container(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade600, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                hintText: 'Select a date',
                                border: InputBorder.none,
                              ),
                              readOnly: true,
                              onTap: () =>
                                  _selectDate(context, _dateController),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey),
                            onPressed: () =>
                                _selectDate(context, _dateController),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 10, // Geser sedikit ke kiri
                      top: -6, // Atur posisi agar tidak terpotong
                      child: Container(
                        color: Colors
                            .white, // Background untuk teks agar tidak tertumpuk
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Select Date',
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
              // Text(
              //   'Date',
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: 10),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 10),
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.black),
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   child: TextField(
              //     controller: _dateController,
              //     decoration: InputDecoration(
              //       hintText: 'Select a date',
              //       border: InputBorder.none,
              //     ),
              //     readOnly: true,
              //     onTap: () => _selectDate(context),
              //   ),
              // ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 30),
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
