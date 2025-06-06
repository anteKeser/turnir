import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tomislav/widgets/groups.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({required this.year, super.key});

  final int year;

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? tournamentData;

  @override
  void initState() {
    super.initState();
    _fetchTournamentData();
  }

  Future<void> _fetchTournamentData() async {
    try {
      final snapshot = await _database.child(widget.year.toString()).get();
      if (snapshot.exists) {
        setState(() {
          tournamentData = Map<String, dynamic>.from(snapshot.value as Map);
        });
      } else {
        print('No data available.');
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  List<Widget> groupNames(int index) {
    List<Widget> groups = [];

    for (var group in tournamentData!['groups']) {
      groups.add(GroupCard(
        groupName: group['name'],
        index: index,
        year: widget.year,
      ));
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return tournamentData == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: groupNames(10).length,
            itemBuilder: (context, index) {
              return groupNames(index)[index];
            },
          );
  }
}
