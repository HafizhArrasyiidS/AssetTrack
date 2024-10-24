import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseMethod {
  Future addKategori(Map<String, dynamic> kategoriInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('Kategori')
        .doc(id)
        .set(kategoriInfoMap);
  }

  Future addBarangMasuk(Map<String, dynamic> barangMasukInfo) async {
    return await FirebaseFirestore.instance
        .collection('BarangMasuk')
        .add(barangMasukInfo); // Menggunakan .add agar ID otomatis di-generate
  }

  Future updateJumlahBarang(String kategoriId, int jumlahBaru) async {
    return await FirebaseFirestore.instance
        .collection('Kategori')
        .doc(kategoriId)
        .update({'jumlah_barang': jumlahBaru});
  }

  Future addBarangKeluar(Map<String, dynamic> barangKeluarInfo) async {
    return await FirebaseFirestore.instance
        .collection('BarangKeluar')
        .add(barangKeluarInfo); // Menggunakan .add agar ID otomatis di-generate
  }

  Future updateJumlahBarang2(String kategoriId, int jumlahBaru) async {
    return await FirebaseFirestore.instance
        .collection('Kategori')
        .doc(kategoriId)
        .update({'jumlah_barang': jumlahBaru});
  }
}
