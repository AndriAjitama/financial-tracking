// ignore_for_file: non_constant_identifier_names, sized_box_for_whitespace, avoid_unnecessary_containers

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
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(15),
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
                            Container(
                              child: Stack(
                                clipBehavior:
                                    Clip.none, // Menghindari elemen terpotong
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.grey.shade600,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: selectedType,
                                        icon: Icon(Icons.arrow_drop_down),
                                        iconSize: 24,
                                        dropdownColor: Colors.white,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedType = newValue!;
                                            selectedCategory =
                                                categories[selectedType]![0];
                                          });
                                        },
                                        items: <String>['Income', 'Expense']
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          final isSelected =
                                              value == selectedType;
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.green.shade100
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6),
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
                            // Text(
                            //   'Type',
                            //   style: TextStyle(
                            //     color: Colors.black,
                            //     fontSize: 20,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // SizedBox(height: 7),
                            // Container(
                            //   padding: EdgeInsets.symmetric(horizontal: 10),
                            //   decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.black),
                            //     borderRadius: BorderRadius.circular(10),
                            //   ),
                            //   child: DropdownButton<String>(
                            //     isExpanded: true,
                            //     value: selectedType,
                            //     onChanged: (String? newValue) {
                            //       setState(() {
                            //         selectedType = newValue!;
                            //         selectedCategory =
                            //             categories[selectedType]![0];
                            //       });
                            //     },
                            //     items: <String>[
                            //       'Income',
                            //       'Expense'
                            //     ].map<DropdownMenuItem<String>>((String value) {
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
                                clipBehavior:
                                    Clip.none, // Menghindari elemen terpotong
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.grey.shade600,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: selectedCategory,
                                        icon: Icon(Icons.arrow_drop_down),
                                        iconSize: 24,
                                        dropdownColor: Colors.white,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedCategory = newValue!;
                                          });
                                        },
                                        items: categories[selectedType]!
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          final isSelected =
                                              value == selectedCategory;
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.green.shade100
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6),
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
                            // Text(
                            //   'Category',
                            //   style: TextStyle(
                            //     color: Colors.black,
                            //     fontSize: 20,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // SizedBox(height: 7),
                            // Container(
                            //   padding: EdgeInsets.symmetric(horizontal: 10),
                            //   decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.black),
                            //     borderRadius: BorderRadius.circular(10),
                            //   ),
                            //   child: DropdownButton<String>(
                            //     isExpanded: true,
                            //     value: selectedCategory,
                            //     onChanged: (String? newValue) {
                            //       setState(() {
                            //         selectedCategory = newValue!;
                            //       });
                            //     },
                            //     items: categories[selectedType]!
                            //         .map<DropdownMenuItem<String>>(
                            //             (String value) {
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
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText:
                                      'Amount', // Label yang berfungsi sebagai placeholder
                                  floatingLabelBehavior: FloatingLabelBehavior
                                      .auto, // Transisi otomatis
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0), // Default border
                                    borderRadius: BorderRadius.circular(
                                        8), // Sudut border
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 2.0), // Border aktif
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade600,
                                        width: 1.0), // Border tidak aktif
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors
                                        .grey.shade700, // Warna label default
                                    fontSize: 16,
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: Colors
                                        .blue, // Warna label saat melayang
                                    fontSize:
                                        14, // Ukuran label lebih kecil saat melayang
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 15), // Padding teks
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
                            // SizedBox(height: 7),
                            // Container(
                            //   padding: EdgeInsets.only(left: 10),
                            //   decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.black),
                            //     borderRadius: BorderRadius.circular(10),
                            //   ),
                            //   child: TextField(
                            //     controller: amountController,
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
                                controller: descriptionController,
                                decoration: InputDecoration(
                                  labelText:
                                      'Description', // Label yang berfungsi sebagai placeholder
                                  floatingLabelBehavior: FloatingLabelBehavior
                                      .auto, // Transisi otomatis
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0), // Default border
                                    borderRadius: BorderRadius.circular(
                                        8), // Sudut border
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blue,
                                        width: 2.0), // Border aktif
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade600,
                                        width: 1.0), // Border tidak aktif
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors
                                        .grey.shade700, // Warna label default
                                    fontSize: 16,
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: Colors
                                        .blue, // Warna label saat melayang
                                    fontSize:
                                        14, // Ukuran label lebih kecil saat melayang
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 15), // Padding teks
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
                            // SizedBox(height: 7),
                            // Container(
                            //   padding: EdgeInsets.only(left: 10),
                            //   decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.black),
                            //     borderRadius: BorderRadius.circular(10),
                            //   ),
                            //   child: TextField(
                            //     controller: descriptionController,
                            //     decoration: InputDecoration(
                            //       hintText: 'Enter your description',
                            //       border: InputBorder.none,
                            //     ),
                            //   ),
                            // ),
                            SizedBox(height: 20),
                            //           Container(
                            //   child: Stack(
                            //     clipBehavior: Clip.none,
                            //     children: [
                            //       Container(
                            //         padding: EdgeInsets.symmetric(horizontal: 10),
                            //         decoration: BoxDecoration(
                            //           border: Border.all(
                            //               color: Colors.grey.shade600, width: 1),
                            //           borderRadius: BorderRadius.circular(8),
                            //         ),
                            //         child: Row(
                            //           children: [
                            //             Expanded(
                            //               child: TextField(
                            //                 controller: dateController,
                            //                 decoration: InputDecoration(
                            //                   hintText: 'Select a date',
                            //                   border: InputBorder.none,
                            //                 ),
                            //                 readOnly: true,
                            //                 onTap: () => selectDate(
                            //                     context, dateController),
                            //               ),
                            //             ),
                            //             IconButton(
                            //               icon: Icon(Icons.calendar_today,
                            //                   size: 18, color: Colors.grey),
                            //               onPressed: () => selectDate(
                            //                   context, dateController),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //       Positioned(
                            //         left: 10, // Geser sedikit ke kiri
                            //         top: -6, // Atur posisi agar tidak terpotong
                            //         child: Container(
                            //           color: Colors
                            //               .white, // Background untuk teks agar tidak tertumpuk
                            //           padding: EdgeInsets.symmetric(horizontal: 4),
                            //           child: Text(
                            //             'Select Date',
                            //             style: TextStyle(
                            //               color: Colors.blue,
                            //               fontSize: 10,
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // Text(
                            //   'Date',
                            //   style: TextStyle(
                            //     color: Colors.black,
                            //     fontSize: 20,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // SizedBox(height: 7),
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
