import 'package:flutter/material.dart';
import 'package:tomislav/screens/group_stages_screen.dart';

class GroupCard extends StatelessWidget {
  const GroupCard(
      {super.key,
      required this.groupName,
      required this.year,
      required this.index});

  final String groupName;
  final int index;
  final int year;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return GroupStagesScreen(year: year, index: index);
          },
        ));
      },
      child: Card(
        color: const Color.fromARGB(255, 144, 198, 232),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Text(
                groupName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
