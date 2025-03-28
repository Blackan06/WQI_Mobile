import 'dart:convert';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Cài đặt', style: TextStyle(color: Colors.blueAccent)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'Màn hình cài đặt',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
