// ignore_for_file: non_constant_identifier_names, sized_box_for_whitespace, use_super_parameters, avoid_unnecessary_containers, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

Future EditTransaction(
  BuildContext context,
  String id,
  String selectedType,
  String selectedCategory,
  TextEditingController amountController,
  TextEditingController descriptionController,
  TextEditingController dateController,
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
              child: _EditTransactionDialog(
                id: id,
                selectedType: selectedType,
                selectedCategory: selectedCategory,
                amountController: amountController,
                descriptionController: descriptionController,
                dateController: dateController,
                selectDate: selectDate,
              ),
            ));

class _EditTransactionDialog extends StatefulWidget {
  final String id;
  final String selectedType;
  final String selectedCategory;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final TextEditingController dateController;
  final Future<void> Function(BuildContext, TextEditingController) selectDate;

  const _EditTransactionDialog({
    Key? key,
    required this.id,
    required this.selectedType,
    required this.selectedCategory,
    required this.amountController,
    required this.descriptionController,
    required this.dateController,
    required this.selectDate,
  }) : super(key: key);

  @override
  __EditTransactionDialogState createState() => __EditTransactionDialogState();
}

class __EditTransactionDialogState extends State<_EditTransactionDialog> {
  late String selectedType;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedType = widget.selectedType;
    selectedCategory = widget.selectedCategory;

    if (!categories[selectedType]!.contains(selectedCategory)) {
      selectedCategory = categories[selectedType]!.isNotEmpty
          ? categories[selectedType]!.first
          : '';
    }
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

  Future<void> updateTransaction() async {
    try {
      // Mengambil nilai inputan dari form dan memproses sesuai tipe data yang benar
      String id = widget.id;
      int amount =
          int.parse(widget.amountController.text.replaceAll(RegExp(r'\D'), ''));
      String description = widget.descriptionController.text.trim();
      DateTime date =
          DateFormat('dd-MM-yyyy').parse(widget.dateController.text);

      // Membuat map data untuk Firestore dengan tipe data yang sesuai
      Map<String, dynamic> transactionInfoMap = {
        'id': id,
        'type': selectedType,
        'category': selectedCategory,
        'amount': amount,
        'description': description,
        'date': Timestamp.fromDate(date),
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Memperbarui data di Firestore
      await FirebaseFirestore.instance
          .collection('Transaction')
          .doc(widget.id)
          .update(transactionInfoMap);

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

  final Map<String, List<String>> categories = {
    'Income': [
      'Salary',
      'Gift',
      'Asset Sales',
      'Business',
      'Freelance',
      'Other'
    ],
    'Expense': [
      'Cigarette',
      'Fuel',
      'Food',
      'Drink',
      'Bill',
      'Investment',
      'Installment',
      'Housing',
      'Personal Needs',
      'Transportation',
      'Communication',
      'Education',
      'Health & Insurance',
      'Entertainment',
      'Donation',
      'Other'
    ],
  };

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
                _buildDropdownCategory(),
                SizedBox(height: 20),
                _buildTextField(widget.amountController, 'Amount',
                    isAmount: true),
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
          "Edit Transaction",
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
                    // Update category to the first available category for new type
                    selectedCategory = categories[selectedType]!.first;
                  });
                },
                items: <String>[
                  'Income',
                  'Expense',
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

  Container _buildDropdownCategory() {
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
                menuMaxHeight: 350,
                borderRadius: BorderRadius.circular(10),
                isExpanded: true,
                value: selectedCategory,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                dropdownColor: Colors.white,
                style: TextStyle(color: Colors.black, fontSize: 16),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                items: categories[selectedType]!
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: value == selectedCategory
                            ? Colors.green.shade100
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          color: value == selectedCategory
                              ? Colors.green
                              : Colors.black,
                          fontWeight: value == selectedCategory
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
                    controller: widget.dateController,
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
                      widget.selectDate(context, widget.dateController),
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
    );
  }

  Widget _buildUpdateButton() {
    return Center(
        widthFactor: double.maxFinite,
        child: ElevatedButton(
          onPressed: updateTransaction,
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
