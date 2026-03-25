import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:led_truck/core/theme/app_theme.dart';

class SupportFAB extends StatelessWidget {
  const SupportFAB({super.key});

  Future<void> _launchWhatsApp() async {
    // URL padrão do WhatsApp - substitua com o número real do suporte +55 (DDD) NÚMERO
    final Uri url = Uri.parse('https://wa.me/5511999999999?text=Olá,%20preciso%20de%20suporte%20na%20plataforma%20Led%20Truck.');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir o WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _launchWhatsApp,
      backgroundColor: const Color(0xFF25D366), // Cor oficial do WhatsApp
      foregroundColor: Colors.white,
      elevation: 4,
      tooltip: 'Suporte via WhatsApp',
      child: const Icon(Icons.support_agent, size: 28),
    );
  }
}
