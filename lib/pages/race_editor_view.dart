import 'package:flutter/material.dart';

class RaceEditorView extends StatefulWidget {
  final List<String> sailNumbers;
  final List<String> entries;

  RaceEditorView({required this.sailNumbers, required this.entries});

  @override
  _RaceEditorState createState() => _RaceEditorState();
}

class _RaceEditorState extends State<RaceEditorView> {
  List<String> entries = [];
  String? selected;

  @override
  void initState() {
    super.initState();
    entries = List.from(widget.entries);
  }

  void _addEntry() {
    if (selected != null && !entries.contains(selected)) {
      setState(() {
        entries.add(selected!);
        selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Race Entries"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => Navigator.pop(context, entries),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selected,
                    hint: Text("Select Sail Number"),
                    items: widget.sailNumbers
                        .where((s) => !entries.contains(s))
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => selected = val),
                  ),
                ),
                IconButton(icon: Icon(Icons.add), onPressed: _addEntry)
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = entries.removeAt(oldIndex);
                  entries.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < entries.length; i++)
                  ListTile(
                    key: ValueKey(entries[i]),
                    title: Text(entries[i]),
                    leading: Icon(Icons.drag_handle),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => setState(() => entries.removeAt(i)),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}