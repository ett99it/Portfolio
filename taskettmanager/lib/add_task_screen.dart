import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'task.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  String _taskTitle = '';
  DateTime _dueDate = DateTime.now();
  Priority _priority = Priority.Low;
  String _category = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                elevation: 5.0,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _taskTitle = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                    ),
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                elevation: 5.0,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text('Due Date:'),
                      SizedBox(width: 10.0),
                      TextButton(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _dueDate = selectedDate;
                            });
                          }
                        },
                        child: Text(
                          '${_dueDate.year}-${_dueDate.month}-${_dueDate.day}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                elevation: 5.0,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: DropdownButtonFormField<Priority>(
                    value: _priority,
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                    items: Priority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.toString().split('.').last),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Priority',
                    ),
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                elevation: 5.0,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _category = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_taskTitle.isNotEmpty && _category.isNotEmpty) {
                    try {
                      await Provider.of<TaskProvider>(context, listen: false)
                          .addTask(Task(
                        title: _taskTitle,
                        dueDate: _dueDate,
                        priority: _priority,
                        category: _category,
                        isCompleted: false,
                        color: Colors.white.value,
                      ));
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add task: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all fields')),
                    );
                  }
                },
                child: Text('Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
