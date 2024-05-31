import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'task.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Task> _tasks = [];
  Map<String, Color> _categoryColors = {};

  List<Task> get tasks => _tasks;
  Map<String, Color> get categoryColors => _categoryColors;

  TaskProvider() {
    _loadTasksFromLocalStorage();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final user = _auth.currentUser;
    if (user != null) {
      _db.collection('users').doc(user.uid).collection('tasks').snapshots().listen((snapshot) {
        _tasks = snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id)).toList();
        _saveTasksToLocalStorage();
        notifyListeners();
      });
    }
  }

  Future<void> _loadTasksFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List<dynamic> tasksJson = jsonDecode(tasksString);
      _tasks = tasksJson.map((taskJson) => Task.fromMap(taskJson)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveTasksToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = jsonEncode(_tasks.map((task) => task.toMap()).toList());
    await prefs.setString('tasks', tasksString);
  }

  Future<void> addTask(Task task) async {
    final user = _auth.currentUser;
    if (user != null) {
      final taskRef = await _db.collection('users').doc(user.uid).collection('tasks').add(task.toMap());
      _tasks.add(task.copyWith(id: taskRef.id)); // Add the task with the generated ID
      if (!_categoryColors.containsKey(task.category)) {
        _categoryColors[task.category] = Colors.white;
      }
      _saveTasksToLocalStorage();
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final user = _auth.currentUser;
    if (user != null) {
      final index = _tasks.indexOf(task);
      if (index != -1) {
        _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
        await _db.collection('users').doc(user.uid).collection('tasks').doc(task.id).update(_tasks[index].toMap());
        _saveTasksToLocalStorage();
        notifyListeners();
      }
    }
  }

  Future<void> deleteTask(Task task) async {
    final user = _auth.currentUser;
    if (user != null) {
      _tasks.remove(task);
      await _db.collection('users').doc(user.uid).collection('tasks').doc(task.id).delete();
      _saveTasksToLocalStorage();
      notifyListeners();
    }
  }

  void setCategoryColor(String category, Color color) {
    _categoryColors[category] = color;
    notifyListeners();
  }

  Future<void> updateTask(Task oldTask, String title, DateTime dueDate, Priority priority, String category, Color color) async {
    final user = _auth.currentUser;
    if (user != null) {
      final index = _tasks.indexOf(oldTask);
      if (index != -1) {
        _tasks[index] = Task(
          id: oldTask.id,
          title: title,
          dueDate: dueDate,
          priority: priority,
          category: category,
          color: color.value,
          isCompleted: oldTask.isCompleted,
        );
        await _db.collection('users').doc(user.uid).collection('tasks').doc(oldTask.id).update(_tasks[index].toMap());
        if (!_categoryColors.containsKey(category)) {
          _categoryColors[category] = Colors.white;
        }
        _saveTasksToLocalStorage();
        notifyListeners();
      }
    }
  }
}
