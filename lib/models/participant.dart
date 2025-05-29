class Participant {
  String sailNumber;
  String name;
  String sailingClass;

  Participant({required this.sailNumber, required this.name, required this.sailingClass});

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    sailNumber: json['sailNumber'],
    name: json['name'],
    sailingClass: json['sailingClass'],
  );

  Map<String, dynamic> toJson() => {
    'sailNumber': sailNumber,
    'name': name,
    'sailingClass': sailingClass,
  };
}