import 'package:flutter/material.dart';
import '../styles.dart';

class RaceEditorView extends StatefulWidget {
  final List<String> sailNumbers;
  final List<String> entries;

  RaceEditorView({required this.sailNumbers, required this.entries});

  @override
  _RaceEditorState createState() => _RaceEditorState();
}

class _RaceEditorState extends State<RaceEditorView> {
  bool locked = true;
  List<String> entries = [];
  String? selected;
  final List<String> statusOptions = ['DQ', 'OCS', 'DNS', 'DNF'];

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

  void _addStatus(String status) {
    if (selected != null) {
      final labeled = "$status-${selected!}";
      if (!entries.contains(labeled)) {
        setState(() {
          entries.add(labeled);
          selected = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Race Entries"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Styles.baseViewPadding),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selected,
                    hint: Text("Select Sail Number"),
                    items: widget.sailNumbers
                        .where((s) => !entries.contains(s) &&
                        statusOptions.every((status) =>
                        !entries.contains("$status-$s")))
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => selected = val),
                  ),
                ),
                SizedBox(width: Styles.baseViewPadding),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text("Add"),
                  onPressed: _addEntry,
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  tooltip: "Add status",
                  onSelected: _addStatus,
                  itemBuilder: (context) => statusOptions
                      .map((s) => PopupMenuItem(value: s, child: Text(s)))
                      .toList(),
                )
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                if (locked) return;

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
          ),
          Padding(
            padding: EdgeInsets.only(
              left: Styles.baseViewPadding,
              right: Styles.baseViewPadding,
              top: Styles.baseViewPadding,
              bottom: 48,
            ),
            child: Column(
              spacing: Styles.baseViewPadding,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      locked = !locked;
                    });
                  },
                  icon: Icon(locked ? Icons.lock_outline : Icons.lock_open_outlined),
                  label: Text(locked ? "Positions locked" : "Positions unlocked"),
                  style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(48)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, entries);
                  },
                  icon: Icon(Icons.save_alt),
                  label: Text("Save & Exit"),
                  style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(48)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
