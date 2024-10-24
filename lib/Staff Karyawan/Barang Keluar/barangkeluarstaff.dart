import 'package:assettrack2/Staff%20Karyawan/Barang%20Keluar/detailbarangkeluarstaff.dart';
import 'package:assettrack2/Staff%20Karyawan/Barang%20Keluar/inputbarangkeluarstaff.dart';
import 'package:assettrack2/Staff%20Karyawan/bar/bottomnavstaff.dart';
import 'package:assettrack2/Staff%20Karyawan/bar/drawerstaff.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Barangkeluarstaff extends StatefulWidget {
  const Barangkeluarstaff({super.key});

  @override
  State<Barangkeluarstaff> createState() => _BarangkeluarstaffState();
}

class _BarangkeluarstaffState extends State<Barangkeluarstaff> {
  final CollectionReference barangKeluarRef =
      FirebaseFirestore.instance.collection('Barang_Keluar');

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<DocumentSnapshot> _barangKeluarList = [];

  String searchQuery = '';
  String selectedFilter = 'Semua'; // Filter yang dipilih

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data initially
  }

  Future<void> _fetchData() async {
    _barangKeluarList.clear(); // Reset the list before fetching new data

    Query query = barangKeluarRef
        .orderBy('Nama_Barang'); // Urutkan berdasarkan Nama_Barang

    // Menentukan rentang waktu berdasarkan filter yang dipilih
    DateTime now = DateTime.now();
    if (selectedFilter == 'Per Hari') {
      query = query.where('Tanggal',
          isGreaterThanOrEqualTo: DateTime(now.year, now.month, now.day));
    } else if (selectedFilter == 'Per Minggu') {
      DateTime startOfWeek =
          now.subtract(Duration(days: now.weekday - 1)); // Mulai minggu
      query = query.where('Tanggal', isGreaterThanOrEqualTo: startOfWeek);
    } else if (selectedFilter == 'Per Bulan') {
      query = query.where('Tanggal',
          isGreaterThanOrEqualTo: DateTime(now.year, now.month, 1));
    }

    query.snapshots().listen((snapshot) {
      if (mounted) {
        setState(() {
          _barangKeluarList
              .clear(); // Clear the list before inserting new items
        });
      }

      for (int i = 0; i < snapshot.docs.length; i++) {
        Future.delayed(Duration(milliseconds: 100 * i), () {
          if (mounted) {
            setState(() {
              _barangKeluarList.insert(i, snapshot.docs[i]);
              _listKey.currentState?.insertItem(i);
            });
          }
        });
      }
    });
  }

  void _searchData(String query) {
    setState(() {
      searchQuery = query.toLowerCase(); // Update search query
    });

    // Fetch the data again based on the search query
    barangKeluarRef.orderBy('Nama_Barang').snapshots().listen((snapshot) {
      var results = snapshot.docs.where((doc) {
        String namaBarang = doc['Nama_Barang'].toString().toLowerCase();
        return namaBarang.contains(searchQuery);
      }).toList();

      setState(() {
        _barangKeluarList.clear();
        _barangKeluarList.addAll(results);
      });

      for (int i = 0; i < results.length; i++) {
        Future.delayed(Duration(milliseconds: 100 * i), () {
          if (mounted) {
            setState(() {
              _listKey.currentState?.insertItem(i);
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xffffffff),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
        ),
        title: const Text(
          "Transaksi Barang Keluar",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'poppins',
            fontSize: 20,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.filter_alt_rounded,
                color: Colors.black,
              ),
              onSelected: (newFilter) {
                setState(() {
                  selectedFilter = newFilter;
                  _fetchData(); // Update data saat filter berubah
                });
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'Per Hari',
                  child: Text(
                    'Per Hari',
                    style: const TextStyle(fontFamily: 'poppins'),
                  ),
                ),
                PopupMenuItem(
                  value: 'Per Minggu',
                  child: Text(
                    'Per Minggu',
                    style: const TextStyle(fontFamily: 'poppins'),
                  ),
                ),
                PopupMenuItem(
                  value: 'Per Bulan',
                  child: Text(
                    'Per Bulan',
                    style: const TextStyle(fontFamily: 'poppins'),
                  ),
                ),
                PopupMenuItem(
                  value: 'Semua',
                  child: Text(
                    'Semua',
                    style: const TextStyle(fontFamily: 'poppins'),
                  ),
                ),
              ],
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
                obscureText: false,
                textAlign: TextAlign.start,
                maxLines: 1,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  _searchData(value); // Call the search function when submitted
                },
                onChanged: (value) {
                  _searchData(value); // Call the search function on text change
                },
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  fontFamily: 'poppins',
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
                    icon: const Icon(
                      Icons.search,
                      size: 24,
                    ),
                    onPressed: () {}, // Search button action
                    color: const Color(0xffafb4c9),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _barangKeluarList.length,
                itemBuilder: (context, index, animation) {
                  if (index >= _barangKeluarList.length) {
                    return Container(); // Return empty container if the index is out of bounds
                  }

                  var docData =
                      _barangKeluarList[index].data() as Map<String, dynamic>;
                  final String namaBarang =
                      docData['Nama_Barang'] ?? 'Tidak Diketahui';
                  final int jumlahKeluar =
                      docData['Jumlah_keluar'] as int? ?? 0;

                  String currentInitial =
                      namaBarang.isNotEmpty ? namaBarang[0].toUpperCase() : '';

                  // Menampilkan header hanya jika inisial berubah
                  bool showHeader = index == 0 ||
                      currentInitial !=
                          (docData['Nama_Barang'] as String)[0].toUpperCase();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == 0 ||
                          (currentInitial !=
                              (_barangKeluarList[index - 1].data()
                                      as Map<String, dynamic>)['Nama_Barang'][0]
                                  .toUpperCase()))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            currentInitial,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      SizeTransition(
                        sizeFactor: Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: Card(
                          color: const Color(0xffeef1f6),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                namaBarang.isNotEmpty ? namaBarang[0] : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(namaBarang),
                            subtitle: Text('Jumlah Keluar: $jumlahKeluar'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Get.to(Detailbarangkeluarstaff(
                                  barangId: _barangKeluarList[index].id));
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(Inputbarangkeluarstaff());
        },
        hoverElevation: 40,
        hoverColor: Colors.blue.shade700,
        backgroundColor: Colors.blue.shade900,
        child: const Icon(
          Icons.add,
          size: 24,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: const Bottomnavstaff(),
    );
  }
}
