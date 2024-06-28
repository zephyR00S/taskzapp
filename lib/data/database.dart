import 'package:mongo_dart/mongo_dart.dart';

class ToDoDataBase {
  List toDoList = [];
  Db? _mongodb;
  DbCollection? _collection;
  bool _isMongoInitialized = false;
  final String userId;

  ToDoDataBase(this.userId);

  // Initialize MongoDB connection
  Future<void> initMongoDB() async {
    if (!_isMongoInitialized) {
      const uri =
          'mongodb+srv://demo_user:lriPyQpFZTWPAp3z@cluster0.3fh7itg.mongodb.net/taskapp?retryWrites=true&w=majority&appName=Cluster0';
      _mongodb = await Db.create(uri);
      await _mongodb!.open();
      _collection = _mongodb!.collection('todos_$userId');
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

  // Load data from MongoDB
  Future<void> loadData() async {
    await initMongoDB();
    await fetchFromMongoDB();
  }

  // Update MongoDB
  Future<void> updateDataBase() async {
    await initMongoDB();
    try {
      // Clear existing data in MongoDB
      await _collection!.remove({});
      // Create a temporary list to avoid concurrent modification
      //as  trying to modify a list while iterating over it, is not allowed in Dart.
      final List<Map<String, dynamic>> updatedList = toDoList
          .map((todo) => {
                'title': todo[0],
                'completed': todo[1],
                'createdAt': todo[2].toIso8601String(),
                'completedAt': todo[3]?.toIso8601String(),
                'category': todo[4],
              })
          .toList();
      // Insert all todos to MongoDB
      await _collection!.insertMany(updatedList);
    } catch (e) {
      print('Error updating MongoDB: $e');
    }
  }

  // Fetch data from MongoDB
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
    } catch (e) {
      print('Error fetching from MongoDB: $e');
    }
  }
}
