class University {
  final int id;
  final String name;

  University({required this.id, required this.name});

  factory University.fromJson(Map<String, dynamic> json) => University(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    name: json['name'] ?? '',
  );
}
