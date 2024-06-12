// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, depend_on_referenced_packages, unnecessary_new, unnecessary_import, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_tracking/service/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddWishlist extends StatefulWidget {
  const AddWishlist({super.key});

  @override
  State<AddWishlist> createState() => _AddWishlistState();
}

class _AddWishlistState extends State<AddWishlist> {
  String _selectedType = 'Belum Tercapai';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _planningDateController = TextEditingController();
  final TextEditingController _dateReachedController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _planningDateController.dispose();
    _dateReachedController.dispose();
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
      backgroundColor: Color(0xFFF1F3F9),
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F3F9),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'My',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Wishlist',
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
          color: Color(0xFFF1F3F9),
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
              SizedBox(height: 7),
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
                    });
                  },
                  items: <String>['Belum Tercapai', 'Sudah Tercapai']
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
                'Title',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 7),
              Container(
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter the title',
                    border: InputBorder.none,
                  ),
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
              SizedBox(height: 7),
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
              SizedBox(height: 7),
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
                'Planning Date',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 7),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _planningDateController,
                  decoration: InputDecoration(
                    hintText: 'Select a planning date',
                    border: InputBorder.none,
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _planningDateController),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Date Reached',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 7),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _dateReachedController,
                  decoration: InputDecoration(
                    hintText: 'Select a date reached',
                    border: InputBorder.none,
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _dateReachedController),
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
                      Map<String, dynamic> wishlistInfoMap = {
                        'id': id,
                        'type': _selectedType,
                        'title': _titleController.text,
                        'amount': _amountController.text,
                        'description': _descriptionController.text,
                        'planningDate': _planningDateController.text,
                        'dateReached': _dateReachedController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      };
                      try {
                        await DatabaseMethods()
                            .addWishlist(wishlistInfoMap, id);
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
