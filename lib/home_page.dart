import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
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

  void sortTasksByDueDate() {
    widget.db.toDoList.sort((a, b) {
      DateTime? dueDateA = a[3];
      DateTime? dueDateB = b[3];
      if (dueDateA == null) return 1;
      if (dueDateB == null) return -1;
      return dueDateA.compareTo(dueDateB);
    });
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
        sortTasksByDueDate();
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 260,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome',
                    style: GoogleFonts.blackOpsOne(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      textStyle:
                          const TextStyle(letterSpacing: 0.5, height: 1.2),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.grey),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  TyperAnimatedText(
                    'Tasks Overview',
                    speed: const Duration(milliseconds: 80),
                    textStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 120,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: buildTaskCompletionProgressBar(),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 120,
                      child: Lottie.asset(
                        'assets/Lottie/Animation - 1719673032288.json',
                        fit: BoxFit.contain,
                        frameRate: const FrameRate(60.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                sortTasksByDueDate();
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
