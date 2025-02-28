// ignore_for_file: non_constant_identifier_names, sized_box_for_whitespace, use_super_parameters, avoid_unnecessary_containers, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

Future EditWishlist(
  BuildContext context,
  String id,
  String selectedType,
  TextEditingController titleController,
  TextEditingController amountController,
  TextEditingController descriptionController,
  TextEditingController planningDateController,
  TextEditingController dateReachedController,
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
              child: _EditWishlistDialog(
                id: id,
                selectedType: selectedType,
                titleController: titleController,
                amountController: amountController,
                descriptionController: descriptionController,
                planningDateController: planningDateController,
                dateReachedController: dateReachedController,
                selectDate: selectDate,
              ),
            ));

class _EditWishlistDialog extends StatefulWidget {
  final String id;
  final String selectedType;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final TextEditingController planningDateController;
  final TextEditingController dateReachedController;
  final Future<void> Function(BuildContext, TextEditingController) selectDate;

  const _EditWishlistDialog({
    Key? key,
    required this.id,
    required this.selectedType,
    required this.titleController,
    required this.amountController,
    required this.descriptionController,
    required this.planningDateController,
    required this.dateReachedController,
    required this.selectDate,
  }) : super(key: key);

  @override
  __EditWishlistDialogState createState() => __EditWishlistDialogState();
}

class __EditWishlistDialogState extends State<_EditWishlistDialog> {
  late String selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.selectedType;

    widget.amountController.addListener(_onAmountChange);
  }

  void _onAmountChange() {
    String currentText = widget.amountController.text;

    if (currentText.isNotEmpty) {
      String digitsOnly = currentText.replaceAll(RegExp(r'\D'), '');
      double? number = double.tryParse(digitsOnly);

      if (number != null) {
        String formatted = NumberFormat.currency(
          locale: 'id_ID',
          symbol: '',
          decimalDigits: 0,
        ).format(number);

        widget.amountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
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

  Future<void> updateWishlist() async {
    try {
      // Mengambil nilai inputan dari form dan memproses sesuai tipe data yang benar
      String id = widget.id;
      String title = widget.titleController.text.trim();
      int amount =
          int.parse(widget.amountController.text.replaceAll(RegExp(r'\D'), ''));
      String description = widget.descriptionController.text.trim();
      DateTime planningDate =
          DateFormat('dd-MM-yyyy').parse(widget.planningDateController.text);

      Timestamp? dateReached;
      if (selectedType == 'Already Achieved' &&
          widget.dateReachedController.text.isNotEmpty) {
        dateReached = Timestamp.fromDate(
            DateFormat('dd-MM-yyyy').parse(widget.dateReachedController.text));
      } else {
        dateReached = null;
      }

      // Membuat map data untuk Firestore dengan tipe data yang sesuai
      Map<String, dynamic> wishlistInfoMap = {
        'id': id,
        'type': selectedType,
        'title': title,
        'amount': amount,
        'description': description,
        'planningDate': Timestamp.fromDate(planningDate),
        'dateReached': dateReached,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (dateReached != null) {
        wishlistInfoMap['dateReached'] = dateReached;
      }
      // Memperbarui data di Firestore
      await FirebaseFirestore.instance
          .collection('Wishlist')
          .doc(widget.id)
          .update(wishlistInfoMap);

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
                _buildTextField(widget.amountController, 'Amount',
                    isAmount: true),
                SizedBox(height: 20),
                _buildTextField(widget.descriptionController, 'Description'),
                SizedBox(height: 20),
                _buildDatePickerPlanning(),
                SizedBox(height: 20),
                _buildDatePickerReached(),
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
          "Edit Wishlist",
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
                items: <String>[
                  'Not Yet Achieved',
                  'Already Achieved',
                ].map<DropdownMenuItem<String>>((String value) {
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

  Container _buildDatePickerPlanning() {
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
                    controller: widget.planningDateController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Select Planning Date',
                    ),
                    readOnly: true,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () =>
                      widget.selectDate(context, widget.planningDateController),
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
                'Select Planning Date',
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

  Container _buildDatePickerReached() {
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
                    controller: widget.dateReachedController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Select Date Reached',
                    ),
                    readOnly: true,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () =>
                      widget.selectDate(context, widget.dateReachedController),
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
                'Select Date Reached',
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
          onPressed: updateWishlist,
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
