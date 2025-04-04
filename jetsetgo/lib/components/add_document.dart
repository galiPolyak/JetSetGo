import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddDocumentDialog extends StatefulWidget {
  final Function(String, DateTime, PlatformFile) onDocumentAdded; // Pass the new document to WalletPage

  const AddDocumentDialog({super.key, required this.onDocumentAdded});

  @override
  _AddDocumentDialogState createState() => _AddDocumentDialogState();
}

class _AddDocumentDialogState extends State<AddDocumentDialog> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;
  PlatformFile? _selectedFile;

  // Function: pick a PDF file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Only allow PDFs for now?
    );

    if (!mounted) return; //ensure widget is still mounted

    if (result != null) {
      setState(() {
        _selectedFile = result.files.single;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected")),
      );
    }
  }

  // Function: pick a date
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function: save the document locally
  void _saveDocument() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a title")),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please pick a date")),
      );
      return;
    }

    if (_selectedFile == null || _titleController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose a pdf file")),
      );
      return;
    }

    widget.onDocumentAdded(
      _titleController.text,
      _selectedDate!,
      _selectedFile!,
    );

    Navigator.pop(context); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFA6BDA3), // Sage green
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Add Document",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
           ),
        ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Color(0xFF1F1F1F)),
            decoration: InputDecoration(
              labelText: "Document Title",
              labelStyle: const TextStyle(color: Color(0xFF1F1F1F)),
              filled: true,
              fillColor: const Color(0xFFC9D6C9), // lighter sage
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_selectedDate == null
                  ? "No date selected"
                  : "Date: ${_selectedDate!.toLocal()}".split(' ')[0]),
              TextButton(
                onPressed: _pickDate,
                child: const Text("Pick Date", style: TextStyle(color: Color(0xFFD76C5B))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedFile == null ? "No file selected" : "PDF selected",
                style: const TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: _pickFile,
                child: const Text("Choose PDF", style: TextStyle(color: Color(0xFFD76C5B))),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: _saveDocument, 
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD76C5B), // Coral
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Save"),
        ),
      ],
    );
  }
}

