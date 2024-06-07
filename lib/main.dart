import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'todo.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const TodoList(title: 'Todo app'),
    );
  }
}

/// TodoList widget to display and manage todo list
class TodoList extends StatefulWidget {
  const TodoList({super.key, required this.title});

  final String title;

  @override
  State<TodoList> createState() => _TodoList();
}

// ignore: camel_case_types
class _TodoList extends State<TodoList> {
  final List<Todo> entries = <Todo>[];
  final textController = TextEditingController();
  final descController = TextEditingController();
  final String url = 'https://catfact.ninja/fact';

  bool isLoading = false;
  bool addCatFact = false;

  late SharedPreferences prefs;

  /// Fetch random cat fact from the API
  Future<String> randomCatFactFuture() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['fact'];
      } else {
        throw Exception('Failed to load cat fact');
      }
    } catch (e) {
      throw Exception('Failed to load cat fact');
    }
  }

  /// Save this for now if I want to save the todos in shared preferences later
  // @override
  // void initState() {
  //   getSharePrefs();
  //   super.initState();
  // }

  // void getSharePrefs() async {
  //   prefs = await SharedPreferences.getInstance();
  // }
  ///

  /// Add todo to the list
  Future<void> addTodo(BuildContext context) async {
    String desc = descController.text;
    String textToSave =
        textController.text; // Capture the text before async operation

    // Clear the text fields
    textController.clear();
    descController.clear();

    try {
      if (textToSave.isEmpty) {
        throw Exception(
            'You must enter a text for todo. Description can be blank.');
      }

      /// Set loading to true to show loading
      setState(() {
        isLoading = true;
      });

      /// Fetch cat fact if addCatFact is true
      if (addCatFact) {
        try {
          desc = await randomCatFactFuture();
        } catch (e) {
          /// Catch and default to descController.text
        }
      }

      setState(() {
        entries.add(
          Todo(
            title: textToSave,
            description: desc,
          ),
        );
      });
    } catch (e) {
      /// Guard context to check if the widget is still mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            /// Im using toString here, so the error message just propagate.
            /// Its showing an annoying "Exception:" in the beginning though.
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      /// Set loading to false to hide loading
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: "Enter your todo",
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: descController,
                decoration: const InputDecoration(
                  hintText: "Enter description(optional)",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () async {
                  await addTodo(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).colorScheme.primary),
                  foregroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).colorScheme.onPrimary),
                ),
                child: isLoading
                    ? Row(
                        /// Its loading
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Text("Adding, please wait..."),
                        ],
                      )
                    :

                    /// Its not loading anymore
                    const Text("Add Todo"),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: addCatFact,
                  onChanged: (bool? value) {
                    setState(() {
                      addCatFact = value!;
                    });
                  },
                ),
                const Text("Add random cat fact, instead of description"),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(entries[index].getTitle()),
                    subtitle: Text(entries[index].getDescription()),
                    onTap: () {
                      setState(() {
                        descController.text = entries[index].getDescription();
                        textController.text = entries[index].getTitle();
                        entries.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
