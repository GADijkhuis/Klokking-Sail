import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:klokking_sail/handlers/file_handler.dart';
import 'package:klokking_sail/pages/finish_view.dart';
import 'package:klokking_sail/pages/participants_view.dart';
import 'package:klokking_sail/pages/projects_view.dart';
import 'package:klokking_sail/pages/result_view.dart';
import 'package:klokking_sail/styles.dart';

import 'models/project.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klokking Sail',
      theme: ThemeData(
        scaffoldBackgroundColor: Styles.backgroundColor,
        appBarTheme: Styles.appBarTheme,
        bottomNavigationBarTheme: Styles.bottomNavigationAppBarTheme,
        useMaterial3: true,
        canvasColor: Styles.backgroundColor,
        primaryColor: Colors.white,
        textTheme: Styles.textTheme,
        colorScheme: ColorScheme.dark(
          primary: Styles.textColor,
          onPrimary: Styles.backgroundSecondaryColor,
          surface: Styles.backgroundSecondaryColor,
          onSurface: Styles.textColor,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _index = 0;
  List<Project> projects = [];
  Project? selectedProject;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final file = await FileHandler.getLocalFile("projects.json");
    if (await file.exists()) {
      final data = jsonDecode(await file.readAsString());
      setState(() {
        projects = (data as List).map((e) => Project.fromJson(e)).toList();
        if (projects.isNotEmpty) selectedProject = projects.first;
      });
    }
  }

  Future<void> _saveProjects() async {
    final file = await FileHandler.getLocalFile("projects.json");
    await file.writeAsString(jsonEncode(projects.map((e) => e.toJson()).toList()));
    setState(() {
      _loadProjects();
    });
  }

  void _createProject() async {
    final nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Create Project"),
        content: TextField(controller: nameController, decoration: InputDecoration(labelText: "Project Name")),
        actions: [
          TextButton(onPressed: () => { Navigator.pop(context) }, child: Text("Cancel")),
          TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newProject = Project(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                  );
                  setState(() {
                    projects.add(newProject);
                    selectedProject = newProject;
                  });
                  _saveProjects();
                }
                Navigator.pop(context);
              },
              child: Text("Save"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      ProjectsView(
        projects: projects,
        selected: selectedProject,
        onSelect: (p) => setState(() => selectedProject = p),
        onCreate: _createProject,
        onSave: _saveProjects
      ),
      ParticipantsView(project: selectedProject, onSave: _saveProjects),
      FinishView(project: selectedProject, onSave: _saveProjects),
      ResultsView(project: selectedProject),
    ];

    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Participants"),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Finish"),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: "Results"),
        ],

      ),
    );
  }
}