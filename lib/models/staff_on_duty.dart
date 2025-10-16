class StaffOnDuty {
  final String name;
  final String contact;
  final String dateRange;
  final String role;

  const StaffOnDuty({
    required this.name,
    required this.contact,
    required this.dateRange,
    required this.role,
  });

  factory StaffOnDuty.fromFirestore(Map<String, dynamic> json) {
    return StaffOnDuty(
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      dateRange: json['dateRange'] ?? '',
      role: json['role'] ?? '',
    );
  }

  // ------------------------------------------------------------------
  // FIX 1: Add toJson() for saving to SharedPreferences (local cache)
  // ------------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact': contact,
      'dateRange': dateRange,
      'role': role,
    };
  }

  // ------------------------------------------------------------------
  // FIX 2: Add fromLocalJson() for loading from SharedPreferences
  // ------------------------------------------------------------------
  // NOTE: This is separate from fromFirestore, though the implementation is similar.
  factory StaffOnDuty.fromLocalJson(Map<String, dynamic> json) {
    return StaffOnDuty(
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      dateRange: json['dateRange'] ?? '',
      role: json['role'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffOnDuty &&
          name == other.name &&
          contact == other.contact &&
          dateRange == other.dateRange &&
          role == other.role;

  @override
  int get hashCode => Object.hash(name, contact, dateRange, role);
}
