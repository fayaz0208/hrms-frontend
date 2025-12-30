/// Shift model for shift rosters
class Shift {
  final int id;
  final String name;
  final String? startTime;
  final String? endTime;
  final String? description;

  Shift({
    required this.id,
    required this.name,
    this.startTime,
    this.endTime,
    this.description,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'],
      name: json['name'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'description': description,
    };
  }
}
