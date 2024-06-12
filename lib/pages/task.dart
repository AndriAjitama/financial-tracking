// ignore_for_file: prefer_const_literals_to_create_immutables, empty_constructor_bodies, use_super_parameters

import 'package:financial_tracking/pages/task/list_task.dart';
import 'package:flutter/material.dart';

class Tasks extends StatelessWidget {
  const Tasks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F3F9),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'My',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tasks',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: TaskTab(),
      ),
    );
  }
}
