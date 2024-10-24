import 'package:assettrack2/AkunLogin/akun_reset_pass.dart';
import 'package:assettrack2/AkunLogin/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AkunLupaPassword extends StatefulWidget {
  const AkunLupaPassword({super.key});

  @override
  State<AkunLupaPassword> createState() => _AkunLupaPasswordState();
}

class _AkunLupaPasswordState extends State<AkunLupaPassword> {
  final TextEditingController emailCon = TextEditingController();
  var isLoading = false.obs;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailCon.dispose();
    super.dispose();
  }

  Future<void> sentEmail() async {
    if (_formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailCon.text);
        if (mounted) {
          setState(() {
            Get.off(const AkunLogin());
          });
        }
        Get.defaultDialog(
          title: "Berhasil",
          middleText: "Cek email anda untuk melakukan reset password",
          backgroundColor: Colors.green,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
          middleTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        );
      } catch (e) {
        Get.defaultDialog(
          title: "Gagal",
          middleText: "Terjadi kesalahan: $e",
          backgroundColor: Colors.redAccent,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
          middleTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        );
      } finally {
        isLoading.value = false;
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe6e6e6),
      body: Stack(children: [
        // Background container
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: BoxDecoration(
            color: Colors.lightBlue[900],
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
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
                  Get.to(
                    const AkunLogin(),
                    transition: Transition.leftToRight,
                    duration: const Duration(milliseconds: 300),
                  );
                },
              ),
              const SizedBox(width: 8), // Spacing between the icon and the text
              const Text(
                'Lupa Password',
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
          width: MediaQuery.of(context).size.width * 0.83,
          height: MediaQuery.of(context).size.height * 0.45,
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
                    Image.asset('assets/images/text.png',
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fitWidth),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Text(
                        "Sistem akan mengirimkan link pada email anda",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff000000),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: TextFormField(
                        controller: emailCon,
                        keyboardType: TextInputType.emailAddress,
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return 'Masukkan email yang valid';
                          }
                          return null;
                        },
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
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Reset",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                          onPressed: sentEmail,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 15),
                      child: GestureDetector(
                        onTap: () {
                          Get.off(const AkunLogin());
                        },
                        child: const Text(
                          "Login?",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white,
                          ),
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
