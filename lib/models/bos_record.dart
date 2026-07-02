class BosRecord {
  final String id;
  final String title;
  final String description;
  final bool active;

  const BosRecord({
    required this.id,
    required this.title,
    required this.description,
    this.active = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'active': active,
  };

  factory BosRecord.fromJson(Map<String, dynamic> json) => BosRecord(
    id: json['id'] as String,
    title: json['title'] as String? ?? 'Balance of System',
    description: json['description'] as String? ?? '',
    active: json['active'] as bool? ?? true,
  );

  BosRecord copyWith({
    String? id,
    String? title,
    String? description,
    bool? active,
  }) {
    return BosRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      active: active ?? this.active,
    );
  }
}