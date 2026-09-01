class TeamMember {
  final int id;
  final String name;
  final String role;
  final String department;
  final String email;
  final String location;
  final bool active;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.location,
    required this.active,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as int,
      name: json['name'] as String,
      role: json['role'] as String,
      department: json['department'] as String,
      email: json['email'] as String,
      location: json['location'] as String,
      active: json['active'] as bool,
    );
  }

  List<String> get searchableFields => [
    name,
    role,
    department,
    email,
    location,
  ];

  @override
  String toString() =>
      '$name — $role, $department ($location)${active ? '' : ' [inactive]'}';
}
