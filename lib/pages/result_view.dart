import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../models/project.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../styles.dart';

class ResultsView extends StatelessWidget {
  final Project? project;
  final int discardEvery; // e.g. 5 means 1 discard per 5 races

  ResultsView({required this.project, this.discardEvery = 5});

  Map<String, List<Map<String, dynamic>>> calculateResults(
      Project project,
      List<Participant> participants,
      List<List<String>> races,
      ) {
    final classGroups = <String, List<Participant>>{};
    for (var p in participants) {
      classGroups.putIfAbsent(p.sailingClass, () => []).add(p);
    }

    final classResults = <String, List<Map<String, dynamic>>>{};

    classGroups.forEach((sailingClass, classParticipants) {
      final scores = <String, List<int>>{};
      for (var p in classParticipants) {
        scores[p.sailNumber] = [];
      }

      for (var race in races) {
        // Filter only sail numbers in this class that finished this race
        final classFinishers =
        race.where((sn) => classParticipants.any((p) => p.sailNumber == sn)).toList();

        for (int i = 0; i < classFinishers.length; i++) {
          final sailNumber = classFinishers[i];
          if (scores.containsKey(sailNumber)) {
            scores[sailNumber]!.add(i + 1); // Position = score
          }
        }

        // For participants that did NOT start/finish in this race, assign max points (DNF etc)
        for (var p in classParticipants) {
          if (!classFinishers.contains(p.sailNumber)) {
            // Usually in sailing scoring: number of finishers + 1 points for DNF/DSQ
            final dnfScore = classFinishers.length + 1;
            scores[p.sailNumber]!.add(dnfScore);
          }
        }
      }

      final results = scores.entries.map((entry) {
        final participantScores = entry.value.toList();
        final rawTotal = participantScores.fold(0, (a, b) => a + b);

        // Calculate how many discards allowed
        final discards = discardEvery > 0 && participantScores.length >= discardEvery
            ? (participantScores.length ~/ discardEvery)
            : 0;

        // Sort scores ascending to find worst scores (highest points)
        final sortedScoresDesc = List<int>.from(participantScores)
          ..sort((a, b) => b.compareTo(a));

        // Worst scores to discard (highest points)
        final discardedScores = sortedScoresDesc.take(discards).toList();

        final netTotal = rawTotal - discardedScores.fold(0, (a, b) => a + b);

        final participant = classParticipants.firstWhere((p) => p.sailNumber == entry.key);

        return {
          'sailNumber': entry.key,
          'name': participant.name,
          'scores': participantScores,
          'discarded': discardedScores,
          'total': rawTotal,
          'netTotal': netTotal,
        };
      }).toList();

      results.sort((a, b) => (a['netTotal'] as int).compareTo(b['netTotal'] as int));
      classResults[sailingClass] = results;
    });

    return classResults;
  }


  Future<void> _generatePdf(BuildContext context) async {
    if (project == null) return;

    final pdf = pw.Document();
    final results = calculateResults(project!, project!.participants, project!.races);
    final date = DateTime.now();
    final formattedDate = "${date.day}-${date.month}-${date.year}";
    final totalRaces = project!.races.length;

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Text("Uitslagen",
                style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            "Laagpunten systeem; 1 Aftrekpunt per $discardEvery wedstrijden.",
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "Uitslagen ${project!.name} $formattedDate",
            style: pw.TextStyle(fontSize: 14),
          ),
          pw.SizedBox(height: 20),

          ...results.entries.expand((entry) {
            final sailingClass = entry.key;
            final classResults = entry.value;

            return [
              pw.Text(sailingClass, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),

              pw.Row(children: [
                pw.Expanded(flex: 1, child: pw.Text("NR.")),
                pw.Expanded(flex: 2, child: pw.Text("ZeilNR")),
                pw.Expanded(flex: 3, child: pw.Text("Naam")),
                ...List.generate(totalRaces, (i) => pw.Expanded(flex: 1, child: pw.Text("${i + 1}"))),
                pw.Expanded(flex: 2, child: pw.Text("Totaal")),
                pw.Expanded(flex: 2, child: pw.Text("Na aftrek")),
              ]),
              pw.Divider(),

              ...classResults.asMap().entries.map((e) {
                final index = e.key;
                final r = e.value;

                final scores = r['scores'] as List<int>;
                final discarded = r['discarded'] as List<int>;

                return pw.Row(children: [
                  pw.Expanded(flex: 1, child: pw.Text("${index + 1}")),
                  pw.Expanded(flex: 2, child: pw.Text(r['sailNumber'])),
                  pw.Expanded(flex: 3, child: pw.Text(r['name'])),
                  ...List.generate(totalRaces, (i) {
                    if (i < scores.length) {
                      final score = scores[i];
                      return pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          "$score",
                          style: pw.TextStyle(
                            decoration: discarded.contains(score)
                                ? pw.TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      );
                    } else {
                      return pw.Expanded(flex: 1, child: pw.Text(""));
                    }
                  }),
                  pw.Expanded(flex: 2, child: pw.Text("${r['total']}")),
                  pw.Expanded(flex: 2, child: pw.Text("${r['netTotal']}")),
                ]);
              }),
              pw.SizedBox(height: 16),
            ];
          })
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (project == null) return Center(child: Text("No project selected"));
    if (project!.participants.isEmpty || project!.races.isEmpty) {
      return Center(child: Text("No participants or races available"));
    }

    final results = calculateResults(project!, project!.participants, project!.races);

    return Scaffold(
      appBar: AppBar(
        title: Text("Results"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(context),
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: ListView(
        children: results.entries.map((entry) {
          final sailingClass = entry.key;
          final classResults = entry.value;

          return Card(
            margin: EdgeInsets.only(left: Styles.baseViewPadding, right: Styles.baseViewPadding, top: Styles.baseViewPadding),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text("Class: $sailingClass"),
                initiallyExpanded: true,
                tilePadding: EdgeInsets.only(left: Styles.baseViewPadding, right: Styles.baseViewPadding),
                childrenPadding: EdgeInsets.zero,
                children: classResults.asMap().entries.map((e) {
                  final index = e.key;
                  final result = e.value;
                  return ListTile(
                    leading: Text("${index + 1}"),
                    title: Text("${result['sailNumber']} - ${result['name']}"),
                    trailing: Text("${result['netTotal']} pts"),
                    subtitle: result['total'] != result['netTotal']
                        ? Text("Raw: ${result['total']} pts")
                        : null,
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