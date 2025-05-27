import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class RaceEntryView extends StatefulWidget {
  final List<String> sailNumbers;
  final int raceIndex;
  final List<String> currentEntries;
  final ValueChanged<List<String>> onUpdate;

  RaceEntryView({required this.sailNumbers, required this.raceIndex, required this.currentEntries, required this.onUpdate});

  @override
  _RaceEntryViewState createState() => _RaceEntryViewState();
}

class _RaceEntryViewState extends State<RaceEntryView> {
  late List<String> entries;

  @override
  void initState() {
    super.initState();
    entries = List.from(widget.currentEntries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Race ${widget.raceIndex + 1} Entries"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              widget.onUpdate(entries);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          DropdownButtonFormField<String>(
            hint: Text("Select Sail Number"),
            items: widget.sailNumbers.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) {
              if (val != null && !entries.contains(val)) {
                setState(() => entries.add(val));
              }
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(entries[index]),
                trailing: IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => setState(() => entries.removeAt(index)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}