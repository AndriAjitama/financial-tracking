// ignore_for_file: use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, use_super_parameters, await_only_futures, avoid_function_literals_in_foreach_calls, sort_child_properties_last

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
          backgroundColor: const Color(0xFFF1F3F9),
          title: const Text(
            'Tasks',
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
                    Tab(text: 'Tugas'),
                    Tab(text: 'Selesai'),
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
              TaskList(type: null),
              TaskList(type: 'Tugas'),
              TaskList(type: 'Selesai'),
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
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  Stream<QuerySnapshot>? taskStream;

  @override
  void initState() {
    super.initState();
    getTaskData();
  }

  getTaskData() async {
    if (widget.type == null) {
      taskStream = await DatabaseMethods().getTask();
    } else {
      taskStream = FirebaseFirestore.instance
          .collection('Task')
          .where('type', isEqualTo: widget.type)
          .snapshots();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: taskStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No items found',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          );
        }

        List<DocumentSnapshot> tasks = snapshot.data!.docs;

        // Sort tasks by date closest to today
        tasks.sort((a, b) {
          DateTime dateA = DateFormat('dd-MM-yyyy').parse(a['dateLine']);
          DateTime dateB = DateFormat('dd-MM-yyyy').parse(b['dateLine']);
          DateTime now = DateTime.now();
          return (dateA.difference(now).inDays)
              .abs()
              .compareTo((dateB.difference(now).inDays).abs());
        });

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = tasks[index];
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
                        height: 145,
                        color:
                            ds['type'] == 'Selesai' ? Colors.green : Colors.red,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, top: 10, bottom: 10, right: 5),
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
                                              ds['title'].length > 20
                                                  ? ds['title']
                                                          .substring(0, 20) +
                                                      '...'
                                                  : ds['title'],
                                              style: const TextStyle(
                                                fontSize: 22,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    TextEditingController
                                                        descriptionController =
                                                        TextEditingController(
                                                            text: ds[
                                                                'description']);
                                                    TextEditingController
                                                        dateLineController =
                                                        TextEditingController(
                                                            text:
                                                                ds['dateLine']);
                                                    TextEditingController
                                                        titleController =
                                                        TextEditingController(
                                                            text: ds['title']);

                                                    EditTask(
                                                      context,
                                                      ds.id,
                                                      ds['type'],
                                                      titleController,
                                                      descriptionController,
                                                      dateLineController,
                                                      selectDate,
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
                                                          title: Text(
                                                            "Delete Confirmation",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          content: Text(
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
                                                                padding: EdgeInsets
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
                                                                child: Text(
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
                                                                    .deleteTask(
                                                                        ds.id);
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets
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
                                                                child: Text(
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
                                                  child: Icon(
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
                                        Text(
                                          'Date Line: ${ds['dateLine']}',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Des: ${ds['description']}',
                                          style: const TextStyle(fontSize: 15),
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
