// ignore_for_file: non_constant_identifier_names, sized_box_for_whitespace, use_super_parameters, avoid_unnecessary_containers, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

Future EditTask(
  BuildContext context,
  String id,
  String selectedType,
  TextEditingController titleController,
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

  Future<void> selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat('dd-MM-yyyy').parse(controller.text);
      } catch (e) {
        // If the date format is invalid, use the current date
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
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

  Future<void> updateTask() async {
    try {
      // Mengambil nilai inputan dari form dan memproses sesuai tipe data yang benar
      String id = widget.id;
      String title = widget.titleController.text.trim();

      String description = widget.descriptionController.text.trim();
      DateTime dateLine =
          DateFormat('dd-MM-yyyy').parse(widget.dateLineController.text);

      // Membuat map data untuk Firestore dengan tipe data yang sesuai
      Map<String, dynamic> taskInfoMap = {
        'id': id,
        'type': selectedType,
        'title': title,
        // 'amount': amount,
        'description': description,
        'dateLine': Timestamp.fromDate(dateLine),
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Memperbarui data di Firestore
      await FirebaseFirestore.instance
          .collection('Task')
          .doc(widget.id)
          .update(taskInfoMap);

      Fluttertoast.showToast(
        msg: "Data berhasil disimpan!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14,
      );

      // Menutup dialog setelah update berhasil
      Navigator.pop(context);
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: 20),
                _buildDropdownType(),
                SizedBox(height: 20),
                _buildTextField(widget.titleController, 'Title'),
                SizedBox(height: 20),
                _buildTextField(widget.descriptionController, 'Description'),
                SizedBox(height: 20),
                _buildDatePicker(),
                SizedBox(height: 30),
                _buildUpdateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _buildHeader(BuildContext context) {
    return Row(
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
    );
  }

  Container _buildDropdownType() {
    return Container(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade600, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedType,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                dropdownColor: Colors.white,
                style: TextStyle(color: Colors.black, fontSize: 16),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue!;
                  });
                },
                items: <String>['Task', 'Completed']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: value == selectedType
                            ? Colors.green.shade100
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          color: value == selectedType
                              ? Colors.green
                              : Colors.black,
                          fontWeight: value == selectedType
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
    );
  }

  Container _buildTextField(TextEditingController controller, String label,
      {bool isAmount = false}) {
    return Container(
      child: TextField(
        controller: controller,
        keyboardType: isAmount ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
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
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Container _buildDatePicker() {
    return Container(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade600, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.dateLineController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Select Date',
                    ),
                    readOnly: true,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () =>
                      widget.selectDate(context, widget.dateLineController),
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            top: -6,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'Select Date Line',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Center(
        widthFactor: double.maxFinite,
        child: ElevatedButton(
          onPressed: updateTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: Size(double.infinity, 45),
          ),
          child: Text(
            'Update',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ));
  }
}
