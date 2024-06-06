import 'package:flutter/material.dart';

import 'my_button.dart';

class DialogBox extends StatelessWidget {
  final dynamic controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(230, 0, 0, 0),
      content: SizedBox(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // get user input
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Add a new task ...",
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 27, 27, 27),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 81, 81, 81),
                      width: 3,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.add_circle,
                    color: Colors.blue,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                cursorColor: Colors.blue,
              ),
            ),

            // buttons -> save + cancel
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // save button

                  MyButton(text: "Save", onPressed: onSave),

                  const SizedBox(width: 20),

                  // cancel button
                  MyButton(text: "Cancel", onPressed: onCancel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
