import 'package:assettrack2/Admin/Staff/daftarstaff.dart';
import 'package:assettrack2/Admin/diagramad.dart';
import 'package:assettrack2/Admin/profile.dart';
import 'package:assettrack2/AkunLogin/masuk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Drawerad extends StatefulWidget {
  const Drawerad({super.key});

  @override
  State<Drawerad> createState() => _DraweradState();
}

class _DraweradState extends State<Drawerad> {
  String userName = ""; // Ubah menjadi userName
  String userRole = "";

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  void _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ??
          'Nama tidak ditemukan'; // Load nama pengguna
      userRole = prefs.getString('userRole') ?? 'Role tidak ditemukan';
    });
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('tokenJwt'); // Menghapus token dari preference/local storage
    Get.to(const Masuk());
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Keluar',
            style: TextStyle(
              color: Color.fromARGB(255, 74, 74, 74),
              fontWeight: FontWeight.w500,
              fontFamily: 'poppins',
              fontSize: 12,
            ),
          ),
          content: const Text('Yakin ingin keluar dari aplikasi?',
              style: TextStyle(fontFamily: 'poppins')),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child:
                  const Text('Tidak', style: TextStyle(fontFamily: 'poppins')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logout(); // Perform logout action
              },
              child: const Text('Ya', style: TextStyle(fontFamily: 'poppins')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(Profilead(),
                    transition: Transition.leftToRight,
                    duration: const Duration(milliseconds: 300),
                  );
                },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        right: 10), // Tambahkan jarak antara ikon dan teks
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade400,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                  ),
                  Text(
                    '$userName ($userRole)', // Tampilkan nama pengguna
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'poppins',
                      fontSize: 14,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  
                ],
              ),
              ),
              const Divider(
                color: Color(0xFFC6C6C6),
                thickness: 2,
              ),
              GestureDetector(
                onTap: () {
                  Get.to(
                    Diagramad(),
                    transition: Transition.leftToRight,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                child: const SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.area_chart_rounded,
                        color: Color.fromARGB(255, 74, 74, 74),
                        size: 22,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Grafik Barang Masuk & Keluar',
                          style: TextStyle(
                              color: Color.fromARGB(255, 74, 74, 74),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'poppins',
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(
                    Daftarstaff(),
                    transition: Transition.leftToRight,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                child: const SizedBox(
                  height: 30,
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.groups_sharp,
                        color: Color.fromARGB(255, 74, 74, 74),
                        size: 22,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Daftar Staff/Karyawan',
                          style: TextStyle(
                              color: Color.fromARGB(255, 74, 74, 74),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'poppins',
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showLogoutDialog,
                child: const SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Color.fromARGB(255, 74, 74, 74),
                        size: 22,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Keluar',
                          style: TextStyle(
                              color: Color.fromARGB(255, 74, 74, 74),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'poppins',
                              fontSize: 12),
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
