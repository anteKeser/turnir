// team_table.dart
import 'package:flutter/material.dart';

class TeamTable extends StatelessWidget {
  const TeamTable({required this.teams, super.key});

  final List<dynamic> teams;

  // Helper method to safely convert to Map<String, dynamic>
  Map<String, dynamic> _convertTeam(dynamic team) {
    if (team is Map) {
      return team.cast<String, dynamic>();
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 15,
        headingRowColor: MaterialStateProperty.resolveWith<Color>(
          (states) => Colors.blue[50]!,
        ),
        columns: const [
          DataColumn(
              label:
                  Text('Team', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('P', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('W', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('D', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('L', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('GD', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label:
                  Text('Pts', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: teams.map((team) {
          final teamData = _convertTeam(team);
          return DataRow(
            cells: [
              DataCell(
                Text(
                  teamData['name']?.toString() ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(Text(teamData['played']?.toString() ?? '0')),
              DataCell(Text(teamData['wins']?.toString() ?? '0')),
              DataCell(Text(teamData['draws']?.toString() ?? '0')),
              DataCell(Text(teamData['losses']?.toString() ?? '0')),
              DataCell(Text(teamData['goal_difference']?.toString() ?? '0')),
              DataCell(
                Text(
                  teamData['points']?.toString() ?? '0',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
