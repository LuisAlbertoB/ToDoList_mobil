import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_application/secure_application.dart';
import 'package:todolist_app/view/auth/signup_screen.dart';
import 'package:todolist_app/viewmodel/auth/auth_viewmodel.dart';
import 'package:todolist_app/viewmodel/task/task_viewmodel.dart';

void main() {
  runApp(
    SecureApplication(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDoList App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SignUpScreen(),
    );
  }
}