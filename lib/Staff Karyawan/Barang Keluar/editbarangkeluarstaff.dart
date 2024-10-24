import 'package:assettrack2/Admin/Barang%20Keluar/barangkeluarad.dart';
import 'package:assettrack2/Staff%20Karyawan/Barang%20Keluar/barangkeluarstaff.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Editbarangkeluarstaff extends StatefulWidget {
  final String barangId;
  final String jumlahMasuk;
  final String tanggal;
  final String catatan;
  final String namaBarang; // Menambahkan parameter untuk nama barang

  const Editbarangkeluarstaff({
    Key? key,
    required this.barangId,
    required this.jumlahMasuk,
    required this.tanggal,
    required this.catatan,
    required this.namaBarang, // Menambahkan parameter untuk nama barang
  }) : super(key: key);

  @override
  State<Editbarangkeluarstaff> createState() => _EditbarangkeluarstaffState();
}

class _EditbarangkeluarstaffState extends State<Editbarangkeluarstaff> {
  late TextEditingController _jumlahMasukController;
  late TextEditingController _tanggalController;
  late TextEditingController _catatanController;
  String? _selectedBarang; // Menyimpan barang yang dipilih
  List<String> _barangList = []; // Menyimpan daftar barang
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _jumlahMasukController = TextEditingController(text: widget.jumlahMasuk);
    _tanggalController = TextEditingController(text: widget.tanggal);
    _catatanController = TextEditingController(text: widget.catatan);
    _fetchBarangList(); // Ambil data barang dari koleksi Kategori
    _selectedBarang = widget.namaBarang; // Set nilai nama barang dari detail

    selectedDate = DateTime.now();
  }

  Future<void> _fetchBarangList() async {
    try {
      var kategoriCollection =
          await FirebaseFirestore.instance.collection('Kategori').get();

      // Ambil Nama dari setiap dokumen di koleksi Kategori
      List<String> barangNames =
          kategoriCollection.docs.map((doc) => doc['Nama'] as String).toList();

      setState(() {
        _barangList = barangNames; // Set daftar barang
        // _selectedBarang sudah di-set di initState
      });
    } catch (e) {
      print('Error fetching barang list: $e');
      Get.snackbar('Error', 'Gagal mengambil data barang');
    }
  }

  Future<void> _updateBarang() async {
    try {
      // Ambil data barang masuk sebelumnya
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Barang_Keluar')
          .doc(widget.barangId)
          .get();
      int previousJumlahMasuk = docSnapshot['Jumlah_keluar'];

      // Hitung selisih jumlah masuk lama dan baru
      int newJumlahMasuk = int.parse(_jumlahMasukController.text);
      int difference = newJumlahMasuk - previousJumlahMasuk;

      // Update barang masuk
      await FirebaseFirestore.instance
          .collection('Barang_Keluar')
          .doc(widget.barangId)
          .update({
        'Nama_Barang': _selectedBarang,
        'Jumlah_keluar': newJumlahMasuk,
        'Tanggal': DateFormat('dd-MM-yyyy').parse(_tanggalController.text),
        'Catatan': _catatanController.text,
      });

      // Ambil data barang di koleksi Kategori berdasarkan nama barang
      QuerySnapshot kategoriSnapshot = await FirebaseFirestore.instance
          .collection('Kategori')
          .where('Nama', isEqualTo: _selectedBarang)
          .get();

      if (kategoriSnapshot.docs.isNotEmpty) {
        DocumentSnapshot kategoriDoc = kategoriSnapshot.docs.first;
        int currentJumlahBarang = kategoriDoc['Jumlah'];

        // Update jumlah barang di Kategori berdasarkan selisih
        await FirebaseFirestore.instance
            .collection('Kategori')
            .doc(kategoriDoc.id)
            .update({
          'Jumlah': currentJumlahBarang + difference,
        });
      }

      Get.to(Barangkeluarstaff()); // Kembali setelah update berhasil
      Get.snackbar('Sukses', 'Data barang berhasil diperbarui');
    } catch (e) {
      print('Error updating data: $e');
      Get.snackbar('Error', 'Gagal memperbarui data barang');
    }
  }

  Future<void> _deleteBarang() async {
    try {
      await FirebaseFirestore.instance
          .collection('Barang_Keluar')
          .doc(widget.barangId)
          .delete();

      Get.to(Barangkeluarstaff()); // Kembali setelah penghapusan berhasil
      Get.snackbar('Sukses', 'Data barang berhasil dihapus');
    } catch (e) {
      print('Error deleting data: $e');
      Get.snackbar('Error', 'Gagal menghapus data barang');
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
        _tanggalController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Edit Item',
          style: const TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            fontSize: 20,
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
            onTap: () {},
            child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: TextButton(
                  onPressed: _updateBarang,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Text(
                      'Selesai',
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
                )),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
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
                      //         value: _selectedBarang,
                      // items: _barangList.map((String barang) {
                      //   return DropdownMenuItem<String>(
                      //     value: barang,
                      //     child: Text(barang),
                      //   );
                      // }).toList(),
                      // onChanged: (String? newValue) {
                      //   setState(() {
                      //     _selectedBarang = newValue;
                      //   });
                      // },
                      DropdownButtonFormField<String>(
                        value: _selectedBarang,
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
                            _selectedBarang = newValue;
                          });
                        },
                        items: _barangList
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
                        controller: _jumlahMasukController,
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
                            return 'Harap isi jumlah masuk';
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
                        controller: _tanggalController,
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
                        controller: _catatanController,
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: SizedBox(
                          // Menggunakan SizedBox untuk mengatur lebar tombol
                          width: double
                              .infinity, // Memungkinkan tombol mengisi lebar yang tersedia
                          child: TextButton(
                            onPressed: _deleteBarang,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red, // Teks warna putih
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Hapus Item',
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center, // Memusatkan teks
                            ),
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
