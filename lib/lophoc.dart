import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LopHoc extends StatefulWidget {
  const LopHoc({Key? key}) : super(key: key);

  @override
  State<LopHoc> createState() => _LopHocState();
}

class _LopHocState extends State<LopHoc> {

  // text fields' controllers
  final TextEditingController _malh = TextEditingController();
  final TextEditingController _tenlop = TextEditingController();
  final TextEditingController _slsv = TextEditingController();
  final TextEditingController _magv = TextEditingController();


  final CollectionReference _lophocs =
  FirebaseFirestore.instance.collection('lophoc');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _malh.text = documentSnapshot['malh'].toString();
      _tenlop.text = documentSnapshot['tenlop'];
      _slsv.text = documentSnapshot['slsv'].toString();
      _magv.text = documentSnapshot['magv'].toString();
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
                  controller: _malh,
                  decoration: const InputDecoration(
                    labelText: 'Mã lớp học',
                  ),
                ),
                TextField(
                  controller: _tenlop,
                  decoration: const InputDecoration(labelText: 'Tên lớp'),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: _slsv,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng sinh viên',
                  ),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: _magv,
                  decoration: const InputDecoration(
                    labelText: 'Mã giảng viên',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? malh = _malh.text;
                    final String? tenlop = _tenlop.text;
                    final String? slsv = _slsv.text;
                    final String? magv = _magv.text;
                    if (malh != null && tenlop != null && slsv != null && magv != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _lophocs.add({"malh": malh, "tenlop": tenlop, "slsv": slsv, "magv": magv});
                      }

                      if (action == 'update') {
                        // Update the product
                        await _lophocs
                            .doc(documentSnapshot!.id)
                            .update({"malh": malh, "tenlop": tenlop, "slsv": slsv, "magv": magv});
                      }

                      // Clear the text fields
                      _malh.text = '';
                      _tenlop.text = '';
                      _slsv.text = '';
                      _magv.text = '';

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
  Future<void> _deleteProduct(String classId) async {
    await _lophocs.doc(classId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lớp Học'),
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _lophocs.snapshots(),
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
                    title: Text(documentSnapshot['malh'].toString()),
                    subtitle: Text(documentSnapshot['tenlop']),
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
