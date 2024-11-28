import 'package:flutter/material.dart';

import 'login.dart';
import 'register.dart';

class HellowPage extends StatelessWidget {
  const HellowPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const LoginPage())),
                child: const Text("Логин"),),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () =>  Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  RegisterPage())),
                child: const Text("Регистрация"),)
          ],
        ),
      ),
    );
  }
}