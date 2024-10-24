import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Untuk manipulasi tanggal

class Diagramad extends StatefulWidget {
  const Diagramad({super.key});

  @override
  State<Diagramad> createState() => _DiagramadState();
}

class _DiagramadState extends State<Diagramad> {
  List<BarChartGroupData> barChartDataMasuk = [];
  List<BarChartGroupData> barChartDataKeluar = [];
  Map<String, int> totalBarangMasuk = {};
  Map<String, int> totalBarangKeluar = {};
  int? touchedIndexMasuk; // Menyimpan index yang ditekan untuk barang masuk
  int? touchedIndexKeluar; // Menyimpan index yang ditekan untuk barang keluar

  // Filter yang tersedia
  String selectedFilter = 'Semua'; // Default filter adalah Semua

  // Daftar warna untuk barang masuk dan keluar
  List<Color> colorsMasuk = [
    Colors.lightGreen[900]!,
    Colors.blue[900]!,
    Colors.orange[700]!,
    Colors.purple[600]!,
    Colors.teal[700]!,
    Colors.indigo[900]!,
  ];

  List<Color> colorsKeluar = [
    Colors.red[900]!,
    Colors.amber[700]!,
    Colors.pink[600]!,
    Colors.brown[700]!,
    Colors.green[700]!,
    Colors.cyan[600]!,
  ];

  @override
  void initState() {
    super.initState();
    fetchData(); // Panggil fetchData saat pertama kali build
  }

  Future<void> fetchData() async {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (selectedFilter) {
      case 'Per Hari':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Per Minggu':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Per Bulan':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default: // Semua
        startDate = DateTime(2000); // Tanggal awal yang sangat lama
    }

    // Ambil data barang masuk
    QuerySnapshot barangMasukSnapshot = await FirebaseFirestore.instance
        .collection('Barang_masuk')
        .where('Tanggal', isGreaterThanOrEqualTo: startDate)
        .get();
    List<QueryDocumentSnapshot> barangMasukDocs = barangMasukSnapshot.docs;

    // Ambil data barang keluar
    QuerySnapshot barangKeluarSnapshot = await FirebaseFirestore.instance
        .collection('Barang_Keluar')
        .where('Tanggal', isGreaterThanOrEqualTo: startDate)
        .get();
    List<QueryDocumentSnapshot> barangKeluarDocs = barangKeluarSnapshot.docs;

    // Mengolah data barang masuk
    totalBarangMasuk.clear();
    for (var doc in barangMasukDocs) {
      var data = doc.data() as Map<String, dynamic>;
      String namaBarang = data['Nama_Barang'];
      int jumlahMasuk = data['Jumlah_masuk'] ?? 0;

      if (totalBarangMasuk.containsKey(namaBarang)) {
        totalBarangMasuk[namaBarang] =
            totalBarangMasuk[namaBarang]! + jumlahMasuk;
      } else {
        totalBarangMasuk[namaBarang] = jumlahMasuk;
      }
    }

    // Mengolah data barang keluar
    totalBarangKeluar.clear();
    for (var doc in barangKeluarDocs) {
      var data = doc.data() as Map<String, dynamic>;
      String namaBarang = data['Nama_Barang'];
      int jumlahKeluar = data['Jumlah_keluar'] ?? 0;

      if (totalBarangKeluar.containsKey(namaBarang)) {
        totalBarangKeluar[namaBarang] =
            totalBarangKeluar[namaBarang]! + jumlahKeluar;
      } else {
        totalBarangKeluar[namaBarang] = jumlahKeluar;
      }
    }

    // Mengkonversi dan mengurutkan data untuk grafik
    List<MapEntry<String, int>> sortedBarangMasuk = totalBarangMasuk.entries
        .toList()
      ..sort((a, b) => b.value
          .compareTo(a.value)); // Urutkan berdasarkan jumlah (descending)
    List<MapEntry<String, int>> sortedBarangKeluar = totalBarangKeluar.entries
        .toList()
      ..sort((a, b) => b.value
          .compareTo(a.value)); // Urutkan berdasarkan jumlah (descending)

    List<BarChartGroupData> barangMasuk = [];
    List<BarChartGroupData> barangKeluar = [];

    for (int i = 0; i < sortedBarangMasuk.length; i++) {
      barangMasuk.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: sortedBarangMasuk[i].value.toDouble(),
              color: colorsMasuk[i % colorsMasuk.length],
              width: 20,
              borderRadius: BorderRadius.circular(0),
            ),
          ],
        ),
      );
    }

    for (int i = 0; i < sortedBarangKeluar.length; i++) {
      barangKeluar.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: sortedBarangKeluar[i].value.toDouble(),
              color: colorsKeluar[i % colorsKeluar.length],
              width: 20,
              borderRadius: BorderRadius.circular(0),
            ),
          ],
        ),
      );
    }

    setState(() {
      barChartDataMasuk = barangMasuk;
      barChartDataKeluar = barangKeluar;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10),
            child: Container(color: Colors.transparent,)
          ),
        ),
        elevation: 4,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white.withAlpha(200),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50.0),
            bottomRight: Radius.circular(50.0),
          ),
        ),
        title: const Text(
          "Grafik Barang Masuk & Keluar",
          style: TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        leading: TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize:
                const Size(35, 35), // Sesuaikan ukuran tombol sesuai kebutuhan
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              icon: Icon(
                  Icons.filter_alt_rounded,
                  color: Colors.black,
                  ), // Ganti DropdownButton dengan ikon filter
              onSelected: (newFilter) {
                setState(() {
                  selectedFilter = newFilter;
                  fetchData(); // Update data saat filter berubah
                });
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'Per Hari',
                  child: Text(
                    'Per Hari',
                    style: const TextStyle(fontFamily: 'poppins'),
                  ),
                ),
                PopupMenuItem(
                  value: 'Per Minggu',
                  child: Text(
                    'Per Minggu',
                    style: const TextStyle(fontFamily: 'poppins'),
                  ),
                ),
                PopupMenuItem(
                  value: 'Per Bulan',
                  child: Text(
                    'Per Bulan',
                    style: const TextStyle(fontFamily: 'poppins'),
                  ),
                ),
                PopupMenuItem(
                  value: 'Semua',
                  child: Text(
                    'Semua',
                    style: const TextStyle(fontFamily: 'poppins'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown Filter
             
              const SizedBox(height: 100),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[900],
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(screenWidth * 0.5, 50),
                  ),
                  child: const Text(
                    "Barang Masuk",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                child: BarChart(
                  BarChartData(
                    barGroups: barChartDataMasuk,
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              // Bagian keterangan barang masuk dan keluar
              Text(
                'Keterangan Barang Masuk:',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              for (int i = 0; i < barChartDataMasuk.length; i++)
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      color: colorsMasuk[i % colorsMasuk.length],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${totalBarangMasuk.keys.elementAt(i)}: ${barChartDataMasuk[i].barRods.first.toY.toInt()}',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(screenWidth * 0.5, 50),
                  ),
                  child: const Text(
                    "Barang Keluar",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                child: BarChart(
                  BarChartData(
                    barGroups: barChartDataKeluar,
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Keterangan Barang Keluar:',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              for (int i = 0; i < barChartDataKeluar.length; i++)
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      color: colorsKeluar[i % colorsKeluar.length],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${totalBarangKeluar.keys.elementAt(i)}: ${barChartDataKeluar[i].barRods.first.toY.toInt()}',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
