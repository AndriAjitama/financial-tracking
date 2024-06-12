// ignore_for_file: non_constant_identifier_names, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:financial_tracking/service/database.dart';

Future EditFinancialTracking(
  BuildContext context,
  String id,
  String selectedType,
  String selectedCategory,
  Map<String, List<String>> categories,
  TextEditingController amountController,
  TextEditingController descriptionController,
  TextEditingController dateController,
  Future<void> Function(BuildContext) selectDate,
  void Function() formatAmount,
) =>
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.transparent,
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: ClipRRect(
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
                                  "Financial Tracking",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 30),
                              ],
                            ),
                            SizedBox(height: 30),
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
                                    selectedCategory =
                                        categories[selectedType]![0];
                                  });
                                },
                                items: <String>[
                                  'Income',
                                  'Expense'
                                ].map<DropdownMenuItem<String>>((String value) {
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
                            SizedBox(height: 7),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedCategory,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCategory = newValue!;
                                  });
                                },
                                items: categories[selectedType]!
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
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
                            SizedBox(height: 7),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: amountController,
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
                                controller: descriptionController,
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
                            SizedBox(height: 7),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: dateController,
                                decoration: InputDecoration(
                                  hintText: 'Select a date',
                                  border: InputBorder.none,
                                ),
                                readOnly: true,
                                onTap: () => selectDate(context),
                              ),
                            ),
                            Center(
                              child: Container(
                                  margin: EdgeInsets.only(top: 40),
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  width: double.maxFinite,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Map<String, dynamic>
                                          updateFinancialInfoMap = {
                                        "id": id,
                                        "type": selectedType,
                                        "category": selectedCategory,
                                        "amount": amountController.text,
                                        "description":
                                            descriptionController.text,
                                        "date": dateController.text,
                                      };
                                      await DatabaseMethods()
                                          .updateFinancialDetails(
                                              updateFinancialInfoMap,
                                              id,
                                              selectedCategory)
                                          .then((value) {
                                        Navigator.pop(context);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: EdgeInsets.only(
                                            top: 12, bottom: 12)),
                                    child: Text(
                                      "Update",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
