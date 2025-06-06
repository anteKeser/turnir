import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class YearCard extends StatefulWidget {
  final int year;
  final void Function(int year) onTapYear;

  const YearCard({
    super.key,
    required this.year,
    required this.onTapYear,
  });

  @override
  State<YearCard> createState() => _YearCardState();
}

class _YearCardState extends State<YearCard> {
  String? winner;
  String? logoUrl;
  bool isClickable = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchYearData();
  }

  Future<void> _fetchYearData() async {
    final ref = FirebaseDatabase.instance.ref('${widget.year}');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final fetchedWinner = data['winner'] as String?;
      final fetchedLogo = data['logoUrl'] as String?;
      final fetchedHasData = data['hasData'] as bool? ?? false;

      if (mounted) {
        setState(() {
          isClickable = fetchedHasData;
          winner = (fetchedWinner != null && fetchedWinner.isNotEmpty)
              ? fetchedWinner
              : null;
          logoUrl = (fetchedLogo != null && fetchedLogo.isNotEmpty)
              ? fetchedLogo
              : null;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isClickable ? () => widget.onTapYear(widget.year) : null,
      child: Card(
        color: isClickable
            ? const Color.fromARGB(255, 144, 198, 232)
            : Colors.grey.shade400,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLoading
              ? Row(
                  children: [
                    const SizedBox(width: 5),
                    Container(
                      height: 20,
                      width: 50,
                      color: Colors.grey.shade300,
                    ),
                    const Spacer(),
                    const SizedBox(
                      width: 80,
                      height: 20,
                      child: LinearProgressIndicator(),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const SizedBox(width: 5),
                    Text(
                      widget.year.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color:
                            isClickable ? Colors.black : Colors.grey.shade800,
                      ),
                    ),
                    const Spacer(),
                    if (winner != null) ...[
                      const Icon(ZondIcons.trophy, color: Colors.black),
                      const SizedBox(width: 6),
                      Text(
                        winner!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      if (logoUrl != null)
                        Image.network(
                          logoUrl!,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
