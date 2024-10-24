import 'dart:convert';

import 'package:assettrack2/AkunLogin/akun_lupa_password.dart';
import 'package:assettrack2/AkunLogin/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AkunResetPass extends StatefulWidget {
  const AkunResetPass({super.key});

  @override
  State<AkunResetPass> createState() => _AkunResetPassState();
}

class _AkunResetPassState extends State<AkunResetPass> {
  List<dynamic> itemsTenant = [];
  String? selectedValueTenant;

  String? tokenJwt = "";

  @override
  void dispose() {
    tokenController.dispose();
    passwordController.dispose();
    conPasswordController.dispose();
    super.dispose();
  }

  final TextEditingController tokenController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController conPasswordController = TextEditingController();
  final passwordVisibility = true.obs;
  final conPasswordVisibility = true.obs;
  final _formKey = GlobalKey<FormState>();

  var isLoading = false.obs;

  void resetPassword() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 3));

    final token = tokenController.text;
    final password = passwordController.text;
    final conPassword = conPasswordController.text;

    final url = Uri.parse(
        'https://inventoryapp-1-v9972795.deta.app/reset-password?token=$token&new_password=$password&konfirmasi_password=$conPassword');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      final respon = json.decode(response.body);
      print('${respon}');
      if (mounted) {
        setState(() {
          Get.off(const AkunLogin());
        });
      }
      Get.defaultDialog(
        title: "Berhasil",
        middleText: "Password berhasil diubah",
        backgroundColor: Colors.lightBlue[900],
        titleStyle: TextStyle(color: Colors.white),
        middleTextStyle: TextStyle(color: Colors.white),
      );
      isLoading.value = false;
    } else if (response.statusCode == 400) {
      isLoading.value = false;
      Get.defaultDialog(
        title: "Gagal",
        middleText: "Sepertinya ada yang salah dengan token dan password yang Anda masukkan",
        backgroundColor: Colors.redAccent,
        titleStyle: TextStyle(color: Colors.white),
        middleTextStyle: TextStyle(color: Colors.white),
      );
    } else {
      isLoading.value = false;

      Get.defaultDialog(
        title: "Gagal",
        middleText:
            "Sepertinya ada yang salah dengan token dan password yang Anda masukkan",
        backgroundColor: Colors.redAccent,
        titleStyle: TextStyle(color: Colors.white),
        middleTextStyle: TextStyle(color: Colors.white),
      );
    }
    void _logout() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('tokenJwt'); // Menghapus token dari SharedPreferences
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe6e6e6),
      body: Stack(
        children: [
          // Background container
          Container(
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.35000000000000003,
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
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    Get.to(
                      AkunLupaPassword(),
                      transition: Transition.leftToRight,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                ),
                SizedBox(width: 8), // Spacing between the icon and the text
                Text(
                  'Reset Password',
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
            height: MediaQuery.of(context).size.height * 0.55,
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
                      Image(
                        image: const AssetImage('assets/images/tanpa.png'),
                        height: 150,
                        width: MediaQuery.of(context).size.width * 1.0,
                        fit: BoxFit.fitWidth,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Masukkan token yang telah dikirim ke alamat email anda",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 12,
                              color: Color(0xff000000),
                            ),
                          ),
                        ),
                      ),
                      TextField(
                        controller: tokenController,
                        obscureText: false,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                        decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0x00000000), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0x00000000), width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                                color: Color(0x00000000), width: 1),
                          ),
                          hintText: "Token",
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: 14,
                            color: Color(0xff494646),
                          ),
                          filled: true,
                          fillColor: const Color(0xffeeeeee),
                          isDense: false,
                          contentPadding:
                              const EdgeInsets.fromLTRB(15, 0, 0, 0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: Obx(
                          () => TextField(
                            controller: passwordController,
                            obscureText: passwordVisibility.value,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            autofillHints: const [AutofillHints.password],
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00ffffff), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00ffffff), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00ffffff), width: 1),
                              ),
                              hintText: "Password",
                              hintStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff494646),
                              ),
                              filled: true,
                              fillColor: const Color(0xffeeeeee),
                              isDense: false,
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
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
                        child: Obx(
                          () => TextField(
                            controller: conPasswordController,
                            obscureText: conPasswordVisibility.value,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            autofillHints: const [AutofillHints.password],
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00ffffff), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00ffffff), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                    color: Color(0x00ffffff), width: 1),
                              ),
                              hintText: "Konfirmasi Password",
                              hintStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff494646),
                              ),
                              filled: true,
                              fillColor: const Color(0xffeeeeee),
                              isDense: false,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(15, 0, 0, 0),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  conPasswordVisibility.value =
                                      !conPasswordVisibility.value;
                                },
                                child: Icon(
                                  conPasswordVisibility.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xff212435),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () => Container(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 3,
                            ),
                            child: Stack(
                              children: [
                                isLoading.value
                                    ? SizedBox(
                                        width: 25,
                                        height: 25,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 4.0,
                                        ),
                                      )
                                    : const Text(
                                        "Simpan",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                              ],
                            ),
                            onPressed: () {
                              resetPassword();
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 15),
                        child: Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              Get.off(
                                const AkunLogin(),
                              );
                            },
                            child: Text(
                              "Login?",
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     mainAxisSize: MainAxisSize.max,
                      //     children: [
                      //       const Padding(
                      //         padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                      //         child: Text(
                      //           "Guru Baru?",
                      //           textAlign: TextAlign.start,
                      //           overflow: TextOverflow.clip,
                      //           style: TextStyle(
                      //             fontWeight: FontWeight.w400,
                      //             fontStyle: FontStyle.normal,
                      //             fontSize: 14,
                      //             color: Color(0xff000000),
                      //           ),
                      //         ),
                      //       ),
                      //       GestureDetector(
                      //         onTap: () {
                      //           Get.to(const AkunDaftar());
                      //         },
                      //         child: Text(
                      //           "Daftar Disini",
                      //           textAlign: TextAlign.start,
                      //           overflow: TextOverflow.clip,
                      //           style: TextStyle(
                      //             fontWeight: FontWeight.w600,
                      //             fontStyle: FontStyle.normal,
                      //             fontSize: 14,
                      //             color: MainColor.primaryColor,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
