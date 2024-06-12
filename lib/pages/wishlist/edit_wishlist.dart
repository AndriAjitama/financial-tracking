// ignore_for_file: non_constant_identifier_names, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:financial_tracking/service/database.dart';

Future EditWishlist(
  BuildContext context,
  String id,
  TextEditingController titleController,
  String selectedType,
  TextEditingController amountController,
  TextEditingController descriptionController,
  TextEditingController planningDateController,
  TextEditingController dateReachedController,
  Future<void> Function(BuildContext, TextEditingController) selectDate,
  void Function() formatAmount,
) =>
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                                "Edit Wishlist",
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
                                });
                              },
                              items: <String>[
                                'Belum Tercapai',
                                'Sudah Tercapai'
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
                              controller: titleController,
                              decoration: InputDecoration(
                                hintText: 'Enter title',
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
                              controller: planningDateController,
                              decoration: InputDecoration(
                                hintText: 'Select a date',
                                border: InputBorder.none,
                              ),
                              readOnly: true,
                              onTap: () =>
                                  selectDate(context, planningDateController),
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
                              controller: dateReachedController,
                              decoration: InputDecoration(
                                hintText: 'Select a date',
                                border: InputBorder.none,
                              ),
                              readOnly: true,
                              onTap: () =>
                                  selectDate(context, dateReachedController),
                            ),
                          ),
                          Center(
                            child: Container(
                                margin: EdgeInsets.only(top: 40),
                                padding: EdgeInsets.symmetric(vertical: 20),
                                width: double.maxFinite,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Map<String, dynamic> updateWishlistInfoMap =
                                        {
                                      "id": id,
                                      "type": selectedType,
                                      "title": titleController.text,
                                      "amount": amountController.text,
                                      "description": descriptionController.text,
                                      "planningDate":
                                          planningDateController.text,
                                      "dateReached": dateReachedController.text,
                                    };
                                    await DatabaseMethods()
                                        .updateWishlist(updateWishlistInfoMap,
                                            id, selectedType)
                                        .then((value) {
                                      Navigator.pop(context);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding:
                                          EdgeInsets.only(top: 12, bottom: 12)),
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
          });
        });
