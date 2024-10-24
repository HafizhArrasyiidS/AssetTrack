import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'barangkeluarad.dart';

class Inputbarangkeluarad extends StatefulWidget {
  const Inputbarangkeluarad({super.key});

  @override
  State<Inputbarangkeluarad> createState() => _InputbarangkeluaradState();
}

class _InputbarangkeluaradState extends State<Inputbarangkeluarad> {
  String? selectedItem;
  List<String> kategoriList = []; // Daftar kategori dari Firestore
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _image;
  DateTime selectedDate = DateTime.now();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchKategori(); // Ambil data kategori dari Firestore saat inisialisasi

    // Atur tanggal menjadi waktu sekarang
    selectedDate = DateTime.now(); // Set tanggal saat ini
    tanggalController.text = DateFormat('yyyy-MM-dd')
        .format(selectedDate); // Isi text field dengan tanggal saat ini
  }

  // Fungsi untuk mengambil data kategori dari Firestore
  Future<void> fetchKategori() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Kategori')
          .get(); // Ambil data dari koleksi 'kategori'

      List<String> tempList = [];
      for (var doc in querySnapshot.docs) {
        tempList.add(doc['Nama']); // Simpan field 'nama' ke dalam list
      }

      setState(() {
        kategoriList = tempList;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Ambil referensi dokumen kategori yang dipilih
        var kategoriSnapshot = await FirebaseFirestore.instance
            .collection('Kategori')
            .where('Nama', isEqualTo: selectedItem)
            .limit(1)
            .get();

        if (kategoriSnapshot.docs.isEmpty) {
          // Jika kategori tidak ditemukan
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: const Text(
              'Kategori tidak ditemukan!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
              ),
            ),
          ));
          return;
        }

        // Ambil data kategori
        var kategoriDoc = kategoriSnapshot.docs.first;
        var kategoriId = kategoriDoc.id; // Mengambil ID kategori

        // Validasi apakah field 'Jumlah' ada dalam dokumen kategori
        if (!kategoriDoc.data().containsKey('Jumlah')) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: const Text(
              'Field "Jumlah" tidak ditemukan di kategori!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
              ),
            ),
          ));
          return;
        }

        var jumlahBarangSaatIni = kategoriDoc['Jumlah'];

        // Pastikan jumlahBarangSaatIni adalah integer
        if (jumlahBarangSaatIni is! int) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: const Text(
              'Field "Jumlah" bukan angka yang valid!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
              ),
            ),
          ));
          return;
        }

        // Pastikan input barangKeluar valid
        int barangKeluar;
        try {
          barangKeluar = int.parse(jumlahController.text);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: const Text(
              'Jumlah keluar tidak valid!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
              ),
            ),
          ));
          return;
        }

        // Cek apakah stok barang mencukupi
        if (jumlahBarangSaatIni < barangKeluar) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: const Text(
              'Stok barang tidak mencukupi!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
              ),
            ),
          ));
          return;
        }

        // Tambahkan data barang keluar ke koleksi Barang_Keluar
        await FirebaseFirestore.instance.collection('Barang_Keluar').add({
          'kategoriId': kategoriId, // Menyimpan kategoriId yang sesuai
          'Nama_Barang': selectedItem,
          'Jumlah_keluar': barangKeluar,
          'Tanggal': selectedDate,
          'Catatan': catatanController.text,
        });

        // Perbarui jumlah barang di koleksi Kategori
        await FirebaseFirestore.instance
            .collection('Kategori')
            .doc(kategoriDoc.id)
            .update({
          'Jumlah': jumlahBarangSaatIni - barangKeluar,
        });

        // Data berhasil disimpan
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: const Text(
            'Barang Keluar Berhasil di Tambahkan!!!',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'poppins',
            ),
          ),
        ));
        Get.to(const Barangkeluarad());

        // Kosongkan form
        setState(() {
          selectedItem = null;
          jumlahController.clear();
          tanggalController.clear();
          catatanController.clear();
          _image = null;
        });
      } catch (error) {
        print('Failed to add record: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: const Text(
            'Gagal menyimpan data!',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'poppins',
            ),
          ),
        ));
      }
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
        title: const Text(
          "Input Barang Keluar",
          style: TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            fontSize: 18,
            color: Color(0xffffffff),
          ),
        ),
        leading: TextButton(
          onPressed: () {
            Get.to(const Barangkeluarad());
          },
          child: const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              'Batal', // Ganti dengan teks yang Anda inginkan
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'poppins',
                fontSize: 16, // Sesuaikan ukuran teks sesuai kebutuhan
              ),
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize:
                const Size(35, 35), // Sesuaikan ukuran tombol sesuai kebutuhan
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Text(
                'Tambah',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'poppins',
                  fontSize: 16,
                ),
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(35, 35),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Dropdown untuk kategori barang
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: const Text(
                          "Nama Barang", // Ganti dengan label yang Anda inginkan
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'poppins',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedItem,
                        hint: const Text(
                          "Pilih Nama Barang...",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: 'poppins',
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color.fromARGB(97, 0, 0, 0),
                          ),
                        ),
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedItem = newValue;
                          });
                        },
                        items: kategoriList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: 'poppins',
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12.0),
                          fillColor: const Color(0xffeef1f6),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap pilih barang';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                // Input jumlah barang
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: const Text(
                          "Jumlah Keluar",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'poppins',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      TextFormField(
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: 'poppins',
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                        keyboardType: TextInputType
                            .number, // Menentukan input hanya angka
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter
                              .digitsOnly, // Mengizinkan hanya angka
                        ],
                        controller: jumlahController,
                        decoration: InputDecoration(
                          fillColor: const Color(0xffeef1f6),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                           hintText: "Masukan Jumlah Barang",
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color.fromARGB(97, 0, 0, 0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap isi jumlah keluar';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                // Input tanggal
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: const Text(
                          "Tanggal",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'poppins',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      TextFormField(
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: 'poppins',
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                        controller: tanggalController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          fillColor: const Color(0xffeef1f6),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap pilih tanggal';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                // Input catatan
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: const Text(
                          "Catatan",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'poppins',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      TextFormField(
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: 'poppins',
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                        maxLines: 5,
                        controller: catatanController,
                        decoration: InputDecoration(
                          fillColor: const Color(0xffeef1f6),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0,
                            ),
                          ),
                           hintText: "Masukan Catatan",
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color.fromARGB(97, 0, 0, 0),
                          ),
                        ), 
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
