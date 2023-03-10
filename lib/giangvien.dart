import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GiangVien extends StatefulWidget {
  const GiangVien({Key? key}) : super(key: key);

  @override
  State<GiangVien> createState() => _GiangVienState();
}

class _GiangVienState extends State<GiangVien> {

  // text fields' controllers
  final TextEditingController _magv = TextEditingController();
  final TextEditingController _hoten = TextEditingController();
  final TextEditingController _diachi = TextEditingController();
  final TextEditingController _sdt = TextEditingController();


  final CollectionReference _giangviens =
  FirebaseFirestore.instance.collection('giangvien');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _magv.text = documentSnapshot['magv'].toString();
      _hoten.text = documentSnapshot['hoten'];
      _diachi.text = documentSnapshot['diachi'];
      _sdt.text = documentSnapshot['sdt'].toString();
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
                  controller: _magv,
                  decoration: const InputDecoration(
                    labelText: 'Mã giảng viên',
                  ),
                ),
                TextField(
                  controller: _hoten,
                  decoration: const InputDecoration(labelText: 'Họ tên'),
                ),
                TextField(
                  controller: _diachi,
                  decoration: const InputDecoration(labelText: 'Địa chỉ'),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: _sdt,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? magv = _magv.text;
                    final String? hoten = _hoten.text;
                    final String? diachi = _diachi.text;
                    final String? sdt = _sdt.text;
                    if (magv != null && hoten != null && diachi != null && sdt != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _giangviens.add({"magv": magv, "hoten": hoten, "diachi": diachi, "sdt": sdt});
                      }

                      if (action == 'update') {
                        // Update the product
                        await _giangviens
                            .doc(documentSnapshot!.id)
                            .update({"magv": magv, "hoten": hoten, "diachi": diachi, "sdt": sdt});
                      }

                      // Clear the text fields
                      _magv.text = '';
                      _hoten.text = '';
                      _diachi.text = '';
                      _sdt.text = '';

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
  Future<void> _deleteProduct(String gvId) async {
    await _giangviens.doc(gvId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giảng Viên'),
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _giangviens.snapshots(),
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
                    title: Text(documentSnapshot['magv'].toString()),
                    subtitle: Text(documentSnapshot['hoten']),
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
