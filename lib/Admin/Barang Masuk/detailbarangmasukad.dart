import 'dart:io';
import 'package:assettrack2/Admin/Barang%20Masuk/editbarangmasukad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../bar/bottomnavad.dart';

class Detailbarangmasukad extends StatefulWidget {
  final String barangId; // Ambil ID barang dari halaman sebelumnya
  const Detailbarangmasukad({super.key, required this.barangId});

  @override
  State<Detailbarangmasukad> createState() => _DetailbarangmasukadState();
}

class _DetailbarangmasukadState extends State<Detailbarangmasukad> {
  DocumentSnapshot? barangData; // Untuk menyimpan data barang
  DocumentSnapshot? kategoriData;

  get barangId => null;

  get namaBarang => null;

  get jumlahMasuk => null;

  get tanggal => null;

  get catatan => null; // Untuk menyimpan data kategori terkait

  @override
  void initState() {
    super.initState();
    _getBarangDetail(); // Ambil data saat widget pertama kali dibuka
  }

  // Fungsi untuk mengambil data barang masuk dari Firestore dan relasi ke Kategori
  // Fungsi untuk mengambil data barang masuk dari Firestore dan relasi ke Kategori
  Future<void> _getBarangDetail() async {
    try {
      var barangDoc = await FirebaseFirestore.instance
          .collection('Barang_masuk')
          .doc(widget.barangId)
          .get();

      if (barangDoc.exists) {
        if (barangDoc.data()!.containsKey('kategoriId')) {
          // Dapatkan kategoriId dari dokumen barang_masuk
          String kategoriId = barangDoc['kategoriId'];

          // Ambil dokumen dari koleksi Kategori menggunakan kategoriId
          var kategoriDoc = await FirebaseFirestore.instance
              .collection('Kategori')
              .doc(kategoriId)
              .get();

          setState(() {
            barangData = barangDoc;
            kategoriData = kategoriDoc.exists ? kategoriDoc : null;
          });
        } else {
          // Jika kategoriId tidak ada di dokumen
          print("Field kategoriId tidak ditemukan di dokumen barang.");
          setState(() {
            barangData = barangDoc;
            kategoriData = null; // Tidak ada kategori yang terkait
          });
        }
      } else {
        // Jika dokumen barang tidak ditemukan
        print("Dokumen barang tidak ditemukan!");
        setState(() {
          barangData = null;
        });
      }
    } catch (e) {
      print("Error mengambil data: $e");
      setState(() {
        barangData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightBlue[900],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
        ),
        title: Text(
          barangData?['Nama_Barang'] ??
              'Nama Barang Tidak Tersedia', // Menangani null
          style: const TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            fontSize: 18,
            color: Color(0xffffffff),
          ),
        ),
        leading: TextButton(
          onPressed: () {
            Get.back(); // Kembali ke halaman sebelumnya
          },
          child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              )),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize:
                const Size(35, 35), // Sesuaikan ukuran tombol sesuai kebutuhan
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if (barangData != null && widget.barangId.isNotEmpty) {
                Get.to(Editbarangmasukad(
                  barangId: widget.barangId,
                  jumlahMasuk: barangData!['Jumlah_masuk'].toString(),
                  tanggal: DateFormat('dd-MM-yyyy')
                      .format((barangData!['Tanggal'] as Timestamp).toDate()),
                  catatan: barangData!['Catatan'],
                  namaBarang: barangData![
                      'Nama_Barang'], // Mengambil nama barang dari detail
                ));
              } else {
                print('BarangId atau data barang kosong');
              }
            },
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Icon(
                Icons.edit_square,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: barangData == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Barang (diambil dari koleksi Barang_Keluar)
                  const Text(
                    'Nama Barang',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    barangData![
                        'Nama_Barang'], // Mengambil nama barang dari koleksi Barang_Keluar
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 94, 94, 94),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Jumlah Keluar
                  const Text(
                    'Jumlah Masuk',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    barangData!['Jumlah_masuk'].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 94, 94, 94),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tanggal
                  const Text(
                    'Tanggal',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    DateFormat('dd-MM-yyyy')
                        .format((barangData!['Tanggal'] as Timestamp).toDate()),
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 94, 94, 94),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Catatan
                  const Text(
                    'Catatan',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    barangData!['Catatan'],
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 94, 94, 94),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const Bottomnavad(),
    );
  }
}
