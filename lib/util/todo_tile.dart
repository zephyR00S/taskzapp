import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? category;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    required this.createdAt,
    required this.dueDate,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final int colorIndex = dueDate != null
        ? dueDate!.difference(now).inDays % Colors.primaries.length
        : now.microsecondsSinceEpoch % Colors.primaries.length;
    final Color cardColor = Colors.primaries[colorIndex].shade200;

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: deleteFunction,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            icon: Icons.delete_outline_rounded,
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 2.0,
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(-12, -12),
                    child: Checkbox(
                      side: const BorderSide(color: Colors.black, width: 2),
                      value: taskCompleted,
                      onChanged: onChanged,
                      activeColor: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(-8, -10),
                      child: Text(
                        taskName,
                        style: TextStyle(
                          decoration: taskCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${DateFormat('d MMMM, yyyy').format(createdAt)} \n${DateFormat('h:mm a').format(createdAt)}',
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 12,
                ),
              ),
              if (dueDate != null)
                Text(
                  'Due: ${DateFormat('d MMMM, yyyy').format(dueDate!)}',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 13,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold),
                ),
              Text(
                '$category',
                style: const TextStyle(
                  color: Color.fromARGB(255, 33, 0, 0),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
