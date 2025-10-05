import 'package:flutter/material.dart';

class SecureButton extends StatefulWidget {
  final VoidCallback onConfirmed;

  const SecureButton({super.key, required this.onConfirmed});

  @override
  State<SecureButton> createState() => _SecureButtonState();
}

class _SecureButtonState extends State<SecureButton> {
  DateTime? _lastPressed;

  void _handlePress() {
    final now = DateTime.now();

    if (_lastPressed != null &&
        now.difference(_lastPressed!) < const Duration(milliseconds: 500)) {
      widget.onConfirmed();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tap again quickly to confirm")),
      );
    }

    _lastPressed = now;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handlePress,
      child: const Text("Secure Action"),
    );
  }
}
