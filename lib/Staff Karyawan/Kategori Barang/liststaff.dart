import 'package:assettrack2/Staff%20Karyawan/Kategori%20Barang/editbarang.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:assettrack2/Staff%20Karyawan/bar/drawerstaff.dart';
import 'package:assettrack2/Staff%20Karyawan/bar/bottomnavstaff.dart';
import 'package:assettrack2/Staff%20Karyawan/Kategori%20Barang/itembarustaff.dart';

class Liststaff extends StatefulWidget {
  const Liststaff({super.key});

  @override
  State<Liststaff> createState() => _ListstaffState();
}

class _ListstaffState extends State<Liststaff> {
  final TextEditingController searchController = TextEditingController();

  // Fungsi untuk fetch data dengan pencarian berdasarkan Nama
  Stream<QuerySnapshot> fetchDataKategori(String query) {
    if (query.isEmpty) {
      return FirebaseFirestore.instance.collection('Kategori').snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('Kategori')
          .where('Nama', isGreaterThanOrEqualTo: query)
          .where('Nama', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
        ),
        title: const Text(
          "Kategori Barang",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'poppins',
            fontSize: 20,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: GestureDetector(
              onTap: () {
                Get.to(const Itembarustaff(
                  kategoriId: '',
                  fotoUrl: null,
                  nama: null,
                  jumlah: null,
                  catatan: null,
                ));
              },
              child: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 24,
              ),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
      ),
      drawer: const Drawer(
        width: 278,
        backgroundColor: Colors.white,
        child: Drawerstaff(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextField(
                controller: searchController,
                obscureText: false,
                textAlign: TextAlign.start,
                maxLines: 1,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  setState(() {});
                },
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'poppins',
                  fontSize: 14,
                  color: Color(0xff000000),
                ),
                decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide:
                        const BorderSide(color: Color(0xffa09797), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide:
                        const BorderSide(color: Color(0xffa09797), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide:
                        const BorderSide(color: Color(0xffa09797), width: 1),
                  ),
                  hintText: "Pencarian...",
                  hintStyle: const TextStyle(
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xffacb1c6),
                  ),
                  filled: true,
                  fillColor: const Color(0xfff1f4f8),
                  isDense: false,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, size: 24),
                    onPressed: () {
                      setState(() {});
                    },
                    color: const Color(0xffafb4c9),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: fetchDataKategori(searchController.text),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No data found"));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 2 / 3,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var document = snapshot.data!.docs[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(EditKategori(
                            kategoriId: document.id,
                            fotoUrl: document['Foto'],
                            nama: document['Nama'],
                            jumlah: document['Jumlah'].toString(),
                            catatan: document['Catatan'],
                          ));
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  image: DecorationImage(
                                    image: NetworkImage(document['Foto']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              document['Nama'],
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Bottomnavstaff(),
    );
  }
}
