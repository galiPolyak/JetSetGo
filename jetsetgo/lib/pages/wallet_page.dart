import 'package:flutter/material.dart';
import 'package:jetsetgo/components/navbar.dart';
import 'package:jetsetgo/components/add_document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart'; // Ensure this is at the top

class WalletPage extends StatefulWidget {
  final String tripId;
  final String tripName;

  const WalletPage({super.key, required this.tripId, required this.tripName});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  List<Map<String, dynamic>> walletItems = [];
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadWalletItems();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadWalletItems() async {
    final user = FirebaseAuth.instance.currentUser!;
    final walletSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('trip')
        .doc(widget.tripId)
        .collection('wallet')
        .get();

    setState(() {
      walletItems = walletSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'],
          'date': data['date'],
          'url': data['url'],
          'id': doc.id,
        };
      }).toList();
    });
  }

  Future<void> _addDocument(String title, DateTime date, PlatformFile file) async {
    final user = FirebaseAuth.instance.currentUser!;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('trip')
        .doc(widget.tripId)
        .collection('wallet')
        .doc();

    await docRef.set({
      'title': title,
      'date': date.toIso8601String(),
      'url': file.path, // Replace with Firebase Storage URL if using uploads
    });

    setState(() {
      walletItems.add({
        'title': title,
        'date': DateFormat('yyyy-MM-dd').format(date), 
        'url': file.path,
        'id': docRef.id,
      });
    });
  }

  Future<void> _removeItem(String docId, int index) async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('trip')
        .doc(widget.tripId)
        .collection('wallet')
        .doc(docId)
        .delete();

    setState(() {
      walletItems.removeAt(index);
    });
  }

  void _openFile(String path) {
    OpenFile.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        toolbarHeight: 120,
        title: Text(
          '${widget.tripName} - Wallet',
          style: const TextStyle(fontSize: 24, color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF1C1C1E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: walletItems.isEmpty
                  ? const Center(child: Text("No documents added yet.", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: walletItems.length,
                      itemBuilder: (context, index) {
                        final item = walletItems[index];
                        return WalletCard(
                          title: item['title'],
                          date: item['date'],
                          filePath: item['url'],
                          onDelete: () => _removeItem(item['id'], index),
                          onOpen: () => _openFile(item['url']),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 180,
        height: 60,
        child: FloatingActionButton.extended(
          backgroundColor: const Color.fromARGB(255, 222, 177, 109),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddDocumentDialog(
                onDocumentAdded: _addDocument,
              ),
            );
          },
          label: const Text(
            'Add Document',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          icon: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class WalletCard extends StatelessWidget {
  final String title;
  final String date;
  final String filePath;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  const WalletCard({
    super.key,
    required this.title,
    required this.date,
    required this.filePath,
    required this.onDelete,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        color: const Color.fromARGB(255, 34, 36, 36),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf, size: 40, color: Colors.orangeAccent),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Date: $date',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
