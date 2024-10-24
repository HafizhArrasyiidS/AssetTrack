import 'package:assettrack2/Admin/Kategori%20Barang/listad.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'tambahstaff.dart';

class Daftarstaff extends StatefulWidget {
  const Daftarstaff({super.key});

  @override
  State<Daftarstaff> createState() => _DaftarstaffState();
}

class _DaftarstaffState extends State<Daftarstaff> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<DocumentSnapshot> _staffList = [];
  List<DocumentSnapshot> _filteredStaffList = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch data from Firestore and insert into AnimatedList
  Future<void> _fetchData() async {
    _firestore
        .collection('users')
        .where('role', isEqualTo: 'Staff')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _staffList = snapshot.docs;
        _filteredStaffList = snapshot.docs; // Initialize filtered list
      });
      // Insert all items into the AnimatedList
      for (int i = 0; i < snapshot.docs.length; i++) {
        Future.delayed(Duration(milliseconds: 100 * i), () {
          if (mounted) {
            _listKey.currentState?.insertItem(i);
          }
        });
      }
    });
  }

  // Function to delete staff data
  Future<void> _deleteStaff(DocumentSnapshot staffDoc, int index) async {
    try {
      await _firestore.collection('users').doc(staffDoc.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Staff berhasil dihapus!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Remove item from the list with animation
      setState(() {
        // Find the index of the item in the original list
        int originalIndex = _staffList.indexOf(staffDoc);
        if (originalIndex >= 0) {
          _staffList.removeAt(originalIndex);
          _filteredStaffList.removeAt(index);
          _listKey.currentState?.removeItem(
            index,
            (context, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0),
                end: const Offset(-1, 0),
              ).animate(animation),
              child: Card(
                elevation: 3,
                margin:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    (staffDoc.data() as Map<String, dynamic>)['nama'] ??
                        'Nama tidak tersedia',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'poppins',
                      fontSize: 16.0,
                    ),
                  ),
                  subtitle: Text(
                    (staffDoc.data() as Map<String, dynamic>)['email'] ??
                        'Email tidak tersedia',
                    style: TextStyle(fontFamily: 'poppins'),
                  ),
                ),
              ),
            ),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Gagal menghapus staff!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Function to filter staff based on search text
  void _filterStaff(String searchText) {
    setState(() {
      _searchText = searchText;
      if (searchText.isEmpty) {
        _filteredStaffList = _staffList; // Reset to original list
      } else {
        _filteredStaffList = _staffList.where((staff) {
          final staffData = staff.data() as Map<String, dynamic>;
          return (staffData['nama'] ?? '')
              .toLowerCase()
              .contains(searchText.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue.shade900,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        title: const Text(
          "Daftar Staff/Karyawan",
          style: TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        leading: TextButton(
          onPressed: () {
            Get.to(
              Listad(),
              transition: Transition.leftToRight,
              duration: const Duration(milliseconds: 300),
            );
          },
          child: const Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(35, 35),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(
                Tambahstaff(),
                transition: Transition.leftToRight,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: Icon(
                Icons.group_add_rounded,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
        ),
        child: Column(
          children: [
            // Search TextField
            TextField(
              onChanged: _filterStaff,
              decoration: InputDecoration(
                hintText: 'Cari Staff...',
                hintStyle: TextStyle(
                  fontFamily: 'poppins'
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(),
                ),
                suffixIcon: const Icon(Icons.search),
              ),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _filteredStaffList.length,
                itemBuilder: (context, index, animation) {
                  if (index >= _filteredStaffList.length) {
                    return Container(); // Avoid accessing out of bounds
                  }
                  var staff =
                      _filteredStaffList[index].data() as Map<String, dynamic>;
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    )),
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade800,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          staff['nama'] ?? 'Nama tidak tersedia',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'poppins',
                            fontSize: 16.0,
                          ),
                        ),
                        subtitle: Text(
                          staff['email'] ?? 'Email tidak tersedia',
                          style: TextStyle(fontFamily: 'poppins'),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_rounded,
                              color: Colors.red.shade600),
                          onPressed: () {
                            _deleteStaff(_filteredStaffList[index], index);
                          },
                        ),
                        onTap: () {
                          // Aksi ketika list item ditekan
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
