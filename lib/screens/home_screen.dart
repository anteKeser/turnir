import 'package:flutter/material.dart';

const List<String> list = <String>["Hrvatski  ", "English  "];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  String dropdownItem = list.first;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 16,
        title: const Text(
          "Memorijalni Turnir \nMilenko Jerković",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 47, 91),
      ),
      backgroundColor: const Color.fromARGB(255, 216, 245, 255),
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset("assets/images/logo.png"),
              const SizedBox(height: 24),
              DropdownButton<String>(
                value: dropdownItem,
                icon: const Icon(Icons.language_rounded),
                onChanged: (String? value) {
                  setState(() {
                    dropdownItem = value!;
                  });
                },
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 80),
              ElevatedButton(
                  onPressed: () {},
                  child: Text(
                      dropdownItem == list.first ? "Dobrodošli!" : "Welcome"))
            ],
          ),
        ),
      ),
    );
  }
}
