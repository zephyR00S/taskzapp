import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ToDoDataBase {
  List toDoList = [];
  final _myBox = Hive.box('mybox');
  Db? _mongodb;
  DbCollection? _collection;
  bool _isMongoInitialized = false;

  // Initialize MongoDB connection
  Future<void> initMongoDB() async {
    if (!_isMongoInitialized) {
      const uri =
          'mongodb+srv://demo_user:lriPyQpFZTWPAp3z@cluster0.3fh7itg.mongodb.net/taskapp?retryWrites=true&w=majority&appName=Cluster0';
      _mongodb = await Db.create(uri);
      await _mongodb!.open();
      _collection = _mongodb!.collection('todos');
      _isMongoInitialized = true;
    }
  }

  // Create initial data
  Future<void> createInitialData() async {
    toDoList = [
      ["Click + to write..", false, DateTime.now(), null, 'Default'],
    ];
    await updateDataBase();
  }

  // Load data from Hive and sync with MongoDB
  Future<void> loadData() async {
    toDoList = _myBox.get("TODOLIST") ?? [];
    await syncWithMongoDB();
  }

  // Update both Hive and MongoDB
  Future<void> updateDataBase() async {
    await _myBox.put("TODOLIST", toDoList);
    await syncWithMongoDB();
  }

  // Sync Hive data with MongoDB
  Future<void> syncWithMongoDB() async {
    await initMongoDB();
    try {
      // Clear existing data in MongoDB
      await _collection!.remove({});
      // Insert all todos from Hive to MongoDB
      for (var todo in toDoList) {
        await _collection!.insert({
          'title': todo[0],
          'completed': todo[1],
          'createdAt': todo[2].toIso8601String(),
          'completedAt': todo[3]?.toIso8601String(),
          'category': todo[4],
        });
      }
    } catch (e) {
      print('Error syncing with MongoDB: $e');
    }
  }

  // Fetch data from MongoDB and update Hive
  Future<void> fetchFromMongoDB() async {
    await initMongoDB();
    try {
      final fetchedTodos = await _collection!.find().toList();
      toDoList = fetchedTodos
          .map((todo) => [
                todo['title'],
                todo['completed'],
                DateTime.parse(todo['createdAt']),
                todo['completedAt'] != null
                    ? DateTime.parse(todo['completedAt'])
                    : null,
                todo['category'],
              ])
          .toList();
      await _myBox.put("TODOLIST", toDoList);
    } catch (e) {
      print('Error fetching from MongoDB: $e');
    }
  }
}
