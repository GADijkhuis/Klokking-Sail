import 'package:flutter/material.dart';
import 'package:klokking_sail/handlers/file_handler.dart';

import '../models/participant.dart';
import '../models/project.dart';
import '../styles.dart';

class ParticipantsView extends StatefulWidget {
  final Project? project;
  final VoidCallback onSave;

  ParticipantsView({required this.project, required this.onSave});

  @override
  _ParticipantsViewState createState() => _ParticipantsViewState();
}

class _ParticipantsViewState extends State<ParticipantsView> {
  List<Participant> _participants = [];
  @override
  void initState() {
    super.initState();
    _participants = widget.project?.participants.toList() ?? [];
  }

  void _addParticipant() {
    setState(() {
      _participants.add(Participant(sailNumber: '', name: '', sailingClass: ''));
    });
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants.removeAt(index);
    });
  }

  void _save() {
    if (widget.project != null) {
      widget.project!.participants = _participants;
    }
    widget.onSave();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Participants saved')));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.project == null) {
      return Center(child: Text("No project selected"));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Participants"),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'export' :
                  await FileHandler.exportJson('participants.json', _participants.map((e) => e.toJson()).toList());
                  break;
                case 'import' :
                  try {
                    final json = await FileHandler.importJsonListFromFile();
                    if (json != null) {
                      _participants =
                          json.map((e) => Participant.fromJson(e)).toList();
                      _save();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error importing Participants')));
                    }
                  }
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
                      Text("Import Participants")
                    ],
                  )
              ),
              PopupMenuItem(
                  value: 'export',
                  child: Row(
                    spacing: Styles.baseViewPadding,
                    children: [
                      Icon(Icons.file_upload),
                      Text('Export Participants')
                    ],
                  )
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child:
            ListView.builder(
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final participant = _participants[index];
                return Card(
                  margin: EdgeInsets.only(left: Styles.baseViewPadding, right: Styles.baseViewPadding, top: Styles.baseViewPadding),
                  child: Padding(
                    padding: const EdgeInsets.all(Styles.baseViewPadding),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  showDialog(context: context, builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Delete Participant?"),
                                      content: Text("Are you sure you want to delete participant ${participant.name}?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () => {
                                              Navigator.of(context).pop()
                                            },
                                            child: Text("Cancel")
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _removeParticipant(index);
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Participant deleted")));
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Delete"),
                                        )
                                      ],
                                    );
                                  });
                                },
                                child: Row(
                                  spacing: 8,
                                  children: [
                                    Icon(Icons.delete),
                                    Text("Delete")
                                  ],
                                )
                            ),
                          ],
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Sail Number'),
                          onChanged: (val) => participant.sailNumber = val,
                          controller: TextEditingController(text: participant.sailNumber),
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Name'),
                          onChanged: (val) => participant.name = val,
                          controller: TextEditingController(text: participant.name),
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Sailing Class'),
                          onChanged: (val) => participant.sailingClass = val,
                          controller: TextEditingController(text: participant.sailingClass),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
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
                  onPressed: _addParticipant,
                  icon: Icon(Icons.add),
                  label: Text("Add Participant"),
                  style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(48)),
                ),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(Icons.save_alt),
                  label: Text("Save Participants"),
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