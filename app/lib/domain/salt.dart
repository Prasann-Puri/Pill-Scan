/// Salt — an active pharmaceutical ingredient.
/// Matches the `salts` array item in /medicines/search JSON response (README §13).
library;

class Salt {
  final int id;
  final String name; // normalized, e.g. "paracetamol"
  final String? strengthText; // e.g. "500 mg" — informational only

  const Salt({
    required this.id,
    required this.name,
    this.strengthText,
  });

  factory Salt.fromJson(Map<String, dynamic> json) => Salt(
        id: json['id'] as int,
        name: json['name'] as String,
        strengthText: json['strength_text'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (strengthText != null) 'strength_text': strengthText,
      };

  @override
  bool operator ==(Object other) =>
      other is Salt && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}
