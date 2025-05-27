import 'package:flutter/material.dart';

import '../models/project.dart';

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
    final scores = <String, List<int>>{};

    for (var p in participants) {
      scores[p.sailNumber] = [];
    }

    for (var race in races) {
      for (int i = 0; i < race.length; i++) {
        final sailNumber = race[i];
        if (scores.containsKey(sailNumber)) {
          scores[sailNumber]!.add(i + 1); // Low point system
        }
      }
    }

    final resultList = scores.entries.map((entry) {
      final total = entry.value.fold(0, (a, b) => a + b);
      return {
        'sailNumber': entry.key,
        'name': participants.firstWhere((p) => p.sailNumber == entry.key).name,
        'total': total
      };
    }).toList();

    resultList.sort((a, b) => (a['total'] as int).compareTo(b['total'] as int));

    return Scaffold(
      appBar: AppBar(title: Text("Results for ${project!.name}")),
      body: ListView.builder(
        itemCount: resultList.length,
        itemBuilder: (context, index) {
          final result = resultList[index];
          return ListTile(
            leading: Text("${index + 1}"),
            title: Text("${result['sailNumber']} - ${result['name']}"),
            trailing: Text("${result['total']} pts"),
          );
        },
      ),
    );
  }
}