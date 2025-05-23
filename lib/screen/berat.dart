import 'package:flutter/material.dart';

class BeratPage extends StatefulWidget {
  const BeratPage({super.key});

  @override
  State<BeratPage> createState() => _BeratPageState();
}

class _BeratPageState extends State<BeratPage> {
  String selectedBerat = '';

  void _setBerat(String berat) {
    setState(() {
      selectedBerat = berat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F3), // background abu muda
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bagian Header Biru
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF648DDB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF547CC6), // warna bulatan lebih gelap
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Berat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Choose what notifications you want to receive\nbelow and we will update the settings.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Spacer untuk isi konten
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBeratSwitch("1 KG", selectedBerat == "1 KG", () => _setBerat("1 KG")),
                  const SizedBox(height: 12),
                  _buildBeratSwitch("2 KG", selectedBerat == "2 KG", () => _setBerat("2 KG")),
                  const SizedBox(height: 12),
                  _buildBeratSwitch("3 KG", selectedBerat == "3 KG", () => _setBerat("3 KG")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeratSwitch(String label, bool isSelected, VoidCallback onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Switch(
            value: isSelected,
            onChanged: (_) => onChanged(),
            activeColor: const Color(0xFF648DDB),
          ),
        ],
      ),
    );
  }
}
