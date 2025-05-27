import 'package:flutter/material.dart';
import 'package:klokking_sail/pages/race_editor_view.dart';
import '../models/project.dart';

class FinishView extends StatefulWidget {
  final Project? project;
  final VoidCallback onSave;

  FinishView({required this.project, required this.onSave});

  @override
  _FinishViewState createState() => _FinishViewState();
}

class _FinishViewState extends State<FinishView> {
  List<List<String>> get _races => widget.project?.races ?? [];
  List<String> get _sailNumbers => widget.project?.participants.map((p) => p.sailNumber).toList() ?? [];

  void _addRace() {
    setState(() {
      _races.add([]);
    });
  }

  void _save() {
    widget.onSave();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Finish data saved')));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.project == null) {
      return Center(child: Text("No project selected"));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Finish for ${widget.project!.name}"),
        actions: [
          IconButton(onPressed: _save, icon: Icon(Icons.save)),
          IconButton(onPressed: _addRace, icon: Icon(Icons.add)),
        ],
      ),
      body: ListView.builder(
        itemCount: _races.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("Race ${index + 1}"),
            subtitle: Text(_races[index].join(', ')),
            trailing: Icon(Icons.arrow_forward),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RaceEditorView(
                    sailNumbers: _sailNumbers,
                    entries: _races[index],
                  ),
                ),
              );
              if (result != null && result is List<String>) {
                setState(() {
                  _races[index] = result;
                });
              }
            },
            onLongPress: () => {
              showDialog(context: context, builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Delete Race?"),
                  content: Text("Are you sure you want to delete Race ${index + 1}?"),
                  actions: [
                    TextButton(
                        onPressed: () => {
                          Navigator.of(context).pop()
                        },
                        child: Text("Cancel")
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _races.remove(_races[index]);
                          _save();
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text("Delete"),
                    )
                  ],
                );
              })
            },
          );
        },
      ),
    );
  }
}