// ignore_for_file: non_constant_identifier_names, sized_box_for_whitespace, use_super_parameters

import 'package:flutter/material.dart';
import 'package:financial_tracking/service/database.dart';

Future EditTask(
  BuildContext context,
  String id,
  String selectedType,
  TextEditingController
      titleController, // tambahkan TextEditingController untuk judul
  TextEditingController descriptionController,
  TextEditingController dateLineController,
  Future<void> Function(BuildContext, TextEditingController) selectDate,
) =>
    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: _EditTaskDialog(
                id: id,
                selectedType: selectedType,
                titleController: titleController,
                descriptionController: descriptionController,
                dateLineController: dateLineController,
                selectDate: selectDate,
              ),
            ));

class _EditTaskDialog extends StatefulWidget {
  final String id;
  final String selectedType;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController dateLineController;
  final Future<void> Function(BuildContext, TextEditingController) selectDate;

  const _EditTaskDialog({
    Key? key,
    required this.id,
    required this.selectedType,
    required this.titleController,
    required this.descriptionController,
    required this.dateLineController,
    required this.selectDate,
  }) : super(key: key);

  @override
  __EditTaskDialogState createState() => __EditTaskDialogState();
}

class __EditTaskDialogState extends State<_EditTaskDialog> {
  late String selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
          color: Color(0xFFF1F3F9),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                      Text(
                        "Edit Task",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 30),
                    ],
                  ),
                  SizedBox(height: 20),
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
                      value: selectedType,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedType = newValue!;
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
                    'Title', // Form title
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
                      controller: widget.titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter task title',
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
                      controller: widget.descriptionController,
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
                  SizedBox(height: 7),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: widget.dateLineController,
                      decoration: InputDecoration(
                        hintText: 'Select a date',
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                      onTap: () =>
                          widget.selectDate(context, widget.dateLineController),
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 40),
                      padding: EdgeInsets.symmetric(vertical: 20),
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: () async {
                          Map<String, dynamic> updateTaskInfoMap = {
                            "id": widget.id,
                            "type": selectedType,
                            "title": widget.titleController.text,
                            "description": widget.descriptionController.text,
                            "dateLine": widget.dateLineController.text,
                          };
                          await DatabaseMethods()
                              .updateTask(
                                  updateTaskInfoMap, widget.id, selectedType)
                              .then((value) {
                            Navigator.pop(context);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.only(top: 12, bottom: 12)),
                        child: Text(
                          "Update",
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
          )),
    );
  }
}
