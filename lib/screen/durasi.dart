import 'package:flutter/material.dart';

class DurasiPage extends StatefulWidget {
  const DurasiPage({super.key});

  @override
  State<DurasiPage> createState() => _DurasiPageState();
}

class _DurasiPageState extends State<DurasiPage> {
  int? selectedIndex;

  final List<String> durasiList = ["10 Second", "20 Second", "30 Second"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: Column(
          children: [
            // Header biru tanpa sudut melengkung
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF648DDB),
                borderRadius: BorderRadius.zero, // <- Sudut dihilangkan
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol kembali
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black26,
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Judul dan deskripsi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Durasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose what notifications you want to receive below and we will update the settings.',
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

            const SizedBox(height: 24),

            // Pilihan durasi
            Expanded(
              child: ListView.builder(
                itemCount: durasiList.length,
                padding: const EdgeInsets.symmetric(horizontal: 25),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBFB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          durasiList[index],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Switch(
                          value: selectedIndex == index,
                          onChanged: (_) {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
