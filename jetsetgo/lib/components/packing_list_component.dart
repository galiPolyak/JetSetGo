import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jetsetgo/pages/packing_list.dart'; // Make sure this path is correct

class PackingListSection extends StatefulWidget {
  final String tripTitle;
  final String tripId;

  const PackingListSection({
    super.key, 
    required this.tripTitle, 
    required this.tripId
    });

  @override
  _PackingListSectionState createState() => _PackingListSectionState();
}

class _PackingListSectionState extends State<PackingListSection> {
  final TextEditingController _controller = TextEditingController();
  late CollectionReference _packingListRef;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _packingListRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('trip')
        .doc(widget.tripId)
        .collection('PackingList');
  }

  Future<void> _addItem() async {
    if (_controller.text.isNotEmpty) {
      await _packingListRef.add({
        'item': _controller.text,
        'checked': false,
      });
      _controller.clear();
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete this item?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to remove this from your packing list?',
          style: TextStyle(color: Color(0xFFA1A1A3)),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _packingListRef.doc(itemId).delete();
    }
  }

  Future<void> _toggleChecked(String itemId, bool isChecked) async {
    await _packingListRef.doc(itemId).update({'checked': isChecked ? 1 : 0});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackingListScreen(tripTitle: widget.tripTitle, tripId: widget.tripId),
          ),
        );
      },
      child: Card(
        color: const Color(0xFFA6BDA3), //darker sage
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Packing List',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white70),

              // Add Item Section
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Color(0xFF1F1F1F)), //charcoal text
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Add item',
                        labelStyle: const TextStyle(color:  Color(0xFF1F1F1F)),
                        filled: true,
                        fillColor: Color(0xFFC9D6C9), //lighter sage
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFFD76C5B)),
                    onPressed: _addItem,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Item List from Firestore
              StreamBuilder<QuerySnapshot>(
                stream: _packingListRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = snapshot.data!.docs;

                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "No items added yet.",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return Column(
                    children: items.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      bool isChecked = (data['checked'] == 1);

                      return _buildPackingItem(doc.id, data['item'], isChecked);
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackingItem(String itemId, String name, bool isChecked) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFC9D6C9), // lighter sage 
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (value) => _toggleChecked(itemId, value!),
            activeColor: const Color(0xFFA6BDA3), // Coral check color
          ),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F1F1F), // Charcoal text
                decoration: isChecked ? TextDecoration.lineThrough : null,
                decorationColor: const Color(0xFF1F1F1F), // charcoal line
                decorationThickness: 2, 
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFD76C5B)), // Coral icon
            onPressed: () => _deleteItem(itemId),
          ),
        ],
      ),
    );
  }

}
