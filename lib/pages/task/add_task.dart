// ignore_for_file: prefer_const_literals_to_create_immutables, unused_element, avoid_unnecessary_containers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_tracking/service/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  String _selectedType = 'Task';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateLineController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateLineController.dispose();
    super.dispose();
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
              onPressed: () => _selectDate(context, _dateLineController),
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
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _dateLineController.text.isEmpty) {
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

      DateTime dateLine =
          DateFormat('dd-MM-yyyy').parse(_dateLineController.text);

      Map<String, dynamic> taskInfoMap = {
        'id': id,
        'type': _selectedType,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'dateLine': Timestamp.fromDate(dateLine),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await DatabaseMethods().addTask(taskInfoMap, id);

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
        _selectedType = 'Task';
        _titleController.clear();

        _descriptionController.clear();
        _dateLineController.clear();
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
            Text('Task',
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
                                  });
                                },
                                items: <String>[
                                  'Task',
                                  'Completed'
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
              TextField(
                  controller: _titleController,
                  decoration: _inputDecoration('Title')),
              SizedBox(height: 20),

              TextField(
                  controller: _descriptionController,
                  decoration: _inputDecoration('Description')),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context, _dateLineController),
                child: AbsorbPointer(
                  child: TextField(
                      controller: _dateLineController,
                      decoration:
                          _inputDecoration('Select Date Line', context)),
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
