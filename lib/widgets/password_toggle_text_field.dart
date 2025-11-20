import 'package:flutter/material.dart';

class PasswordToggleTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;

  const PasswordToggleTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<PasswordToggleTextField> createState() =>
      _PasswordToggleTextFieldState();
}

class _PasswordToggleTextFieldState extends State<PasswordToggleTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Image.asset(
            _obscure
                ? 'assets/images/eye.png'
                : 'assets/images/eye2.png',
            height: 22,
            width: 22,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
