import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: const TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> tasks = [];
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(tasks));
  }

  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedTasks = prefs.getString('tasks');
    if (storedTasks != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(storedTasks));
      });
    }
  }

  // S N A C K bar ⭐
  void showSnackbar(String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.hideCurrentSnackBar();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Lottie.asset(
                'assets/success.json',
                fit: BoxFit.cover,
                repeat: false,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.circle,
                    color: Colors.white,
                    size: 20.0,
                  );
                },
                onLoaded: (composition) {
                  // Optional: Add preloading behavior here
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[850],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Add T A S K S ⭐
  void addTask() {
    if (taskController.text.isNotEmpty) {
      setState(
        () {
          tasks.add({"title": taskController.text, "completed": false});
          taskController.clear();
          saveTasks();
          showSnackbar("Task Added Successfully!");
        },
      );
    }
  }

  // Remove T A S K ⭐
  void removeTask(int index) {
    String removedTask = tasks[index]["title"];
    setState(
      () {
        tasks.removeAt(index);
        saveTasks();
        showSnackbar("Task '$removedTask' Deleted!");
      },
    );
  }

  // The indicator of task completion ⭐
  void toggleTaskCompletion(int index) {
    setState(
      () {
        tasks[index]["completed"] = !tasks[index]["completed"];
        saveTasks();
        showSnackbar(tasks[index]["completed"]
            ? "Task Completed!"
            : "Task Marked as Incomplete");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("To-Do List")),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      hintText: "Enter task",
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  backgroundColor: Colors.teal,
                  onPressed: addTask,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Lottie.asset(
                      'assets/empty.json',
                      width: 200,
                      height: 200,
                    ),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Dismissible(
                                key: Key(tasks[index]["title"]),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  color: Colors.red,
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  removeTask(index);
                                },
                                child: Card(
                                  color: Colors.grey[850],
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    leading: GestureDetector(
                                      onTap: () => toggleTaskCompletion(index),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: tasks[index]["completed"]
                                              ? Colors.teal
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: Colors.teal,
                                            width: 2,
                                          ),
                                        ),
                                        width: 24,
                                        height: 24,
                                        child: tasks[index]["completed"]
                                            ? const Icon(
                                                Icons.check,
                                                size: 18,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ),
                                    title: Text(
                                      tasks[index]["title"],
                                      style: TextStyle(
                                        color: tasks[index]["completed"]
                                            ? Colors.grey
                                            : Colors.white,
                                        decoration: tasks[index]["completed"]
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.drag_handle,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
