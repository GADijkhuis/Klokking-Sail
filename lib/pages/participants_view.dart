import 'package:flutter/material.dart';

import '../models/participant.dart';
import '../models/project.dart';

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
        title: Text("Participants for ${widget.project!.name}"),
        actions: [
          IconButton(onPressed: _save, icon: Icon(Icons.save)),
          IconButton(onPressed: _addParticipant, icon: Icon(Icons.add))
        ],
      ),
      body: ListView.builder(
        itemCount: _participants.length,
        itemBuilder: (context, index) {
          final participant = _participants[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
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
                  ElevatedButton(
                    onPressed: () => _removeParticipant(index),
                    child: Text("Remove"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}