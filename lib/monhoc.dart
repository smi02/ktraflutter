import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonHoc extends StatefulWidget {
  const MonHoc({Key? key}) : super(key: key);

  @override
  State<MonHoc> createState() => _MonHocState();
}

class _MonHocState extends State<MonHoc> {
  // text fields' controllers
  final TextEditingController _mamh = TextEditingController();
  final TextEditingController _tenmh = TextEditingController();
  final TextEditingController _mota = TextEditingController();

  final CollectionReference _monhocs =
  FirebaseFirestore.instance.collection('monhoc');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _mamh.text = documentSnapshot['mamh'].toString();
      _tenmh.text = documentSnapshot['tenmh'];
      _mota.text = documentSnapshot['mota'];
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
                  controller: _mamh,
                  decoration: const InputDecoration(
                    labelText: 'Mã môn học',
                  ),
                ),
                TextField(
                  controller: _tenmh,
                  decoration: const InputDecoration(labelText: 'Ten môn học'),
                ),
                TextField(
                  controller: _mota,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? mamh = _mamh.text;
                    final String? temh = _tenmh.text;
                    final String? mota = _mota.text;
                    if (mamh != null && temh != null && mota != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _monhocs.add({"mamh": mamh, "temh": temh, "mota": mota});
                      }

                      if (action == 'update') {
                        // Update the product
                        await _monhocs
                            .doc(documentSnapshot!.id)
                            .update({"mamh": mamh, "temh": temh, "mota": mota});
                      }

                      // Clear the text fields
                      _mamh.text = '';
                      _tenmh.text = '';
                      _mota.text = '';

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
    await _monhocs.doc(productId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Môn Học'),
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _monhocs.snapshots(),
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
                    title: Text(documentSnapshot['mamh'].toString()),
                    subtitle: Text(documentSnapshot['mota']),
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