import 'package:flutter/material.dart';

class CustomBookingTextField extends StatelessWidget {
  final TextEditingController? controller; // Add this line for controller
  final IconData? icon;
  final String text;
  final String hintText;
  final TextInputType keyboardType;

  const CustomBookingTextField({
    Key? key,
    this.controller, // Add this line to initialize controller
    this.icon,
    required this.text,
    required this.hintText,
    required this.keyboardType, required bool readOnly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller, // Controller to manage input text
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon) : null, // Add icon if provided
          labelText: text, // Field label
          hintText: hintText, // Placeholder text
          border: const OutlineInputBorder(), // Box around the field
        ),
      ),
    );
  }
}
