import 'dart:io';
import 'package:assettrack2/Staff%20Karyawan/Kategori%20Barang/liststaff.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditKategori extends StatefulWidget {
  final String kategoriId;
  final String fotoUrl;
  final String nama;
  final String jumlah;
  final String catatan;

  const EditKategori({
    super.key,
    required this.kategoriId,
    required this.fotoUrl,
    required this.nama,
    required this.catatan,
    required this.jumlah,
  });

  @override
  State<EditKategori> createState() => _EditKategoriState();
}

class _EditKategoriState extends State<EditKategori> {
  TextEditingController namaController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  int totalBarangMasuk = 0;
  int totalBarangKeluar = 0;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isImageUpdated = false;

  Future<void> _calculateTotalBarang() async {
    try {
      final barangMasukSnapshot = await FirebaseFirestore.instance
          .collection('Barang_masuk')
          .where('Nama_Barang', isEqualTo: widget.nama)
          .get();

      int totalMasuk = 0;
      for (var doc in barangMasukSnapshot.docs) {
        totalMasuk += (doc['Jumlah_masuk'] as num).toInt();
      }

      final barangKeluarSnapshot = await FirebaseFirestore.instance
          .collection('Barang_Keluar')
          .where('Nama_Barang', isEqualTo: widget.nama)
          .get();

      int totalKeluar = 0;
      for (var doc in barangKeluarSnapshot.docs) {
        totalKeluar += (doc['Jumlah_keluar'] as num).toInt();
      }

      setState(() {
        totalBarangMasuk = totalMasuk;
        totalBarangKeluar = totalKeluar;
      });
    } catch (e) {
      print("Error calculating totals: $e");
    }
  }

  Future<void> _deleteKategori(String kategoriId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Kategori')
          .doc(widget.kategoriId)
          .delete();

      if (isImageUpdated && widget.fotoUrl.isNotEmpty) {
        FirebaseStorage.instance.refFromURL(widget.fotoUrl).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: const Text(
            'Barang telah dihapus',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'poppins',
            ),
          ),
        ),
      );
      Get.to(Liststaff());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: const Text(
            'Gagal menghapus kategori',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'poppins',
            ),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.nama);
    jumlahController = TextEditingController(text: widget.jumlah);
    catatanController = TextEditingController(text: widget.catatan);

    _calculateTotalBarang();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        isImageUpdated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
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
          namaController.text,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xffffffff),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Color(0xffffffff),
            size: 24,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Get.defaultDialog(
                  title: 'Hapus Kategori',
                  titleStyle: TextStyle(
                      fontFamily: 'poppins', fontWeight: FontWeight.w500),
                  middleText: 'Apakah Anda yakin ingin menghapus ini?',
                  middleTextStyle: TextStyle(
                    fontFamily: 'poppins',
                  ),
                  textConfirm: 'Hapus',
                  textCancel: 'Batal',
                  confirmTextColor: Colors.white,
                  cancelTextColor: Colors.black,
                  buttonColor: Colors.lightBlue[900],
                  onConfirm: () {
                    _deleteKategori(widget.kategoriId);
                  },
                );
              },
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 24,
              ),
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
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: screenWidth * 0.9, // Responsif sesuai lebar layar
                  height: screenWidth * 0.5, // Tinggi juga proporsional
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: _image != null
                          ? FileImage(_image!)
                          : NetworkImage(widget.fotoUrl) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[900],
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.3,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Keterangan",
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Text(
                  catatanController.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontFamily: 'poppins',
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[900],
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.25,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Informasi Barang",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                // Membungkus keseluruhan kolom dengan Center agar benar-benar berada di tengah layar
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Mengatur konten di tengah secara vertikal
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // Mengatur konten di tengah secara horizontal
                  children: [
                    // Total Barang Masuk
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0), // Jarak antar elemen
                      child: Column(
                        children: [
                          const Text(
                            'Total Barang Masuk',
                            style: TextStyle(
                              fontSize: 16, // Ukuran teks yang lebih jelas
                              color: Colors.black,
                              fontFamily: 'poppins',
                            ),
                            textAlign:
                                TextAlign.center, // Memastikan teks di tengah
                          ),
                          Text(
                            totalBarangMasuk.toString(),
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight
                                  .bold, // Membuat total lebih menonjol
                              fontSize: 18, // Ukuran teks yang lebih besar
                              color: Colors.grey[800], // Warna agar terlihat berbeda
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Column(
                        children: [
                          const Text(
                            'Total Barang Keluar',
                            style: TextStyle(
                              fontSize: 16, // Ukuran teks yang lebih jelas
                              color: Colors.black,
                              fontFamily: 'poppins',
                            ),
                            textAlign:
                                TextAlign.center, // Memastikan teks di tengah
                          ),
                          Text(
                            totalBarangKeluar.toString(),
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight
                                  .bold, // Membuat total lebih menonjol
                              fontSize: 18, // Ukuran teks yang lebih besar
                              color: Colors.grey[800], // Warna agar terlihat berbeda
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[900],
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth *
                          0.19, // Mengurangi padding agar lebih fleksibel
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: [
                      FittedBox(
                        // Gunakan FittedBox agar teks tidak keluar dari area
                        fit: BoxFit
                            .scaleDown, // Pastikan teks bisa diskalakan sesuai ukuran ruang
                        child: Text(
                          jumlahController.text,
                          style: TextStyle(
                            fontSize: screenWidth *
                                0.06, // Ukuran teks berdasarkan lebar layar
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontFamily: 'poppins',
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Stok Yang Tersedia",
                          style: TextStyle(
                            fontSize: screenWidth *
                                0.05, // Ukuran teks lebih proporsional
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: 'poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
