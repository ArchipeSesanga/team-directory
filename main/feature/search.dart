import '../models/team_member.dart';

List<TeamMember> searchTeam(
  List<TeamMember> members,
  String query, {
  bool activeOnly = false,
}) {
  final needle = query.trim().toLowerCase();

  return members.where((member) {
    if (activeOnly && !member.active) return false;

    if (needle.isEmpty) return true;

    return member.searchableFields
        .any((field) => field.toLowerCase().contains(needle));
  }).toList();
}
