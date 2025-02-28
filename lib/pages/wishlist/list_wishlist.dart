// ignore_for_file: unnecessary_const, use_super_parameters, prefer_const_literals_to_create_immutables, sort_child_properties_last, library_private_types_in_public_api, unnecessary_string_interpolations, unused_local_variable

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
          backgroundColor: Colors.white,
          toolbarHeight: 50,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green.shade100,
                border: Border.all(color: Colors.green),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicator: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: TextStyle(fontSize: 12),
                  tabs: [
                    Tab(text: 'All'),
                    Tab(text: 'Not Yet Achieved'),
                    Tab(text: 'Already Achieved'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            const TotalAmountSummary(),
            Expanded(
              child: TabBarView(
                children: const [
                  ListWishlist(type: null),
                  ListWishlist(type: 'Not Yet Achieved'),
                  ListWishlist(type: 'Already Achieved'),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddWishlist()),
            );
          },
          heroTag: 'addWishlist',
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}

class TotalAmountSummary extends StatelessWidget {
  const TotalAmountSummary({Key? key}) : super(key: key);

  Stream<Map<String, double>> _calculateTotalPerType() {
    return FirebaseFirestore.instance
        .collection('Wishlist')
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs;

      Map<String, double> totalPerType = {
        'All': 0,
        'Not Yet Achieved': 0,
        'Already Achieved': 0,
        'Target': 0,
      };

      for (var doc in docs) {
        final type = doc['type'] ?? 'All';
        final amount = (doc['amount'] as num).toDouble();
        totalPerType['All'] = totalPerType['All']! + amount;
        if (totalPerType.containsKey(type)) {
          totalPerType[type] = totalPerType[type]! + amount;
        }
      }

      // Hitung Target
      totalPerType['Target'] =
          totalPerType['Already Achieved']! - totalPerType['Not Yet Achieved']!;

      return totalPerType;
    });
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: StreamBuilder<Map<String, double>>(
        stream: _calculateTotalPerType(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final totals = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    currencyFormat.format(totals['All']),
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(
                    currencyFormat.format(totals['Not Yet Achieved']),
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text(
                    currencyFormat.format(totals['Already Achieved']),
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Target: ${currencyFormat.format(totals['Target'])}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}

class ListWishlist extends StatefulWidget {
  final String? type;

  const ListWishlist({Key? key, this.type}) : super(key: key);

  @override
  _WishlistListState createState() => _WishlistListState();
}

class _WishlistListState extends State<ListWishlist> {
  late Stream<QuerySnapshot<Object?>> wishlistStream;

  // var ds;

  @override
  void initState() {
    super.initState();
    wishlistStream = widget.type == null
        ? FirebaseFirestore.instance.collection('Wishlist').snapshots()
        : FirebaseFirestore.instance
            .collection('Wishlist')
            .where('type', isEqualTo: widget.type)
            .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Object?>>(
      stream: wishlistStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final wishlist = snapshot.data!.docs;
        if (wishlist.isEmpty) {
          return const Center(
            child: Text(
              'No items found',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          );
        }

        wishlist.sort((a, b) {
          DateTime dateA = (a['planningDate'] as Timestamp).toDate();
          DateTime dateB = (b['planningDate'] as Timestamp).toDate();
          return dateA.compareTo(dateB);
        });

        return ListView.builder(
          itemCount: wishlist.length,
          itemBuilder: (context, index) {
            final ds = wishlist[index];
            return WishlistItem(
              wishlistData: ds,
              onEdit: () => _onEdit(context, ds),
              onDelete: () => _onDelete(context, ds),
            );
          },
        );
      },
    );
  }

  void _onEdit(BuildContext context, DocumentSnapshot ds) {
    TextEditingController titleController =
        TextEditingController(text: ds['title']);
    TextEditingController amountController =
        TextEditingController(text: ds["amount"].toString());
    TextEditingController descriptionController =
        TextEditingController(text: ds['description']);
    TextEditingController planningDateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy')
            .format((ds['planningDate'] as Timestamp).toDate()));
    TextEditingController dateReachedController = TextEditingController(
        text: ds['dateReached'] != null
            ? DateFormat('dd-MM-yyyy')
                .format((ds['dateReached'] as Timestamp).toDate())
            : 'Select Date Reached');

    EditWishlist(
      context,
      ds.id,
      ds['type'],
      titleController,
      amountController,
      descriptionController,
      planningDateController,
      dateReachedController,
      selectDate,
    );
  }

  void _onDelete(BuildContext context, DocumentSnapshot ds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Delete Confirmation",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),
        ),
        content: const Text(
          "Apakah Anda yakin akan menghapus data ini?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue,
              ),
              child: const Text("Cancel",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              DatabaseMethods().deleteWishlist(ds.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.red,
              ),
              child: const Text("Delete",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class WishlistItem extends StatelessWidget {
  final DocumentSnapshot wishlistData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WishlistItem({
    Key? key,
    required this.wishlistData,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Container(
                width: 15,
                height: 150,
                color: _getTypeColor(wishlistData['type']),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          wishlistData['title'],
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: onEdit,
                              child: const Icon(Icons.edit,
                                  color: Colors.orange, size: 23),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: onDelete,
                              child: const Icon(Icons.delete,
                                  color: Colors.red, size: 23),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(wishlistData['type'],
                            style: const TextStyle(fontSize: 15)),
                        Text(
                          'Rp ${NumberFormat.decimalPattern('id').format(wishlistData['amount'])}',
                          style: TextStyle(
                              fontSize: 20,
                              color: wishlistData['type'] == 'Already Achieved'
                                  ? Colors.green
                                  : Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PD: ${wishlistData['planningDate'] != null ? DateFormat('dd-MM-yyyy').format((wishlistData['planningDate'] as Timestamp).toDate()) : ''}',
                          style:
                              const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'DR: ${wishlistData['dateReached'] != null ? DateFormat('dd-MM-yyyy').format((wishlistData['dateReached'] as Timestamp).toDate()) : ''}',
                          style:
                              const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                    Text(wishlistData['description'],
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Already Achieved':
        return Colors.green;
      case 'Not Yet Achieved':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

Future<void> selectDate(
    BuildContext context, TextEditingController controller) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: Colors.blue),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue)),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    controller.text = DateFormat('dd-MM-yyyy').format(picked);
  }
}
