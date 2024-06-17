import 'package:flutter/material.dart';
import 'my_button.dart';

class DialogBox extends StatefulWidget {
  final TextEditingController controller;
  final Function(DateTime?, String) onSave;
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
  String? _selectedCategory;
  final List<String> _categories = [
    'default',
    'personal',
    'home',
    'work'
  ]; // Categories list

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(230, 0, 0, 0),
      content: SizedBox(
        height: 250, // Increased height to accommodate dropdown
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
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

            const SizedBox(height: 10),
            // Dropdown for Categories
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
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
                      widget.onSave(
                          _selectedDate, _selectedCategory ?? 'default');
                      _selectedDate = null; // Reset the selected date
                      _selectedCategory = null; // Reset the selected category
                    },
                  ),
                  const SizedBox(width: 20),
                  // Cancel button
                  MyButton(
                    iconData: Icons.cancel,
                    onPressed: widget.onCancel,
                  ),
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
