import 'package:assettrack2/AkunLogin/daftar.dart';
import 'package:assettrack2/AkunLogin/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Masuk extends StatefulWidget {
  const Masuk({super.key});

  @override
  State<Masuk> createState() => _MasukState();
}

class _MasukState extends State<Masuk> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe6e6e6),
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 210),
            child: Container(
              margin: const EdgeInsets.all(0),
              padding: const EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.lightBlue[900],
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40.0),
                  bottomRight: Radius.circular(40.0),
                ),
                border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
              ),
              child: const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Image(
                    image: AssetImage("assets/images/putih.png"),
                    height: 450,
                    width: 450,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Mengatur tombol di tengah
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.to(
                      AkunLogin(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Mengatur radius ke 15
                    ),
                    backgroundColor: Colors.lightBlue[900], // Warna latar belakang
                    minimumSize: const Size(200, 40), // Ukuran minimum tombol (lebar 200, tinggi 40)
                    padding: const EdgeInsets.symmetric(horizontal: 20), // Padding horizontal
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(
                        fontSize: 14, color: Colors.white, fontFamily: 'poppins'), // Ukuran teks
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(vertical: 10),
                //   child: const Center(
                //     child: Text(
                //       'Atau',
                //       style: TextStyle(fontSize: 12, fontFamily: 'poppins'),
                //     ),
                //   ),
                // ),
                // ElevatedButton(
                //   onPressed: () {
                //     Get.to(
                //       Daftar(),
                //       transition: Transition.rightToLeft,
                //       duration: const Duration(milliseconds: 300),
                //     );
                //   },
                //   style: ElevatedButton.styleFrom(
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(15), // Mengatur radius ke 15
                //     ),
                //     backgroundColor: Color(0xFFBBDEFB), // Warna latar belakang
                //     minimumSize: const Size(200, 40), // Ukuran minimum tombol (lebar 200, tinggi 40)
                //     padding: const EdgeInsets.symmetric(horizontal: 20), // Padding horizontal
                //   ),
                //   child: const Text(
                //     'Daftar',
                //     style: TextStyle(
                //         fontSize: 14, color: Colors.black, fontFamily: 'poppins'), // Ukuran teks
                //   ),
                // ),
                const SizedBox(height: 40), // Spacer between buttons and text
              ],
            ),
          ),
        ],
      ),
    );
  }
}
