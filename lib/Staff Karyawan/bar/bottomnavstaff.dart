import 'package:assettrack2/Staff%20Karyawan/Barang%20Keluar/barangkeluarstaff.dart';
import 'package:assettrack2/Staff%20Karyawan/Barang%20Masuk/barangmasukstaff.dart';
import 'package:assettrack2/Staff%20Karyawan/Kategori%20Barang/liststaff.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Bottomnavstaff extends StatefulWidget {
  const Bottomnavstaff({super.key});

  @override
  State<Bottomnavstaff> createState() => _BottomnavstaffState();
}

class _BottomnavstaffState extends State<Bottomnavstaff> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Container(
        height: 60.0, // Increased height to provide enough space
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Get.to(const Liststaff(),
                transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 300),
                ); // Your navigation logic here
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.edit_document,
                    color: Colors.black,
                    size: 25,
                  ),
                  Text(
                    'Kategori Barang',
                    style: TextStyle(color: Colors.black, fontFamily: 'poppins', fontSize: 10),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(Barangmasukstaff(),
                transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 300),
                );// Add your navigation logic here
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.house,
                    color: Colors.black,
                    size: 25,
                  ),
                  Text(
                    'Barang Masuk',
                    style: TextStyle(color: Colors.black, fontFamily: 'poppins', fontSize: 10),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
               Get.to(Barangkeluarstaff(),
               transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 300),
               ); // Add your navigation logic here
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.payment, // Changed icon for demonstration
                    color: Colors.black,
                    size: 25,
                  ),
                  Text(
                    'Barang Keluar',
                    style: TextStyle(color: Colors.black, fontFamily: 'poppins', fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
