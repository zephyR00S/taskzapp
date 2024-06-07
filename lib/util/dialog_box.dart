import 'package:flutter/material.dart';

import 'my_button.dart';

class DialogBox extends StatefulWidget {
  final TextEditingController controller;
  final Function(DateTime?) onSave;
  final VoidCallback onCancel;

  const DialogBox({
    Key? key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(230, 0, 0, 0),
      content: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Get user input
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 0, 0, 0),
                  hintText: "Add a new task ...",
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255),
                      width: 1,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.add_circle,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                cursorColor: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),

            const SizedBox(height: 10),
            // Date field and Select Date button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month_outlined),
                        onPressed: () {
                          _showDatePicker(context);
                        },
                      ),
                    ),
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : '',
                    ),
                  ),
                ),
              ],
            ),
            // Buttons: Save + Cancel
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Save button
                  MyButton(
                    iconData: Icons.check,
                    onPressed: () {
                      setState(() {
                        widget.onSave(_selectedDate);
                        _selectedDate = null; // Reset the selected date
                      });
                    },
                  ),
                  const SizedBox(width: 20),
                  // Cancel button
                  MyButton(iconData: Icons.cancel, onPressed: widget.onCancel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
  }
}
