// ignore_for_file: use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, use_super_parameters, await_only_futures, avoid_function_literals_in_foreach_calls, sort_child_properties_last, unnecessary_const

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_tracking/pages/wishlist/add_wishlist.dart';
import 'package:financial_tracking/pages/wishlist/edit_wishlist.dart';
import 'package:financial_tracking/service/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WishlistTab extends StatelessWidget {
  const WishlistTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF1F3F9),
          title: const Text(
            'Wishlists',
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green.shade100,
                border: Border.all(
                  color: Colors.green,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicator: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: TextStyle(
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Belum Terc..'),
                    Tab(text: 'Sudah Terc..'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Container(
          color: const Color(0xFFF1F3F9),
          child: const TabBarView(
            children: [
              WishlistList(type: null),
              WishlistList(type: 'Belum Tercapai'),
              WishlistList(type: 'Sudah Tercapai'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddWishlist()),
            );
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}

class WishlistList extends StatefulWidget {
  final String? type;

  const WishlistList({Key? key, this.type}) : super(key: key);

  @override
  State<WishlistList> createState() => _WishlistListState();
}

class _WishlistListState extends State<WishlistList> {
  Stream<QuerySnapshot>? wishlistStream;

  @override
  void initState() {
    super.initState();
    getWishlistData();
  }

  getWishlistData() async {
    if (widget.type == null) {
      wishlistStream = await DatabaseMethods().getWishlist();
    } else {
      wishlistStream = FirebaseFirestore.instance
          .collection('Wishlist')
          .where('type', isEqualTo: widget.type)
          .snapshots();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: wishlistStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No items found',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];

            String title = ds['title'].length > 20
                ? ds['title'].substring(0, 20) + '...'
                : ds['title'] ?? '-';
            String type = ds['type'] ?? '-';
            String amount = ds['amount'] ?? '-';
            String planningDate = ds['planningDate'] ?? '-';
            String dateReached = ds['dateReached'] ?? '-';
            String description = ds['description'] ?? '-';

            Color amountColor =
                (ds['type'] == 'Sudah Tercapai') ? Colors.green : Colors.black;

            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      child: Container(
                        width: 15,
                        height: 155,
                        color: ds['type'] == 'Sudah Tercapai'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 0, top: 10, bottom: 10, right: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    TextEditingController
                                                        titleController =
                                                        TextEditingController(
                                                            text: ds['title']);
                                                    TextEditingController
                                                        amountController =
                                                        TextEditingController(
                                                            text: ds['amount']);
                                                    TextEditingController
                                                        descriptionController =
                                                        TextEditingController(
                                                            text: ds[
                                                                'description']);
                                                    TextEditingController
                                                        planningDateController =
                                                        TextEditingController(
                                                            text: ds[
                                                                'planningDate']);
                                                    TextEditingController
                                                        dateReachedController =
                                                        TextEditingController(
                                                            text: ds[
                                                                'dateReached']);

                                                    EditWishlist(
                                                      context,
                                                      ds.id,
                                                      titleController,
                                                      ds['type'],
                                                      amountController,
                                                      descriptionController,
                                                      planningDateController,
                                                      dateReachedController,
                                                      selectDate,
                                                      () {},
                                                    );
                                                  },
                                                  child: const Icon(
                                                    Icons.edit,
                                                    color: Colors.orange,
                                                    size: 23,
                                                  ),
                                                ),
                                                const SizedBox(width: 7),
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                            "Delete Confirmation",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          content: const Text(
                                                            "Apakah Anda yakin akan menghapus data ini?",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  color: Colors
                                                                      .blue,
                                                                ),
                                                                child:
                                                                    const Text(
                                                                  "Cancel",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                DatabaseMethods()
                                                                    .deleteWishlist(
                                                                        ds.id);
                                                              },
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                child:
                                                                    const Text(
                                                                  "Delete",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                    size: 23,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              type,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              'Rp.$amount',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: amountColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'PD: $planningDate',
                                              style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              'DR: $dateReached',
                                              style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Des: $description',
                                          style: const TextStyle(
                                              fontSize: 15, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }
}
