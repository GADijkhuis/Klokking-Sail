import 'package:klokking_sail/models/project.dart';

class AppData {
  final List<Project> projects;

  AppData(this.projects);

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
    (json['projects'] as List).map((e) => Project.fromJson(e)).toList(),
  );

  Map<String, dynamic> toJson() => {
    'projects': projects.map((e) => e.toJson()).toList(),
  };
}
