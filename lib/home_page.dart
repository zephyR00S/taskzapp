import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/database.dart';
import '../util/dialog_box.dart';
import '../util/todo_tile.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatefulWidget {
  final ToDoDataBase db;
  const HomePage({super.key, required this.db});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
    });
    await widget.db.loadData(); // This now fetches data from MongoDB
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  final _controller = TextEditingController();

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      widget.db.toDoList[index][1] = !widget.db.toDoList[index][1];
    });
    widget.db.updateDataBase();
  }

  Future<void> saveNewTask(DateTime? dueDate, String? category) async {
    setState(() {
      widget.db.toDoList
          .add([_controller.text, false, DateTime.now(), dueDate, category]);
      _controller.clear();
    });
    await widget.db.updateDataBase();
    _showSnackBar('Task Added !', Colors.green[600]!);
  }

  void createNewTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DialogBox(
        controller: _controller,
        onSave: saveNewTask,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> deleteTask(int index) async {
    setState(() {
      widget.db.toDoList.removeAt(index);
    });
    await widget.db.updateDataBase();
    _showSnackBar('Task Deleted !', Colors.red[600]!);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 187,
            right: 15,
            left: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 150,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Welcome',
                style: GoogleFonts.blackOpsOne(
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    textStyle: const TextStyle(letterSpacing: 1, height: 1.5)),
              ),
              const SizedBox(height: 8),
              AnimatedTextKit(repeatForever: true, animatedTexts: [
                TyperAnimatedText(
                  'What are your plans ?',
                  speed: const Duration(milliseconds: 100),
                  textStyle: const TextStyle(
                      color: Color.fromARGB(255, 168, 167, 167),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ]),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewTask,
          child: const Icon(Icons.add),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : MasonryGridView.count(
                padding: const EdgeInsets.only(top: 16.0),
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                itemCount: widget.db.toDoList.length,
                itemBuilder: (context, index) {
                  return ToDoTile(
                    taskName: widget.db.toDoList[index][0],
                    taskCompleted: widget.db.toDoList[index][1],
                    createdAt: widget.db.toDoList[index][2],
                    dueDate: widget.db.toDoList[index][3],
                    category: widget.db.toDoList[index][4],
                    onChanged: (value) => checkBoxChanged(value, index),
                    deleteFunction: (context) => deleteTask(index),
                  );
                },
              ));
  }
}
