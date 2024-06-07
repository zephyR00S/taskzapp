import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;
  final DateTime createdAt;
  final DateTime? dueDate; // Added dueDate parameter

  const ToDoTile({
    Key? key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    required this.createdAt,
    required this.dueDate, // Added dueDate to the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Color> tileColors = [
      Colors.blue[200]!,
      Colors.green[200]!,
      Colors.orange[200]!,
      Colors.purple[200]!,
      Colors.red[200]!,
      Colors.yellow[200]!,
    ];

    final DateTime now = DateTime.now();
    final int index = dueDate != null
        ? dueDate!.difference(now).inDays % tileColors.length
        : now.microsecondsSinceEpoch % tileColors.length;
    final Color cardColor = tileColors[index];

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => deleteFunction?.call(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 2.0,
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    side: const BorderSide(color: Colors.black, width: 2),
                    value: taskCompleted,
                    onChanged: onChanged,
                    activeColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      taskName,
                      style: TextStyle(
                        decoration: taskCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Text color is set to black
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(), // Pushes the date and time to the bottom
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${DateFormat('d MMMM, yyyy').format(createdAt)} | ${DateFormat('h:mm a').format(createdAt)}',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 12,
                      ),
                    ),
                    if (dueDate != null)
                      Text(
                        'Due: ${DateFormat('d MMMM, yyyy').format(dueDate!)}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 33, 0, 0),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
