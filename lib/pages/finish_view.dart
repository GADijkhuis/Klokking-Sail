import 'package:flutter/material.dart';
import 'package:klokking_sail/pages/race_editor_view.dart';
import '../handlers/file_handler.dart';
import '../models/project.dart';
import '../styles.dart';

class FinishView extends StatefulWidget {
  final Project? project;
  final VoidCallback onSave;

  FinishView({required this.project, required this.onSave});

  @override
  _FinishViewState createState() => _FinishViewState();
}

class _FinishViewState extends State<FinishView> {
  late List<List<String>> _races;
  List<String> get _sailNumbers => widget.project?.participants.map((p) => p.sailNumber).toList() ?? [];

  void _addRace() {
    setState(() {
      _races.add([]);
    });
  }

  void _save() {
    widget.project?.races = _races;
    widget.onSave();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Finish data saved')));
  }

  @override
  void initState() {
    super.initState();
    _races = widget.project?.races ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.project == null) {
      return Center(child: Text("No project selected"));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Finish"),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'export' :
                  await FileHandler.exportJson('races.json', _races);
                  break;
                case 'import' :
                  try {
                    final json = await FileHandler.importJsonListFromFile();
                    if (json != null) {
                      _races = List<List<String>>.from(
                        json.map((e) => List<String>.from(e)),
                      );
                      _save();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error importing races')));
                    }                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 'import', 
                  child: Row(
                    spacing: Styles.baseViewPadding,
                    children: [
                      Icon(Icons.file_download),
                      Text("Import Races")
                    ],
                  )
              ),
              PopupMenuItem(
                  value: 'export',
                  child: Row(
                    spacing: Styles.baseViewPadding,
                    children: [
                      Icon(Icons.file_upload),
                      Text('Export Races')
                    ],
                  )
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
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
          ),
          Padding(
              padding: const EdgeInsets.all(Styles.baseViewPadding),
              child: Column(
                spacing: Styles.baseViewPadding,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addRace,
                    icon: Icon(Icons.add),
                    label: Text("Add Race"),
                    style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(48)),
                  ),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: Icon(Icons.save_alt),
                    label: Text("Save Races"),
                    style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(48)),
                  ),
                ],
              )
          ),
        ],
      )


    );
  }
}