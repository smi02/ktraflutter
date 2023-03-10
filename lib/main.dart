// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ktra1/giangvien.dart';
import 'package:ktra1/lophoc.dart';
import 'package:ktra1/monhoc.dart';
import 'package:ktra1/sinhvien.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'hihi',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  final tabBar = [
    SinhVien(),
    GiangVien(),
    LopHoc(),
    MonHoc(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabBar[_selectedIndex],
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          selectedItemColor: Colors.black,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          unselectedItemColor: Colors.grey,
          items: const<BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "SINH VIÊN",
                backgroundColor: Colors.white
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: "GIẢNG VIÊN",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.class_),
              label: "LỚP HỌC",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.subject),
              label: "MÔN HỌC",
            ),
          ],
        ),
      ),
    );
  }
}