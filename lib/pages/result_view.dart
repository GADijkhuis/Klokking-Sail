import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../models/project.dart';
import '../styles.dart';

class ResultsView extends StatelessWidget {
  final Project? project;

  ResultsView({required this.project});

  @override
  Widget build(BuildContext context) {
    if (project == null) return Center(child: Text("No project selected"));
    if (project!.participants.isEmpty || project!.races.isEmpty) {
      return Center(child: Text("No participants or races available"));
    }

    final participants = project!.participants;
    final races = project!.races;

    // Group participants by sailing class
    final Map<String, List<Participant>> classGroups = {};
    for (var p in participants) {
      classGroups.putIfAbsent(p.sailingClass, () => []).add(p);
    }

    // Calculate results per class
    Map<String, List<Map<String, dynamic>>> classResults = {};

    classGroups.forEach((sailingClass, classParticipants) {
      final scores = <String, List<int>>{};
      for (var p in classParticipants) {
        scores[p.sailNumber] = [];
      }

      for (var race in races) {
        final classFinishers = race.where((sn) =>
            classParticipants.any((p) => p.sailNumber == sn)).toList();

        for (int i = 0; i < classFinishers.length; i++) {
          final sailNumber = classFinishers[i];
          if (scores.containsKey(sailNumber)) {
            scores[sailNumber]!.add(i + 1); // Low point within class
          }
        }
      }


      final results = scores.entries.map((entry) {
        final total = entry.value.fold(0, (a, b) => a + b);
        final participant = classParticipants.firstWhere((p) => p.sailNumber == entry.key);
        return {
          'sailNumber': entry.key,
          'name': participant.name,
          'total': total,
        };
      }).toList();

      results.sort((a, b) => (a['total'] as int).compareTo(b['total'] as int));
      classResults[sailingClass] = results;
    });

    return Scaffold(
      appBar: AppBar(title: Text("Results")),
      body: ListView(
        children: classResults.entries.map((entry) {
          final sailingClass = entry.key;
          final results = entry.value;

          return Card(
            margin: EdgeInsets.only(left: Styles.baseViewPadding, right: Styles.baseViewPadding, top: Styles.baseViewPadding),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent
              ),
              child: ExpansionTile(
                title: Text("Class: $sailingClass"),
                initiallyExpanded: true,
                tilePadding: EdgeInsets.only(left: Styles.baseViewPadding, right: Styles.baseViewPadding),
                childrenPadding: EdgeInsets.zero,
                children: results.asMap().entries.map((e) {
                  final index = e.key;
                  final result = e.value;
                  return ListTile(
                    leading: Text("${index + 1}"),
                    title: Text("${result['sailNumber']} - ${result['name']}"),
                    trailing: Text("${result['total']} pts"),
                  );
                }).toList(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
