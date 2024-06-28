import 'dart:math';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ToDoDataBase {
  List toDoList = [];
  Db? _mongodb;
  DbCollection? _todoCollection;
  DbCollection? _userCollection;
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
      _todoCollection = _mongodb!.collection('todos');
      _userCollection = _mongodb!.collection('users');
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
      // Clear existing data in MongoDB for this user
      await _todoCollection!.remove(where.eq('userId', userId));

      final List<Map<String, dynamic>> updatedList = toDoList
          .map((todo) => {
                'userId': userId,
                'title': todo[0],
                'completed': todo[1],
                'createdAt': todo[2].toIso8601String(),
                'completedAt': todo[3]?.toIso8601String(),
                'category': todo[4],
              })
          .toList();

      // Insert all todos to MongoDB
      await _todoCollection!.insertMany(updatedList);
    } catch (e) {
      print('Error updating MongoDB: $e');
    }
  }

  // Fetch data from MongoDB
  Future<void> fetchFromMongoDB() async {
    await initMongoDB();
    try {
      final fetchedTodos =
          await _todoCollection!.find(where.eq('userId', userId)).toList();
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

  // User sign up
  Future<bool> signUp(String username, String password) async {
    await initMongoDB();
    try {
      final existingUser =
          await _userCollection!.findOne(where.eq('username', username));
      if (existingUser != null) {
        return false; // User already exists
      }

      final salt = genRandomString(16);
      final hashedPassword = _hashPassword(password, salt);

      await _userCollection!.insert({
        'username': username,
        'password': hashedPassword,
        'salt': salt,
      });
      return true;
    } catch (e) {
      print('Error signing up: $e');
      return false;
    }
  }

  // User sign in
  Future<bool> signIn(String username, String password) async {
    await initMongoDB();
    try {
      final user =
          await _userCollection!.findOne(where.eq('username', username));
      if (user == null) {
        return false; // User not found
      }

      final hashedPassword = _hashPassword(password, user['salt']);
      return hashedPassword == user['password'];
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  // Helper function to hash password
  String _hashPassword(String password, String salt) {
    var bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  // Helper function to generate random string
  String genRandomString(int len) {
    var r = Random();
    return String.fromCharCodes(
        List.generate(len, (index) => r.nextInt(33) + 89));
  }
}
