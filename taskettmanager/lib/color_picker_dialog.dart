import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pick a Color'),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: Colors.white,
          onColorChanged: (color) {
            Navigator.of(context).pop(color);
          },
        ),
      ),
    );
  }
}
