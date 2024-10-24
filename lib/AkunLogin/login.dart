import 'package:assettrack2/Admin/Kategori%20Barang/listad.dart';
import 'package:assettrack2/AkunLogin/akun_lupa_password.dart';
import 'package:assettrack2/AkunLogin/masuk.dart';
import 'package:assettrack2/Staff%20Karyawan/Kategori%20Barang/liststaff.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AkunLogin extends StatefulWidget {
  const AkunLogin({super.key});

  @override
  State<AkunLogin> createState() => _AkunLoginState();
}

class _AkunLoginState extends State<AkunLogin> {
  String email = "", password = "";
  String emailError = "", passwordError = ""; // Variabel untuk menyimpan pesan error
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final passwordVisibility = true.obs;
  final _formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  userLogin() async {
  isLoading.value = true; // Mulai loading
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    // Menyimpan email pengguna ke SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'userEmail', userCredential.user!.email!); // Simpan email pengguna

    // Ambil data pengguna dari Firestore
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (userDoc.exists) {
      String role =
          userDoc.data()?['role'] ?? 'Staff'; // Ambil role, default 'Staff'
      String nama = userDoc.data()?['nama'] ??
          userCredential
              .user!.email!; // Ambil nama atau email jika nama tidak ada

      // Menyimpan nama pengguna ke SharedPreferences
      await prefs.setString('userName', nama); // Simpan nama pengguna
      await prefs.setString('userRole', role); // Simpan role pengguna

      // Navigasi ke halaman berdasarkan role
      if (role == 'Admin') {
        Get.to(() => Listad(), transition: Transition.fadeIn);
      } else if (role == 'Staff') {
        Get.to(() => Liststaff(), transition: Transition.fadeIn);
      } else {
        showSnackbar('Role tidak dikenali', Colors.red);
      }
    } else {
      showSnackbar('Data pengguna tidak ditemukan', Colors.red);
    }
  } on FirebaseAuthException catch (e) {
    // Jika user tidak ditemukan atau password salah, tampilkan pesan validasi yang sama
    if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      showSnackbar('Email atau password anda salah', Colors.red);
    } else {
      showSnackbar('Error: ${e.message}', Colors.red);
    }
  } catch (e) {
    showSnackbar('Terjadi kesalahan: ${e.toString()}', Colors.red);
  } finally {
    isLoading.value = false; // Selesai loading
  }
}


  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          message,
          style: const TextStyle(fontSize: 16.0),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe6e6e6),
      body: Stack(children: [
        Container(
          margin: const EdgeInsets.all(0),
          padding: const EdgeInsets.all(0),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: BoxDecoration(
            color: Colors.lightBlue[900],
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)),
            border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
          ),
        ),
        Positioned(
          top: 40,
          left: 10,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  Get.to(() => Masuk(),
                      transition: Transition.leftToRight,
                      duration: const Duration(milliseconds: 300));
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Masuk',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(40, 150, 35, 20),
          padding: const EdgeInsets.all(0),
          width: MediaQuery.of(context).size.width * 0.83,
          height: MediaQuery.of(context).size.height * 0.51,
          decoration: BoxDecoration(
            color: const Color(0xffffffff),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Image(
                      image: AssetImage('assets/images/text.png'),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email harus diisi';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Masukkan email yang valid';
                          }
                          return null;
                        },
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(
                            fontFamily: 'poppins',
                          ),
                          filled: true,
                          fillColor: const Color(0xffeef1f6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          errorText: emailError.isEmpty ? null : emailError, // Menampilkan pesan error
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Obx(
                        () => TextFormField(
                          controller: passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password harus diisi';
                            }
                            return null;
                          },
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff000000),
                          ),
                          obscureText: passwordVisibility.value,
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(
                              fontFamily: 'poppins',
                            ),
                            filled: true,
                            fillColor: const Color(0xffeef1f6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(15, 0, 0, 0),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                passwordVisibility.value =
                                    !passwordVisibility.value;
                              },
                              child: Icon(
                                passwordVisibility.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xff212435),
                                size: 24,
                              ),
                            ),
                            errorText: passwordError.isEmpty ? null : passwordError, // Menampilkan pesan error
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 15),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => const AkunLupaPassword(),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 300));
                          },
                          child: Text(
                            "Lupa Password?",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'poppins',
                              fontSize: 14,
                              color: Colors.lightBlue[900],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: isLoading.value
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontFamily: 'poppins'),
                                ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                email = emailController.text;
                                password = passwordController.text;
                              });
                              userLogin();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

