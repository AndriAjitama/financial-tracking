// ignore_for_file: use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, use_super_parameters, override_on_non_overriding_member

import 'package:financial_tracking/pages/login/login.dart';
import 'package:financial_tracking/service/auth.dart';
import 'package:flutter/material.dart';
import 'package:financial_tracking/components/navbar/navigation_bar.dart'
    as custom_navbar;

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const custom_navbar.NavigationBar();
          } else {
            return Login();
          }
        });
  }
}

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}
