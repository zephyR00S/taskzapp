import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskzapp/util/login_screen.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
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
  final ValueNotifier<double> completionPercentageNotifier =
      ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void updateCompletionPercentage() {
    int completedTasks =
        widget.db.toDoList.where((task) => task[1] == true).length;
    int totalTasks = widget.db.toDoList.length;
    double newPercentage =
        totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
    completionPercentageNotifier.value = newPercentage;
  }

  void _logout() {
    // Clear any local user data if necessary
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const SignInScreen(), // Ensure you've imported this
    ));
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
    updateCompletionPercentage(); // Update the percentage after loading data
  }

  final _controller = TextEditingController();

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      widget.db.toDoList[index][1] = !widget.db.toDoList[index][1];
    });
    widget.db.updateDataBase();
    updateCompletionPercentage(); // Update the percentage when a task is checked/unchecked
  }

  Future<void> saveNewTask(DateTime? dueDate, String? category) async {
    setState(() {
      widget.db.toDoList
          .add([_controller.text, false, DateTime.now(), dueDate, category]);
      _controller.clear();
    });
    await widget.db.updateDataBase();
    updateCompletionPercentage(); // Update the percentage when a new task is added
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
    updateCompletionPercentage(); // Update the percentage when a task is deleted
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

  Widget buildTaskCompletionProgressBar() {
    return ValueListenableBuilder<double>(
      valueListenable: completionPercentageNotifier,
      builder: (context, value, child) {
        return SimpleCircularProgressBar(
          valueNotifier: completionPercentageNotifier,
          progressStrokeWidth: 8,
          backStrokeWidth: 8,
          mergeMode: true,
          maxValue: 100,
          progressColors: const [
            Color.fromARGB(255, 255, 1, 136),
            Colors.cyan,
            Colors.green,
            Colors.amberAccent,
            Colors.redAccent,
          ],
          backColor: Colors.grey.withOpacity(0.3),
          onGetText: (double value) {
            return Text(
              '${value.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 254, 55, 151),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight:
            250, // Adjust the height to fit the progress bar and other contents
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Welcome',
              style: GoogleFonts.blackOpsOne(
                fontWeight: FontWeight.bold,
                fontSize: 48,
                textStyle: const TextStyle(letterSpacing: 1, height: 1.5),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                TyperAnimatedText(
                  'Tasks Completed...',
                  speed: const Duration(milliseconds: 100),
                  textStyle: const TextStyle(
                    color: Color.fromARGB(255, 168, 167, 167),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Add the progress bar widget here
            SizedBox(
              height: 120, // Adjust the height as needed
              child: buildTaskCompletionProgressBar(),
            ),
          ],
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(bottom: 130),
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
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
            ),
    );
  }
}
