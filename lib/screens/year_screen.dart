import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tomislav/screens/year_navbar_screen.dart';
import 'package:tomislav/widgets/year.dart';
import 'package:url_launcher/url_launcher.dart';

void _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

class YearScreen extends StatefulWidget {
  const YearScreen({super.key});

  @override
  State<YearScreen> createState() => _YearScreenState();
}

class _YearScreenState extends State<YearScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<int> years = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchYearsFromDatabase();
  }

  Future<void> _fetchYearsFromDatabase() async {
    try {
      final snapshot = await _database.get();
      if (snapshot.exists) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(snapshot.value as Map);
        final List<int> loadedYears =
            data.keys.map((key) => int.tryParse(key)).whereType<int>().toList();
        loadedYears
            .sort((a, b) => b.compareTo(a)); // Sort descending (latest first)
        setState(() {
          years = loadedYears;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching years: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        titleSpacing: 16,
        title: const Text(
          "Memorijalni Turnir \nMilenko Jerković",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 47, 91),
      ),
      drawer: Drawer(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 13, 47, 91),
            title: const Text(
              'Follow Us',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.facebook, color: Colors.blue),
                title: const Text('Facebook'),
                onTap: () {
                  // Replace with your actual Facebook URL
                  _launchURL(
                      'https://www.facebook.com/profile.php?id=100063837168303');
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: Colors.red),
                title: const Text('YouTube'),
                onTap: () {
                  // Replace with your actual YouTube URL
                  _launchURL(
                      'https://www.youtube.com/@NKTomislavLivana/featured');
                },
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : years.isEmpty
              ? const Center(child: Text('No tournament years available'))
              : ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final year = years[index];
                    return YearCard(
                      year: year,
                      onTapYear: (selectedYear) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return YearNavbarScreen(year: selectedYear);
                          },
                        ));
                      },
                    );
                  },
                ),
    );
  }
}
