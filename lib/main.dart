import 'package:flutter/material.dart';
import 'package:mirea_task_proj/api/tasks.dart';
import 'package:mirea_task_proj/pages/hellow.dart';

void main() {
  setupLocator();
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pract 9 ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HellowPage(),
    );
  }
}