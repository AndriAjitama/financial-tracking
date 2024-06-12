// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, depend_on_referenced_packages, unnecessary_new, unnecessary_import, sort_child_properties_last

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
  String _selectedType = 'Tugas';
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
              'Task',
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
                    });
                  },
                  items: <String>['Tugas', 'Selesai']
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
              SizedBox(height: 10),
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
                'Date Line',
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
                  controller: _dateLineController,
                  decoration: InputDecoration(
                    hintText: 'Select a date line',
                    border: InputBorder.none,
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _dateLineController),
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
                        'description': _descriptionController.text,
                        'dateLine': _dateLineController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      };
                      try {
                        await DatabaseMethods().addTask(wishlistInfoMap, id);
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
