import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget textField({
  TextEditingController controller,
  String label,
  String hint,
  String initialValue,
  double width,
  Widget suffixIcon,
  Function(String) locationCallback,
}) {
  return Container(
    width: width * 0.8,
    child: TextField(
      onChanged: (value) {
        locationCallback(value);
      },
      controller: controller,
      // initialValue: initialValue,
      decoration: new InputDecoration(
        suffixIcon: suffixIcon,
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[400],
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.green[300],
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.all(15),
        hintText: hint,
      ),
    ),
  );
}