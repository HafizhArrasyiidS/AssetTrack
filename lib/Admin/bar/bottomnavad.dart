import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Kategori Barang/listad.dart';
import '../Barang Masuk/barangmasukad.dart';
import '../Barang Keluar/barangkeluarad.dart';

class Bottomnavad extends StatefulWidget {
  const Bottomnavad({super.key});

  @override
  State<Bottomnavad> createState() => _BottomnavadState();
}

class _BottomnavadState extends State<Bottomnavad> {
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
                Get.to(const Listad(),
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
                Get.to(Barangmasukad(),
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
               Get.to(Barangkeluarad(),
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
