// ignore_for_file: avoid_print, await_only_futures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatabaseMethods {
  //////////////////////////////////////////////// FINANCIAL ////////////////////////////////////////////

  Future<void> addFinancialDetails(
      Map<String, dynamic> financialInfoMap, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection("FinancialTracking")
          .doc(id)
          .set(financialInfoMap);
    } catch (e) {
      print('Error adding financial details: $e');
    }
  }

  Future<Stream<QuerySnapshot>> getFinancialDetails() async {
    try {
      return await FirebaseFirestore.instance
          .collection("FinancialTracking")
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting financial details: $e');
    }

    throw Exception('Failed to get financial details.'); // Add this line
  }

  Future updateFinancialDetails(Map<String, dynamic> updateFinancialInfoMap,
      String id, String selectedCategory) async {
    try {
      await FirebaseFirestore.instance
          .collection("FinancialTracking")
          .doc(id)
          .update(updateFinancialInfoMap);
    } catch (e) {
      print('Error updating financial details: $e');
    }
  }

  Future deleteFinancialDetails(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection("FinancialTracking")
          .doc(id)
          .delete();
    } catch (e) {
      print('Error deleting financial details: $e');
    }
  }

  //////////////////////////////////////////////// WISHLIST ////////////////////////////////////////////

  Future<void> addWishlist(
      Map<String, dynamic> wishlistInfoMap, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection("Wishlist")
          .doc(id)
          .set(wishlistInfoMap);
    } catch (e) {
      print('Error adding wishlist details: $e');
    }
  }

  Future<Stream<QuerySnapshot>> getWishlist() async {
    try {
      return await FirebaseFirestore.instance
          .collection("Wishlist")
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting wishlist details: $e');
    }

    throw Exception('Failed to get wishlist details.'); // Add this line
  }

  Future updateWishlist(Map<String, dynamic> updateWishlistInfoMap, String id,
      String selectedCategory) async {
    try {
      await FirebaseFirestore.instance
          .collection("Wishlist")
          .doc(id)
          .update(updateWishlistInfoMap);
    } catch (e) {
      print('Error updating wishlist details: $e');
    }
  }

  Future deleteWishlist(String id) async {
    try {
      await FirebaseFirestore.instance.collection("Wishlist").doc(id).delete();
    } catch (e) {
      print('Error deleting wishlist details: $e');
    }
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

  //////////////////////////////////////////// TASK ////////////////////////////////////////////
  Future<void> addTask(Map<String, dynamic> taskInfoMap, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection("Task")
          .doc(id)
          .set(taskInfoMap);
    } catch (e) {
      print('Error adding task details: $e');
    }
  }

  Future<Stream<QuerySnapshot>> getTask() async {
    try {
      return await FirebaseFirestore.instance
          .collection("Task")
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      print('Error getting task details: $e');
    }

    throw Exception('Failed to get task details.'); // Add this line
  }

  Future updateTask(Map<String, dynamic> updateTaskInfoMap, String id,
      String selectedCategory) async {
    try {
      await FirebaseFirestore.instance
          .collection("Task")
          .doc(id)
          .update(updateTaskInfoMap);
    } catch (e) {
      print('Error updating task details: $e');
    }
  }

  Future deleteTask(String id) async {
    try {
      await FirebaseFirestore.instance.collection("Task").doc(id).delete();
    } catch (e) {
      print('Error deleting task details: $e');
    }
  }
}
