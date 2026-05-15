import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> faqs = const [
    {'q': 'Bagaimana cara menambah transaksi?', 'a': 'Tekan tombol (+) di bagian bawah layar utama.'},
    {'q': 'Bagaimana cara mengubah tema?', 'a': 'Buka halaman Profil dan tekan toggle Mode Gelap.'},
    {'q': 'Apakah data saya aman?', 'a': 'Ya, data Anda disimpan secara lokal dan aman.'},
    {'q': 'Bagaimana cara ekspor laporan?', 'a': 'Buka tab Laporan dan pilih ikon PDF di bagian atas.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan & FAQ')),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return FadeInUp(
            delay: Duration(milliseconds: index * 100),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: ExpansionTile(
                title: Text(faqs[index]['q']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(faqs[index]['a']!, style: GoogleFonts.outfit(color: Theme.of(context).textTheme.bodySmall?.color)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
