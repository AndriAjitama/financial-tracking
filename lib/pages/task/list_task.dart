// ignore_for_file: unnecessary_const, use_super_parameters, prefer_const_literals_to_create_immutables, sort_child_properties_last, library_private_types_in_public_api, unnecessary_string_interpolations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_tracking/pages/task/add_task.dart';
import 'package:financial_tracking/pages/task/edit_task.dart';
import 'package:financial_tracking/service/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskTab extends StatelessWidget {
  const TaskTab({Key? key}) : super(key: key);

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
                    Tab(text: 'Task'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: const TabBarView(
            children: [
              TaskList(type: null),
              TaskList(type: 'Task'),
              TaskList(type: 'Completed'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTask()),
            );
          },
          heroTag: 'addTask',
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}

class TaskList extends StatefulWidget {
  final String? type;

  const TaskList({Key? key, this.type}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  late Stream<QuerySnapshot<Object?>> taskStream;

  @override
  void initState() {
    super.initState();
    taskStream = widget.type == null
        ? FirebaseFirestore.instance.collection('Task').snapshots()
        : FirebaseFirestore.instance
            .collection('Task')
            .where('type', isEqualTo: widget.type)
            .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Object?>>(
      stream: taskStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final task = snapshot.data!.docs;
        if (task.isEmpty) {
          return const Center(
            child: Text(
              'No items found',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          );
        }

        task.sort((a, b) {
          DateTime dateA = (a['dateLine'] as Timestamp).toDate();
          DateTime dateB = (b['dateLine'] as Timestamp).toDate();
          return dateA.compareTo(dateB);
        });

        return ListView.builder(
          itemCount: task.length,
          itemBuilder: (context, index) {
            final ds = task[index];
            return TaskListItem(
              taskData: ds,
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
    TextEditingController descriptionController =
        TextEditingController(text: ds['description']);
    TextEditingController dateLineController = TextEditingController(
        text: DateFormat('dd-MM-yyyy')
            .format((ds['dateLine'] as Timestamp).toDate()));

    EditTask(
      context,
      ds.id,
      ds['type'],
      titleController,
      descriptionController,
      dateLineController,
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
              DatabaseMethods().deleteTask(ds.id);
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

class TaskListItem extends StatelessWidget {
  final DocumentSnapshot taskData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskListItem({
    Key? key,
    required this.taskData,
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
                height: 140,
                color: _getTypeColor(taskData['type']),
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
                          taskData['title'],
                          style: const TextStyle(
                              fontSize: 25,
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
                    const SizedBox(height: 0),
                    Text(
                      'Date Line: ${DateFormat('dd-MM-yyyy').format((taskData['dateLine'] as Timestamp).toDate())}',
                      style: const TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                    const SizedBox(height: 0),
                    Text('Desc: ${taskData['description']}',
                        style: const TextStyle(fontSize: 15)),
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
      case 'Completed':
        return Colors.green;
      case 'Task':
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
