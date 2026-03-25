import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets/base_components.dart';
import '../../shared/widgets/side_menu.dart';
import '../../shared/widgets/notifications_drawer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../providers/dispositivos_provider.dart';
import '../models/dispositivo_model.dart';
import '../widgets/modal_cadastrar_dispositivo.dart';
import '../widgets/modal_vincular_carro.dart';
import '../widgets/modal_desvincular_dispositivo.dart';
import '../widgets/modal_historico_dispositivo.dart';

class AdminDispositivosScreen extends ConsumerWidget {
  const AdminDispositivosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dispositivosMetricsProvider);
    final dispositivos = ref.watch(dispositivosProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("GESTÃO DE DISPOSITIVOS", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
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
            // CARDS DE MÉTRICAS
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisExtent: 100,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: metrics.length,
              itemBuilder: (context, index) {
                final metric = metrics[index];
                final iconColor = Color(int.parse(metric.colorHex, radix: 16) + 0xFF000000);
                return AppCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getIcon(metric.icon), color: iconColor),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(metric.label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 12)),
                          Text(metric.value, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("DISPOSITIVOS", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                AppButton(
                  label: "Cadastrar Dispositivo",
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: const Color(0xFF12121A),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (_) => const ModalCadastrarDispositivo(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            AppCard(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text("Nº Série", style: TextStyle(color: Color(0xFF7A7A9A)))),
                    DataColumn(label: Text("Modelo", style: TextStyle(color: Color(0xFF7A7A9A)))),
                    DataColumn(label: Text("Firmware", style: TextStyle(color: Color(0xFF7A7A9A)))),
                    DataColumn(label: Text("Status", style: TextStyle(color: Color(0xFF7A7A9A)))),
                    DataColumn(label: Text("Carro Vinculado", style: TextStyle(color: Color(0xFF7A7A9A)))),
                    DataColumn(label: Text("Franqueado", style: TextStyle(color: Color(0xFF7A7A9A)))),
                    DataColumn(label: Text("Instalado em", style: TextStyle(color: Color(0xFF7A7A9A)))),
                    DataColumn(label: Text("Ações", style: TextStyle(color: Color(0xFF7A7A9A)))),
                  ],
                  rows: dispositivos.map((d) {
                    return DataRow(
                      cells: [
                        DataCell(Text(d.numeroSerie, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataCell(Text(d.modelo, style: const TextStyle(color: Colors.white))),
                        DataCell(Text(d.versaoFirmware, style: const TextStyle(color: Colors.white))),
                        DataCell(_buildStatusBadge(d.status)),
                        DataCell(Text(d.carroVinculado ?? '-', style: const TextStyle(color: Colors.white))),
                        DataCell(Text(d.franqueadoNome ?? '-', style: const TextStyle(color: Colors.white))),
                        DataCell(Text(d.instaladoEm != null ? DateFormat('dd/MM/yyyy').format(d.instaladoEm!) : '-', style: const TextStyle(color: Colors.white))),
                        DataCell(
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Color(0xFF7A7A9A)),
                            color: const Color(0xFF1A1A26),
                            onSelected: (action) => _handleAction(context, action, d),
                            itemBuilder: (context) => [
                              if (d.status == 'estoque' || d.status == 'manutencao')
                                const PopupMenuItem(value: 'vincular', child: Text('Vincular a Carro', style: TextStyle(color: Colors.white))),
                              if (d.status == 'instalado')
                                const PopupMenuItem(value: 'desvincular', child: Text('Desvincular', style: TextStyle(color: Colors.redAccent))),
                              const PopupMenuItem(value: 'historico', child: Text('Ver Histórico', style: TextStyle(color: Colors.white))),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    switch (status) {
      case 'estoque':
        bg = Colors.blue.withOpacity(0.12);
        text = Colors.blue;
        break;
      case 'instalado':
        bg = const Color(0xFF00E87A).withOpacity(0.12);
        text = const Color(0xFF00E87A);
        break;
      case 'manutencao':
        bg = Colors.amber.withOpacity(0.12);
        text = Colors.amber;
        break;
      case 'inativo':
      default:
        bg = Colors.grey.withOpacity(0.12);
        text = Colors.grey;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: text.withOpacity(0.3))),
      child: Text(status.toUpperCase(), style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _handleAction(BuildContext context, String action, AdminDispositivo d) {
    if (action == 'vincular') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF12121A),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => ModalVincularCarro(dispositivo: d),
      );
    } else if (action == 'desvincular') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF12121A),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => ModalDesvincularDispositivo(dispositivo: d),
      );
    } else if (action == 'historico') {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF12121A),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => ModalHistoricoDispositivo(dispositivo: d),
      );
    }
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'inventory_2': return Icons.inventory_2_outlined;
      case 'check_circle': return Icons.check_circle_outline;
      case 'build': return Icons.build_circle_outlined;
      default: return Icons.info_outline;
    }
  }
}
