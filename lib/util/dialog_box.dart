import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'my_button.dart';

class DialogBox extends StatefulWidget {
  final TextEditingController controller;
  final Function(DateTime?, String) onSave;
  final VoidCallback onCancel;

  const DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  static void show(
    BuildContext context, {
    required TextEditingController controller,
    required Function(DateTime?, String) onSave,
    required VoidCallback onCancel,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return DialogBox(
          controller: controller,
          onSave: onSave,
          onCancel: onCancel,
        );
      },
    );
  }

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  DateTime? _selectedDateTime;
  String? _selectedCategory;
  final List<String> _categories = [
    'default',
    'personal',
    'home',
    'work'
  ]; // Categories list

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150,
                // Adjust the height as needed
                child: Lottie.asset(
                    'assets/Lottie/Animation - 1719331492962.json',
                    fit: BoxFit.contain,
                    frameRate: const FrameRate(60.0)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: "Add a new task ...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  prefixIcon: const Icon(Icons.add_circle),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: ' Select Date and Time',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () {
                            _showDateTimePicker(context);
                          },
                        ),
                      ),
                      controller: TextEditingController(
                        text: _selectedDateTime != null
                            ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                            : '',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyButton(
                    iconData: Icons.cancel,
                    onPressed: () {
                      widget.onCancel();
                    },
                  ),
                  const SizedBox(width: 20),
                  MyButton(
                    iconData: Icons.check,
                    onPressed: () {
                      widget.onSave(
                          _selectedDateTime, _selectedCategory ?? 'default');
                      _selectedDateTime = null;
                      _selectedCategory = null;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDateTimePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate != null) {
        showTimePicker(
          context: context,
          initialTime:
              TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
        ).then((pickedTime) {
          if (pickedTime != null) {
            setState(() {
              _selectedDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
            });
          }
        });
      }
    });
  }
}
