import 'package:flutter/material.dart';

import '../models/project.dart';

class ProjectsView extends StatelessWidget {
  final List<Project> projects;
  final Project? selected;
  final Function(Project) onSelect;
  final VoidCallback onCreate;

  const ProjectsView({required this.projects, required this.selected, required this.onSelect, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Projects"), actions: [IconButton(icon: Icon(Icons.add), onPressed: onCreate)]),
      body: ListView(
        children: projects
            .map(
              (p) => ListTile(
            title: Text(p.name),
            selected: selected?.id == p.id,
            onTap: () => onSelect(p),
          ),
        ).toList(),
      ),
    );
  }
}