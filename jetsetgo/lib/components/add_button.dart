import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AddButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, // width of the button
      height: 80, //height of the button
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: const Color(0xFFD76C5B), //coral!
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              color: Colors.white,
              size: 36, 
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12, 
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}