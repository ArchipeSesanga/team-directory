import 'dart:convert';
import 'dart:io';

import 'feature/search.dart';
import 'models/team_member.dart';

void main(List<String> args) {
  print('Assignment 1');
  print('------------');

  final members = loadTeam('data/team.json');
  final query = args.join(' ');
  final results = searchTeam(members, query);

  print(
    query.isEmpty
        ? 'All ${results.length} team members:'
        : 'Found ${results.length} match(es) for "$query":',
  );

  for (final member in results) {
    print('  - $member');
  }
}

List<TeamMember> loadTeam(String relativePath) {
  final file = File.fromUri(Platform.script.resolve('../$relativePath'));

  if (!file.existsSync()) {
    stderr.writeln('Could not find ${file.path}');
    exit(1);
  }

  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  return (decoded['team'] as List<dynamic>)
      .map((entry) => TeamMember.fromJson(entry as Map<String, dynamic>))
      .toList();
}
