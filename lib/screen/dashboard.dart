import 'package:flutter/material.dart';
import 'pembukaan_pakan.dart'; // Pastikan file ini ada



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool kontrolValve = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Hello,',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: 'Welcome'),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF648DDB),
      ),
      backgroundColor: const Color(0xFFEEEEEE),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          const SectionTitle('Kualitas Air'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _InfoCard(title: 'Tingkat Air', value: '75%'),
              _InfoCard(title: 'Suhu Air', value: '27.5 °C'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _InfoCard(title: 'pH Air', value: '7.2 pH'),
              _InfoCard(title: 'Kekeruhan Air', value: '25.5 °C'),
            ],
          ),
          const SizedBox(height: 32),
          const SectionTitle('Sistem Power Source'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _InfoCard(title: 'Tegangan Masuk', value: '13,9 V'),
              _InfoCard(title: 'Tegangan Keluar', value: '12,8 V'),
            ],
          ),
          const SizedBox(height: 32),
          const SectionTitle('Kontrol'),
          const SizedBox(height: 12),

          // Kontrol Valve (Switch)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kontrol Valve',
                style: TextStyle(fontSize: 16),
              ),
              Switch(
                value: kontrolValve,
                onChanged: (value) {
                  setState(() {
                    kontrolValve = value;
                  });
                },
                activeColor: const Color(0xFF648DDB),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Kontrol Pakan (Figma-style button)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PembukaanPakan()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Kontrol Pakan',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF648DDB),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }
}
