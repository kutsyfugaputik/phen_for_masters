class StatusModel {
  final int statusId;
  final String name;
  final String? description;

  StatusModel({
    required this.statusId,
    required this.name,
    this.description,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) => StatusModel(
    statusId: json['status_id'],
    name: json['name'],
    description: json['description'],
  );

  Map<String, dynamic> toJson() => {
    'status_id': statusId,
    'name': name,
    'description': description,
  };
}
