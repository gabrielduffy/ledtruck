import 'package:flutter/material.dart';

class TabRota extends StatelessWidget {
  const TabRota({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D14),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, color: Color(0xFFFF7200), size: 48),
            SizedBox(height: 12),
            Text(
              "Mapa em breve",
              style: TextStyle(color: Color(0xFFFF7200)),
            ),
          ],
        ),
      ),
    );
  }
}
