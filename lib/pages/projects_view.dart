import 'package:flutter/material.dart';
import '../models/project.dart';
import '../styles.dart';

class ProjectsView extends StatelessWidget {
  final List<Project> projects;
  final Project? selected;
  final Function(Project) onSelect;
  final VoidCallback onCreate;
  final VoidCallback onSave;

  const ProjectsView({
    required this.projects,
    required this.selected,
    required this.onSelect,
    required this.onCreate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Projects")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: projects.map((p) {
                return ListTile(
                  leading: selected?.id == p.id ? Icon(Icons.check) : null,
                  title: Text(p.name),
                  selected: selected?.id == p.id,
                  onTap: () => onSelect(p),
                  onLongPress: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Delete project?"),
                        content: Text("Are you sure you want to delete ${p.name}?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              projects.remove(p);
                              onSave();
                              Navigator.of(context).pop();
                            },
                            child: Text("Delete"),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Styles.baseViewPadding),
            child: ElevatedButton.icon(
              onPressed: onCreate,
              icon: Icon(Icons.add),
              label: Text("Add Project"),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(48)),
            ),
          ),
        ],
      ),
    );
  }
}
