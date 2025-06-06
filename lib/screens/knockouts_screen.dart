import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class KnockoutBracketScreen extends StatefulWidget {
  final String tournamentYear;
  KnockoutBracketScreen({required this.tournamentYear});

  @override
  _KnockoutBracketScreenState createState() => _KnockoutBracketScreenState();
}

class _KnockoutBracketScreenState extends State<KnockoutBracketScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? knockoutData;

  @override
  void initState() {
    super.initState();
    _listenToKnockoutUpdates();
  }

  void _listenToKnockoutUpdates() {
    _database
        .child('${widget.tournamentYear}/knockout')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null && mounted) {
        setState(() {
          knockoutData = _convertToMap(data);
        });
      }
    });
  }

  Map<String, dynamic> _convertToMap(dynamic value) {
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    return {};
  }

  List<dynamic> _convertToList(dynamic value) {
    if (value is List) {
      return value.map((e) => _convertToMap(e)).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return knockoutData == null
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (knockoutData!["round_of_16"] != null)
                  _buildKnockoutStage(
                    "Round of 16",
                    _convertToList(knockoutData!["round_of_16"]),
                  ),
                if (knockoutData!["quarter_finals"] != null)
                  _buildKnockoutStage(
                    "Quarter-finals",
                    _convertToList(knockoutData!["quarter_finals"]),
                  ),
                if (knockoutData!["semi_finals"] != null)
                  _buildKnockoutStage(
                    "Semi-finals",
                    _convertToList(knockoutData!["semi_finals"]),
                  ),
                if (knockoutData!["final"] != null)
                  _buildKnockoutStage(
                    "Final",
                    [_convertToMap(knockoutData!["final"])],
                  ),
                if (knockoutData!["third_place"] != null)
                  _buildKnockoutStage(
                    "Third Place",
                    [_convertToMap(knockoutData!["third_place"])],
                  ),
                if (knockoutData!["5th-8th_playoffs"] != null)
                  _buildPlayoffStage(
                    "5th-8th Playoffs",
                    _convertToMap(knockoutData!["5th-8th_playoffs"]),
                  ),
                if (knockoutData!["9th-16th_playoffs"] != null)
                  _buildPlayoffStage(
                    "9th-16th Playoffs",
                    _convertToMap(knockoutData!["9th-16th_playoffs"]),
                  ),
              ],
            ),
          );
  }

  Widget _buildKnockoutStage(String title, List<dynamic> matches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...matches.map((match) => _buildMatchItem(match)).toList(),
      ],
    );
  }

  Widget _buildPlayoffStage(String title, Map<String, dynamic> playoffData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (playoffData["semi_finals"] != null)
          ..._convertToList(playoffData["semi_finals"])
              .map((match) => _buildMatchItem(match, "Semi-finals")),
        if (playoffData["fifth_place"] != null)
          _buildMatchItem(
              _convertToMap(playoffData["fifth_place"]), "5th Place"),
        if (playoffData["seventh_place"] != null)
          _buildMatchItem(
              _convertToMap(playoffData["seventh_place"]), "7th Place"),
        if (playoffData["ninth_place"] != null)
          _buildMatchItem(
              _convertToMap(playoffData["ninth_place"]), "9th Place"),
        if (playoffData["eleventh_place"] != null)
          _buildMatchItem(
              _convertToMap(playoffData["eleventh_place"]), "11th Place"),
        if (playoffData["thirteenth_place"] != null)
          _buildMatchItem(
              _convertToMap(playoffData["thirteenth_place"]), "13th Place"),
        if (playoffData["fifteenth_place"] != null)
          _buildMatchItem(
              _convertToMap(playoffData["fifteenth_place"]), "15th Place"),
      ],
    );
  }

  Widget _buildMatchItem(dynamic match, [String? subtitle]) {
    if (match == null) return SizedBox.shrink();

    final Map<String, dynamic> matchData =
        match is Map ? _convertToMap(match) : {};
    final status = matchData['status']?.toString() ?? 'upcoming';
    final score = matchData['score']?.toString() ?? '0:0';
    final time = matchData['time'] != null
        ? DateFormat('dd-MM HH:mm')
            .format(DateTime.parse(matchData['time'].toString()))
        : 'TBD';
    final field = matchData['field']?.toString() ?? 'Unknown field';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    matchData['team1']?.toString() ?? 'TBD',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    status == 'playing' || status == 'finished' ? score : 'vs',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    matchData['team2']?.toString() ?? 'TBD',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
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
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
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
    );
  }
}
