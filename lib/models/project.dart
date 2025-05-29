import 'package:klokking_sail/models/participant.dart';

class Project {
  final String id;
  final String name;
  List<Participant> participants;
  List<List<String>> races;

  Project({required this.id, required this.name, this.participants = const [], this.races = const []});

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'],
    name: json['name'],
    participants: (json['participants'] as List).map((e) => Participant.fromJson(e)).toList(),
    races: List<List<String>>.from(json['races'].map((x) => List<String>.from(x))),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'participants': participants.map((e) => e.toJson()).toList(),
    'races': races,
  };
}