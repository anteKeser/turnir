import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:tomislav/widgets/scores_update';
import 'package:tomislav/widgets/team_table.dart';

class GroupStagesScreen extends StatefulWidget {
  const GroupStagesScreen({required this.year, required this.index, super.key});
  final int year;
  final int index;

  @override
  State<GroupStagesScreen> createState() => _GroupStageScreenState();
}

class _GroupStageScreenState extends State<GroupStagesScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<dynamic>? groups;
  bool isLoading = true;
  late DatabaseReference _groupsRef;
  late StreamSubscription<DatabaseEvent> _subscription;

  @override
  void initState() {
    super.initState();
    _groupsRef = _database.child('${widget.year}/groups');
    _setupRealTimeListener();
  }

  @override
  void dispose() {
    _subscription.cancel(); // Important to prevent memory leaks
    super.dispose();
  }

  void _setupRealTimeListener() {
    _subscription = _groupsRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          groups = _convertToList(data);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    }, onError: (error) {
      setState(() => isLoading = false);
      debugPrint("Error listening to data: $error");
    });
  }

  List<dynamic> _convertToList(dynamic value) {
    if (value is List) return value;
    return [];
  }

  Map<String, dynamic> _convertToMap(dynamic value) {
    if (value is Map) return value.cast<String, dynamic>();
    return {};
  }

  String _formatTime(String? time) {
    if (time == null) return 'TBD';
    try {
      return DateFormat('dd-MM HH:mm').format(DateTime.parse(time));
    } catch (e) {
      return 'TBD';
    }
  }

  Widget _buildGroupContent(Map<String, dynamic> group) {
    final matches = _convertToList(group['matches'])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final teams = _convertToList(group['teams']);

    final updatedTeams = updateGroupTable(matches, teams);
    group['teams'] = updatedTeams;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            group['name']?.toString() ?? 'Group',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TeamTable(
              teams: updatedTeams,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._buildGroupMatches(matches),
      ],
    );
  }

  List<Widget> _buildGroupMatches(List<dynamic> matches) {
    List<Widget> widgets = [];
    for (int i = 0; i < matches.length; i++) {
      final matchData = _convertToMap(matches[i]);
      final status = matchData['status']?.toString() ?? 'upcoming';
      final score = matchData['score']?.toString() ?? '0:0';
      final time = _formatTime(matchData['time']?.toString());
      final field = matchData['field']?.toString() ?? '';

      final team1 = matchData['team1']?.toString() ?? 'TBD';
      final team2 = matchData['team2']?.toString() ?? 'TBD';
      final scores = score.split(':');
      final int score1 = int.tryParse(scores[0]) ?? 0;
      final int score2 = int.tryParse(scores[1]) ?? 0;
      final bool team1Won = status == 'finished' && score1 > score2;
      final bool team2Won = status == 'finished' && score2 > score1;

      widgets.add(
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        team1,
                        style: TextStyle(
                          fontWeight:
                              team1Won ? FontWeight.bold : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        status == 'playing' || status == 'finished'
                            ? score
                            : 'vs',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        team2,
                        style: TextStyle(
                          fontWeight:
                              team2Won ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status == 'playing'
                          ? field
                          : status == 'finished'
                              ? 'Finished'
                              : 'Scheduled: $time',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (status == 'playing')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Text(
                        field,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (i % 2 == 1 && i != matches.length - 1) {
        widgets.add(const SizedBox(height: 24));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Memorijalni Turnir \n Milenko Jerković",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color.fromARGB(255, 13, 47, 91),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (groups == null || groups!.isEmpty)
              ? const Center(child: Text('No group data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child:
                      _buildGroupContent(_convertToMap(groups![widget.index])),
                ),
    );
  }
}
