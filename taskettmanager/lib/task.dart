import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { Low, Medium, High }

class Task {
  final String? id; // ID is now optional
  final String title;
  final DateTime dueDate;
  final Priority priority;
  final String category;
  final int color;
  final bool isCompleted;

  Task({
    this.id, // ID is optional in the constructor
    required this.title,
    required this.dueDate,
    required this.priority,
    required this.category,
    required this.color,
    required this.isCompleted,
  });

//  factory Task.fromMap(Map<String, dynamic> data, [String? documentId]) {
    return Task(
      id: documentId,
      title: data['title'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      priority: _priorityFromString(data['priority']),
      category: data['category'],
      color: data['color'],
      isCompleted: data['isCompleted'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': _priorityToString(priority),
      'category': category,
      'color': color,
      'isCompleted': isCompleted,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    Priority? priority,
    String? category,
    int? color,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  static Priority _priorityFromString(String priority) {
    switch (priority) {
      case 'Low':
        return Priority.Low;
      case 'Medium':
        return Priority.Medium;
      case 'High':
        return Priority.High;
      default:
        throw ArgumentError('Unknown priority: $priority');
    }
  }

  static String _priorityToString(Priority priority) {
    switch (priority) {
      case Priority.Low:
        return 'Low';
      case Priority.Medium:
        return 'Medium';
      case Priority.High:
        return 'High';
    }
  }
}
