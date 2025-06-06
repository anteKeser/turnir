import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResultsScreen extends StatefulWidget {
  final String year;

  const ResultsScreen({super.key, required this.year});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<Map<String, dynamic>> upcomingMatches = [];
  List<Map<String, dynamic>> _allUpcomingMatches = [];
  List<Map<String, dynamic>> _previousMatches = [];
  Map<String, bool> _highlightedMatches = {};

  bool isLoading = true;
  late DatabaseReference _groupsRef;
  late DatabaseReference _knockoutRef;
  late StreamSubscription<DatabaseEvent> _groupsSubscription;
  late StreamSubscription<DatabaseEvent> _knockoutSubscription;

  @override
  void initState() {
    super.initState();
    _groupsRef = FirebaseDatabase.instance.ref("${widget.year}/groups");
    _knockoutRef = FirebaseDatabase.instance.ref("${widget.year}/knockout");
    _setupRealTimeListeners();
  }

  @override
  void dispose() {
    _groupsSubscription.cancel();
    _knockoutSubscription.cancel();
    super.dispose();
  }

  void _setupRealTimeListeners() {
    _groupsSubscription = _groupsRef.onValue.listen((event) {
      _processMatches(event.snapshot, isGroups: true);
    });
    _knockoutSubscription = _knockoutRef.onValue.listen((event) {
      _processMatches(event.snapshot, isGroups: false);
    });
  }

  void _processMatches(DataSnapshot snapshot, {required bool isGroups}) {
    try {
      List<Map<String, dynamic>> matches = [];

      if (snapshot.exists) {
        if (isGroups) {
          for (var groupSnap in snapshot.children) {
            final group = groupSnap.value;
            if (group is Map && group.containsKey('matches')) {
              final groupMatches = _convertToList(group['matches']);
              for (var match in groupMatches) {
                final matchData = _convertToMap(match);
                matchData['field'] = matchData['field'] ?? 'Unknown';
                if (matchData['status'] == 'upcoming' ||
                    matchData['status'] == 'playing') {
                  matches.add(matchData);
                }
              }
            }
          }
        } else {
          final knockoutData = _convertToMap(snapshot.value);

          void processMatches(dynamic value) {
            if (value is List) {
              for (var match in value) {
                final matchData = _convertToMap(match);
                if (matchData['status'] == 'upcoming' ||
                    matchData['status'] == 'playing') {
                  matchData['field'] = matchData['field'] ?? 'Unknown';
                  matches.add(matchData);
                }
              }
            } else if (value is Map) {
              value.forEach((_, subValue) => processMatches(subValue));
            }
          }

          knockoutData.forEach((_, value) => processMatches(value));
        }

        // Replace only matches from current source
        _allUpcomingMatches.removeWhere(
            (m) => m['source'] == (isGroups ? 'group' : 'knockout'));
        for (var m in matches) {
          m['source'] = isGroups ? 'group' : 'knockout';
          _allUpcomingMatches.add(m);
        }

        // Sort by time
        _allUpcomingMatches.sort((a, b) {
          try {
            return DateTime.parse(a['time'] ?? '')
                .compareTo(DateTime.parse(b['time'] ?? ''));
          } catch (_) {
            return 0;
          }
        });

        // Limit to 3 matches per field
        final Map<String, List<Map<String, dynamic>>> matchesByField = {};
        for (var match in _allUpcomingMatches) {
          final field = match['field']?.toString() ?? 'Unknown';
          if (!matchesByField.containsKey(field)) {
            matchesByField[field] = [];
          }
          if (matchesByField[field]!.length < 3) {
            matchesByField[field]!.add(match);
          }
        }

        final List<Map<String, dynamic>> limitedMatches = [];
        matchesByField.forEach((_, matches) => limitedMatches.addAll(matches));

        _detectChanges(limitedMatches);
        setState(() {
          upcomingMatches = limitedMatches;
          isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint("❌ Error while processing matches: $e");
      debugPrint("🪵 Stack trace:\n$stack");
      setState(() => isLoading = false);
    }
  }

  void _detectChanges(List<Map<String, dynamic>> currentMatches) {
    if (_previousMatches.isEmpty) {
      _previousMatches = currentMatches;
      return;
    }

    final previousMap = {
      for (var match in _previousMatches)
        '${match['team1']}_${match['team2']}_${match['time']}': match
    };

    for (var current in currentMatches) {
      final key = '${current['team1']}_${current['team2']}_${current['time']}';
      final previous = previousMap[key];

      if (previous != null &&
          (current['score'] != previous['score'] ||
              current['status'] != previous['status'])) {
        setState(() {
          _highlightedMatches[key] = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _highlightedMatches.remove(key);
            });
          }
        });
      }
    }

    _previousMatches = currentMatches;
  }

  Map<String, dynamic> _convertToMap(dynamic value) {
    if (value is Map) return value.cast<String, dynamic>();
    return {};
  }

  List<dynamic> _convertToList(dynamic value) {
    if (value is List) return value.map((e) => _convertToMap(e)).toList();
    return [];
  }

  String _formatTime(String? time) {
    if (time == null) return 'TBD';
    try {
      final DateTime dt = DateTime.parse(time);
      return DateFormat('dd-MM HH:mm').format(dt);
    } catch (_) {
      return 'TBD';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (upcomingMatches.isEmpty) {
      return const Center(child: Text('No upcoming matches found'));
    }

    final Map<String, List<Map<String, dynamic>>> matchesByField = {};
    for (var match in upcomingMatches) {
      final field = match['field']?.toString() ?? 'Unknown';
      matchesByField.putIfAbsent(field, () => []).add(match);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming & Live Matches')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: matchesByField.entries.map((entry) {
            final field = entry.key;
            final matches = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    field,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                ...matches.map((match) => _buildMatchCard(match)).toList(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final status = match['status']?.toString() ?? 'upcoming';
    final score = match['score']?.toString() ?? '0:0';
    final time = _formatTime(match['time']?.toString());
    final field = match['field']?.toString() ?? 'Unknown';
    final highlightKey = '${match['team1']}_${match['team2']}_${match['time']}';
    final isHighlighted = _highlightedMatches.containsKey(highlightKey);

    final highlightColor = Colors.blue[100]; // soft blue
    final highlightTextColor = Colors.blue[900]; // dark blue for contrast

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isHighlighted ? highlightColor : Colors.transparent,
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: isHighlighted ? highlightColor : null,
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
                      match['team1'] ?? 'TBD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isHighlighted ? highlightTextColor : null,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isHighlighted ? 18 : 16,
                        color: isHighlighted ? highlightTextColor : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match['team2'] ?? 'TBD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isHighlighted ? highlightTextColor : null,
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
                      color:
                          isHighlighted ? highlightTextColor : Colors.grey[600],
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
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
