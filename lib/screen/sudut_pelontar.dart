import 'package:flutter/material.dart';


class SudutPelontarPage extends StatefulWidget {
  const SudutPelontarPage({super.key});

  @override
  State<SudutPelontarPage> createState() => _SudutPelontarPageState();
}

class _SudutPelontarPageState extends State<SudutPelontarPage> {
  int _selectedIndex = -1;

  final List<String> _options = ['30 derajat', '60 derajat', '90 derajat'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: Column(
        children: [
          // Header biru seperti Figma
          Container(
            width: double.infinity,
            color: const Color(0xFF648DDB),
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Sudut Pelontar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose what notifications you want to recieve below and we will update the settings.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // List pilihan dengan switch
          ...List.generate(_options.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    _options[index],
                    style: const TextStyle(color: Colors.black),
                  ),
                  trailing: Switch(
                    value: _selectedIndex == index,
                    onChanged: (bool value) {
                      setState(() {
                        _selectedIndex = value ? index : -1;
                      });
                    },
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
