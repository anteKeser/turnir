import 'package:flutter/material.dart';
import 'package:tomislav/screens/groups_screen.dart';
import 'package:tomislav/screens/knockouts_screen.dart';
import 'package:tomislav/screens/results_screen.dart';

class YearNavbarScreen extends StatefulWidget {
  const YearNavbarScreen({required this.year, super.key});

  final int year;

  @override
  State<YearNavbarScreen> createState() => _YearNavbarScreen();
}

class _YearNavbarScreen extends State<YearNavbarScreen> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      GroupsScreen(year: widget.year),
      ResultsScreen(
        year: widget.year.toString(),
      ),
      KnockoutBracketScreen(tournamentYear: widget.year.toString()),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        titleSpacing: 16,
        title: const Text(
          "Memorijalni Turnir \nMilenko Jerković",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 47, 91),
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_numbered), label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Live'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_tree), label: 'Knockouts'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 13, 47, 91),
        onTap: _onItemTapped,
      ),
    );
  }
}
