import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/side_menu.dart';
import '../../shared/widgets/notifications_drawer.dart';
import '../../shared/widgets/base_components.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';

class AdminIntegracoesScreen extends ConsumerStatefulWidget {
  const AdminIntegracoesScreen({super.key});

  @override
  ConsumerState<AdminIntegracoesScreen> createState() => _AdminIntegracoesScreenState();
}

class _AdminIntegracoesScreenState extends ConsumerState<AdminIntegracoesScreen> {
  void _openConfigModal(String title, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text("Configurar $title", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(description, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              const SizedBox(height: 24),
              const AppTextField(
                label: "Chave da API",
                icon: Icons.key,
              ),
              const SizedBox(height: 16),
              const AppTextField(
                label: "Webhook URL (Opcional)",
                icon: Icons.link,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5))),
            ),
            AppButton(
              label: "Salvar",
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$title configurado com sucesso!"), backgroundColor: AppTheme.primaryNeon),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildIntegracaoCard(String title, String description, IconData icon, bool connected) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNeon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryNeon, size: 32),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: connected ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: connected ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: connected ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      connected ? "Conectado" : "Desconectado",
                      style: TextStyle(color: connected ? Colors.green : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: connected ? "Configurar" : "Conectar",
              onPressed: () => _openConfigModal(title, "Insira as credenciais para integrar com $title."),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("INTEGRAÇÕES", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
              color: AppTheme.primaryNeon,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: Badge(
                backgroundColor: AppTheme.primaryNeon,
                textColor: Colors.white,
                label: const Text('2'),
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Central de Integrações",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Conecte o LED Truck com outras plataformas e serviços.",
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
            ),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : (MediaQuery.of(context).size.width > 800 ? 2 : 1),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: 1.2,
              children: [
                _buildIntegracaoCard(
                  "WhatsApp API (Evolution)",
                  "Envie notificações automáticas de conclusão de campanhas para os clientes via WhatsApp.",
                  Icons.chat,
                  true,
                ),
                _buildIntegracaoCard(
                  "Resend (E-mail)",
                  "Envie relatórios e PDFs consolidados diretamente para o e-mail dos anunciantes.",
                  Icons.email,
                  false,
                ),
                _buildIntegracaoCard(
                  "Webhooks Customizáveis",
                  "Notifique outros sistemas (ERPs, CRMs) sobre eventos do rastreador em tempo real.",
                  Icons.webhook,
                  false,
                ),
                _buildIntegracaoCard(
                  "Asaas (Pagamentos)",
                  "Geração automática de cobranças para franqueados e gestão de faturas.",
                  Icons.payments,
                  false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
