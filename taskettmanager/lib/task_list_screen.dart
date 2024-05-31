import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_provider.dart';
import 'task.dart';
import 'color_picker_dialog.dart';

num getLuminance(Color color) {
  const double redWeight = 0.299;
  const double greenWeight = 0.587;
  const double blueWeight = 0.114;
  final double red = color.red / 255.0;
  final double green = color.green / 255.0;
  final double blue = color.blue / 255.0;
  return red * redWeight + green * greenWeight + blue * blueWeight;
}

class TaskListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.tasks.isEmpty) {
            return Center(
              child: Text('No tasks available. Add a new task to get started.'),
            );
          }

          final tasksByCategory = <String, List<Task>>{};

          for (var task in taskProvider.tasks) {
            tasksByCategory.putIfAbsent(task.category, () => []).add(task);
          }

          return ListView(
            children: tasksByCategory.entries.map((entry) {
              final category = entry.key;
              final tasks = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      category,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.color_lens),
                      onPressed: () async {
                        final selectedColor = await showDialog<Color>(
                          context: context,
                          builder: (context) => ColorPickerDialog(),
                        );
                        if (selectedColor != null) {
                          taskProvider.setCategoryColor(category, selectedColor);
                        }
                      },
                    ),
                  ),
                  ...tasks.map((task) {
                    TextStyle lightTextStyle = TextStyle(color: Colors.black);
                    TextStyle darkTextStyle = TextStyle(color: Colors.white);
                    Color? selectedColor = taskProvider.categoryColors[task.category];
                    Color? textcolor = getLuminance(selectedColor!) > 0.5 ? Colors.black : Colors.white;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      elevation: 5.0,
                      color: taskProvider.categoryColors[task.category],
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    color: getLuminance(selectedColor) > 0.5 ? Colors.black : Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: textcolor),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => EditTaskDialog(task: task),
                                        );
                                      },
                                    ),
                                    Checkbox(
                                      value: task.isCompleted,
                                      onChanged: (value) {
                                        taskProvider.toggleTaskCompletion(task);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Text('Due Date: ${task.dueDate.year}-${task.dueDate.month}-${task.dueDate.day}', style: getLuminance(selectedColor) > 0.5 ? lightTextStyle : darkTextStyle),
                            Text('Priority: ${task.priority.toString().split('.').last}', style: getLuminance(selectedColor) > 0.5 ? lightTextStyle : darkTextStyle),
                            Text('Category: ${task.category}', style: getLuminance(selectedColor) > 0.5 ? lightTextStyle : darkTextStyle,),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: getLuminance(selectedColor) > 0.5 ? Colors.black : Colors.white ),
                                onPressed: () {
                                  taskProvider.deleteTask(task);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_task');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class EditTaskDialog extends StatefulWidget {
  final Task task;

  EditTaskDialog({required this.task});

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late DateTime _dueDate;
  late Priority _priority;
  late String _category;

  @override
  void initState() {
    super.initState();
    _title = widget.task.title;
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _category = widget.task.category;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                initialValue: _dueDate.toString(),
                decoration: InputDecoration(labelText: 'Due Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != _dueDate) {
                    setState(() {
                      _dueDate = pickedDate;
                    });
                  }
                },
              ),
              DropdownButtonFormField<Priority>(
                value: _priority,
                decoration: InputDecoration(labelText: 'Priority'),
                items: Priority.values.map((priority) {
                  return DropdownMenuItem<Priority>(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (Priority? newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
              ),
              TextFormField(
                initialValue: _category,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
                onSaved: (value) {
                  _category = value!;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final taskProvider = Provider.of<TaskProvider>(context, listen: false);
              taskProvider.updateTask(
                widget.task,
                _title,
                _dueDate,
                _priority,
                _category,
                Colors.transparent,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
