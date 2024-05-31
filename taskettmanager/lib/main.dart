// main.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'task_list_screen.dart';
import 'add_task_screen.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid?
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA6pTv4GK3ta6pPxbqXXEqhQY0YWEr0KMY",
      appId: "1:747030141288:android:3682fe08e7b9fbdaec9edd",
      messagingSenderId: "747030141288",
      projectId: "taskettmanager",
    ),
  )
      :await Firebase.initializeApp();
  runApp(taskettmanager());
}

class taskettmanager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        home: AuthWrapper(),
        routes: {
          '/auth': (context) => AuthScreen(),
          '/home': (context) => TaskListScreen(),
          '/add_task': (context) => AddTaskScreen(),
        },
      ),
    );
  }
}
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return TaskListScreen();
        }
        return AuthScreen();
      },
    );
  }
}
