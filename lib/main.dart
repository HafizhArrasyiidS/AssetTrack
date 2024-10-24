import 'package:assettrack2/AkunLogin/splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAs_Egu849wk0aaFSFFjWEs9yBYRVtpTxs",
          appId: "1:869708616173:android:b7974a7b481349cced97e4",
          messagingSenderId: "869708616173",
          projectId: "inventoryapp-e32cb",
          storageBucket: "inventoryapp-e32cb.appspot.com"),
    );
  } catch (errorMsg) {
    print("Error:: " + errorMsg.toString());
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Application',
      debugShowCheckedModeBanner: false,
      home: AppSplash(),
    );
  } 
}
