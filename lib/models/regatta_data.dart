import 'package:klokking_sail/models/participant.dart';

class RegattaData {
  final List<Participant> participants;
  final List<List<String>> finishList;
  final List<List<String>> resultList;

  RegattaData(this.participants, this.finishList, this.resultList);

  factory RegattaData.fromJson(Map<String, dynamic> json) => RegattaData(
    (json['participants'] as List)
        .map((e) => Participant.fromJson(e))
        .toList(),
    List<List<String>>.from(
        json['finishList'].map((x) => List<String>.from(x))),
    List<List<String>>.from(
        json['resultList'].map((x) => List<String>.from(x))),
  );

  Map<String, dynamic> toJson() => {
    'participants': participants.map((e) => e.toJson()).toList(),
    'finishList': finishList,
    'resultList': resultList,
  };
}
