import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SinhVien extends StatefulWidget {
  const SinhVien({Key? key}) : super(key: key);

  @override
  State<SinhVien> createState() => _SinhVienState();
}

class _SinhVienState extends State<SinhVien> {

  // text fields' controllers
  final TextEditingController _masv = TextEditingController();
  final TextEditingController _ngaysinh = TextEditingController();
  final TextEditingController _gioitinh = TextEditingController();
  final TextEditingController _quequan = TextEditingController();


  final CollectionReference _sinhviens =
  FirebaseFirestore.instance.collection('sinhvien');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _masv.text = documentSnapshot['masv'].toString();
      _ngaysinh.text = documentSnapshot['ngaysinh'];
      _gioitinh.text = documentSnapshot['gioitinh'];
      _quequan.text = documentSnapshot['quequan'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: _masv,
                  decoration: const InputDecoration(
                    labelText: 'Mã sinh viên',
                  ),
                ),
                TextField(
                  controller: _ngaysinh,
                  decoration: const InputDecoration(labelText: 'Ngày sinh'),
                ),
                TextField(
                  controller: _gioitinh,
                  decoration: const InputDecoration(labelText: 'Giới tính'),
                ),
                TextField(
                  controller: _quequan,
                  decoration: const InputDecoration(labelText: 'Quê quán'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? masv = _masv.text;
                    final String? ngaysinh = _ngaysinh.text;
                    final String? gioitinh = _gioitinh.text;
                    final String? quequan = _quequan.text;
                    if (masv != null && ngaysinh != null && gioitinh != null && quequan != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _sinhviens.add({"masv": masv, "ngaysinh": ngaysinh, "gioitinh": gioitinh, "quequan": quequan});
                      }

                      if (action == 'update') {
                        // Update the product
                        await _sinhviens
                            .doc(documentSnapshot!.id)
                            .update({"masv": masv, "ngaysinh": ngaysinh, "gioitinh": gioitinh, "quequan": quequan});
                      }

                      // Clear the text fields
                      _masv.text = '';
                      _ngaysinh.text = '';
                      _gioitinh.text = '';
                      _quequan.text = '';

                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // Deleteing a product by id
  Future<void> _deleteProduct(String productId) async {
    await _sinhviens.doc(productId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sinh Viên'),
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _sinhviens.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['masv'].toString()),
                    subtitle: Text(documentSnapshot['ngaysinh']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Press this button to edit a single product
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          // This icon button is used to delete a single product
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteProduct(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
