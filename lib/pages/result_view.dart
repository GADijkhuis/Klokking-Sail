import 'package:flutter/material.dart';
import '../models/participant.dart';
import '../models/project.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../styles.dart';

class ResultsView extends StatelessWidget {
  final Project? project;
  final int discardEvery;

  ResultsView({required this.project, this.discardEvery = 5});

  static const List<String> statusOptions = ['DQ', 'OCS', 'DNS', 'DNF'];

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
      final scores = <String, List<Map<String, dynamic>>>{};
      for (var p in classParticipants) {
        scores[p.sailNumber] = [];
      }

      for (var race in races) {
        final classFinishers = race.where((sn) => classParticipants.any((p) => sn.contains(p.sailNumber))).toList();

        for (var p in classParticipants) {
          final entry = classFinishers.firstWhere(
                (sn) => sn.contains(p.sailNumber),
            orElse: () => '',
          );

          if (entry.isEmpty) {
            scores[p.sailNumber]!.add({
              'points': classFinishers.length + 1,
              'status': 'DNF'
            });
            continue;
          }

          final parts = entry.split('-');
          final sailNumber = parts.last;
          final status = statusOptions.firstWhere(
                (s) => entry.startsWith("$s-"),
            orElse: () => "",
          );

          final pos = classFinishers.indexOf(entry);
          final points = status != "" ? classFinishers.length + 1 : pos + 1;

          scores[sailNumber]!.add({
            'points': points,
            'status': status,
          });
        }
      }

      final results = scores.entries.map((entry) {
        final participantScores = entry.value;
        final rawTotal = participantScores.fold(0, (a, b) => a + (b['points'] as int));

        final discards = discardEvery > 0 && participantScores.length >= discardEvery
            ? (participantScores.length ~/ discardEvery)
            : 0;

        final sortedScoresDesc = List<Map<String, dynamic>>.from(participantScores)
          ..sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));

        final discardedScores = sortedScoresDesc.take(discards).toList();

        final netTotal = rawTotal - discardedScores.fold(0, (a, b) => a + (b['points'] as int));

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
        orientation: pw.PageOrientation.landscape,
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

                final scores = r['scores'] as List<Map<String, dynamic>>;
                final discarded = r['discarded'] as List<Map<String, dynamic>>;

                return pw.Row(children: [
                  pw.Expanded(flex: 1, child: pw.Text("${index + 1}")),
                  pw.Expanded(flex: 2, child: pw.Text(r['sailNumber'])),
                  pw.Expanded(flex: 3, child: pw.Text(r['name'])),
                  ...List.generate(totalRaces, (i) {
                    if (i < scores.length) {
                      final score = scores[i];
                      final points = score['points'];
                      final status = score['status'];
                      final display = status != "" ? "$points ($status)" : "$points";
                      final isDiscarded = discarded.contains(score);
                      return pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          display,
                          style: pw.TextStyle(
                            decoration: isDiscarded ? pw.TextDecoration.lineThrough : null,
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
