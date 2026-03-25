import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';
import 'package:led_truck/features/shared/providers/notificacoes_provider.dart';
import 'package:led_truck/features/admin/providers/admin_provider.dart';
import 'package:led_truck/features/admin/models/admin_models.dart';

class AdminFranqueadosScreen extends ConsumerWidget {
  const AdminFranqueadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final franqueados = ref.watch(franqueadosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("FRANQUEADOS", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: AppTheme.primaryNeon),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: Badge(
                backgroundColor: AppTheme.primaryNeon,
                textColor: Colors.white,
                label: Consumer(
                  builder: (context, ref, child) {
                    final count = ref.watch(unreadNotificacoesCountProvider);
                    if (count == 0) return const SizedBox.shrink();
                    return Text(count.toString());
                  },
                ),
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Gestão de Franqueados", style: Theme.of(context).textTheme.headlineMedium),
                    AppButton(
                      label: "Novo Franqueado",
                      icon: Icons.business,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        columns: [
                          DataColumn(label: Text("Nome", style: Theme.of(context).textTheme.bodySmall)),
                          DataColumn(label: Text("Cidade", style: Theme.of(context).textTheme.bodySmall)),
                          DataColumn(label: Text("Carros", style: Theme.of(context).textTheme.bodySmall)),
                          DataColumn(label: Text("Campanhas", style: Theme.of(context).textTheme.bodySmall)),
                          DataColumn(label: Text("Ações", style: Theme.of(context).textTheme.bodySmall)),
                        ],
                        rows: franqueados.map((f) => DataRow(
                          cells: [
                            DataCell(Text(f.nome, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
                            DataCell(Text("${f.cidade}/${f.estado}", style: Theme.of(context).textTheme.bodyMedium)),
                            DataCell(Text("${f.carrosAtivos}", style: Theme.of(context).textTheme.bodyMedium)),
                            DataCell(Text("${f.campanhasAtivas}", style: Theme.of(context).textTheme.bodyMedium)),
                            DataCell(TextButton(onPressed: () => _openFranqueadoDrawer(context, f), child: const Text("Ver Detalhes", style: TextStyle(color: AppTheme.primaryNeon)))),
                          ],
                        )).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openFranqueadoDrawer(BuildContext context, AdminFranqueado f) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Fechar",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 16,
            color: Theme.of(context).cardColor,
            child: SizedBox(
              width: 400,
              height: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Detalhes do Franqueado", style: Theme.of(context).textTheme.headlineMedium),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(f.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("${f.cidade} / ${f.estado}", style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 32),
                    const Text("Métricas", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Horas Exibidas Hoje:"), Text("24h", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Carros Ativos:"), Text("${f.carrosAtivos} / ${f.carrosAtivos+2}", style: const TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text("Carros", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const ListTile(leading: Icon(Icons.directions_car), title: Text("Fiorino - ABC-1234"), subtitle: Text("Online")),
                    const ListTile(leading: Icon(Icons.directions_car), title: Text("Kombi - XYZ-9876"), subtitle: Text("Offline")),
                    const SizedBox(height: 32),
                    const Text("Campanhas Ativas", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const ListTile(leading: Icon(Icons.campaign), title: Text("Coca-Cola"), subtitle: Text("Até 31/03")),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(anim1),
          child: child,
        );
      },
    );
  }
}
