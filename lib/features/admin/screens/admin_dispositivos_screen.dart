import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/core/utils/date_formatter.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';
import 'package:led_truck/features/admin/providers/dispositivos_provider.dart';
import 'package:led_truck/features/admin/models/dispositivo_model.dart';
import 'package:led_truck/features/admin/widgets/modal_cadastrar_dispositivo.dart';
import 'package:led_truck/features/admin/widgets/modal_vincular_carro.dart';
import 'package:led_truck/features/admin/widgets/modal_desvincular_dispositivo.dart';
import 'package:led_truck/features/admin/widgets/modal_historico_dispositivo.dart';
import 'package:led_truck/features/admin/widgets/modal_editar_dispositivo.dart';
import 'package:led_truck/features/shared/widgets/support_fab.dart';

class AdminDispositivosScreen extends ConsumerWidget {
  const AdminDispositivosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(dispositivosMetricsProvider);
    final dispositivos = ref.watch(dispositivosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      floatingActionButton: const SupportFAB(),
      appBar: AppBar(
        title: Text("GESTÃO DE DISPOSITIVOS", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
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
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CARDS DE MÉTRICAS
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
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
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_getIcon(metric.icon), color: iconColor, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(metric.label, style: Theme.of(context).textTheme.bodySmall),
                                    const SizedBox(height: 4),
                                    Text(metric.value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("DISPOSITIVOS", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
                    AppButton(
                      label: "Cadastrar Dispositivo",
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: isDark ? const Color(0xFF12121A) : Colors.white,
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
                  child: SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        columns: [
                          DataColumn(label: Text("Nº Série", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                          DataColumn(label: Text("Modelo", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                          DataColumn(label: Text("Firmware", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                          DataColumn(label: Text("Status", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                          DataColumn(label: Text("Carro Vinculado", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                          DataColumn(label: Text("Franqueado", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                          DataColumn(label: Text("Instalado em", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                          DataColumn(label: Text("Ações", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                        ],
                        rows: dispositivos.map((d) {
                          return DataRow(
                            cells: [
                              DataCell(Text(d.numeroSerie, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
                              DataCell(Text(d.modelo, style: Theme.of(context).textTheme.bodyMedium)),
                              DataCell(Text(d.versaoFirmware, style: Theme.of(context).textTheme.bodyMedium)),
                              DataCell(_buildStatusBadge(d.status)),
                              DataCell(Text(d.carroVinculado ?? '-', style: Theme.of(context).textTheme.bodyMedium)),
                              DataCell(Text(d.franqueadoNome ?? '-', style: Theme.of(context).textTheme.bodyMedium)),
                              DataCell(Text(d.instaladoEm != null ? DateFormatter.date(d.instaladoEm!) : '-', style: Theme.of(context).textTheme.bodyMedium)),
                              DataCell(
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  color: isDark ? const Color(0xFF1A1A26) : Colors.white,
                                  onSelected: (action) => _handleAction(context, action, d),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'editar',
                                      child: Text('Editar', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0D0D1A))),
                                    ),
                                    if (d.status == 'estoque' || d.status == 'manutencao')
                                      PopupMenuItem(
                                        value: 'vincular',
                                        child: Text('Vincular a Carro', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0D0D1A))),
                                      ),
                                    if (d.status == 'instalado')
                                      const PopupMenuItem(
                                        value: 'desvincular',
                                        child: Text('Desvincular', style: TextStyle(color: Colors.redAccent)),
                                      ),
                                    PopupMenuItem(
                                      value: 'historico',
                                      child: Text('Ver Histórico', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0D0D1A))),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
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

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    switch (status) {
      case 'estoque':
        bg = Colors.blue.withValues(alpha: 0.12);
        text = Colors.blue;
        break;
      case 'instalado':
        bg = const Color(0xFF00E87A).withValues(alpha: 0.12);
        text = const Color(0xFF00E87A);
        break;
      case 'manutencao':
        bg = Colors.amber.withValues(alpha: 0.12);
        text = Colors.amber;
        break;
      case 'inativo':
      default:
        bg = Colors.grey.withValues(alpha: 0.12);
        text = Colors.grey;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: text.withValues(alpha: 0.3))),
      child: Text(status.toUpperCase(), style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _handleAction(BuildContext context, String action, AdminDispositivo d) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modalBg = isDark ? const Color(0xFF12121A) : Colors.white;

    if (action == 'editar') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: modalBg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => ModalEditarDispositivo(dispositivo: d),
      );
    } else if (action == 'vincular') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: modalBg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => ModalVincularCarro(dispositivo: d),
      );
    } else if (action == 'desvincular') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: modalBg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => ModalDesvincularDispositivo(dispositivo: d),
      );
    } else if (action == 'historico') {
      showModalBottomSheet(
        context: context,
        backgroundColor: modalBg,
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
