import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Imports do mapa removidos temporariamente
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong2.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/status_chip.dart';
import 'package:led_truck/features/shared/widgets/skeleton_loader.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';
import 'package:led_truck/features/admin/providers/admin_provider.dart';
import 'package:led_truck/features/admin/models/admin_models.dart';
import 'package:led_truck/core/utils/date_formatter.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(adminMetricsProvider);
    final franqueados = ref.watch(franqueadosProvider);
    final eventsAsync = ref.watch(eventsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("DASHBOARD ADMIN", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CARDS DE MÉTRICAS - GRID RESPONSIVO
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisExtent: 100,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                      ),
                      itemCount: metrics.length,
                      itemBuilder: (context, index) {
                        final metric = metrics[index];
                        return AppCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryNeon.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_getIcon(metric.icon), color: AppTheme.primaryNeon, size: 24),
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

                // 2. MAPA EM TEMPO REAL
                Text("MAPA EM TEMPO REAL", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
                const SizedBox(height: 16),
                AppCard(
                  padding: EdgeInsets.zero,
                  height: 400,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A26) : const Color(0xFFF0F0F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.map, color: AppTheme.primaryNeon, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          "Mapa em tempo real — em breve",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryNeon,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 3. TABELA DE FRANQUEADOS E FEED DE EVENTOS - LAYOUT RESPONSIVO
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 1000;
                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6, // 60%
                            child: _FranqueadosTable(franqueados: franqueados),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 4, // 40%
                            child: _EventsFeed(eventsAsync: eventsAsync),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _FranqueadosTable(franqueados: franqueados),
                          const SizedBox(height: 32),
                          _EventsFeed(eventsAsync: eventsAsync),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'people': return Icons.people_outline;
      case 'flash_on': return Icons.flash_on;
      case 'ads_click': return Icons.ads_click;
      case 'schedule': return Icons.schedule;
      default: return Icons.info_outline;
    }
  }

  void _showCarInfo(BuildContext context, AdminCarro carro) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor, // Use cardColor for modal background
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(carro.codigo, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(carro.veiculo, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
                StatusChip(status: carro.isOnline ? 'ligado' : 'desligado', label: carro.isOnline ? "LIGADO" : "DE LIGADO"),
              ],
            ),
            Divider(height: 32, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            _PopupRow(label: "Placa", value: carro.placa),
            _PopupRow(label: "Franqueado", value: carro.franqueadoNome),
            _PopupRow(label: "Tempo ligado hoje", value: carro.tempoLigadoHoje, isHighlight: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppButton(label: "Ver Detalhes do Carro", onPressed: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final bool isOnline;
  const _MapMarker({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFF00E87A) : Colors.grey,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          if (isOnline)
            BoxShadow(
              color: const Color(0xFF00E87A).withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 20),
    );
  }
}

class _PopupRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _PopupRow({required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF7A7A9A))),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? AppTheme.primaryNeon : Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _FranqueadosTable extends StatelessWidget {
  final List<AdminFranqueado> franqueados;
  const _FranqueadosTable({required this.franqueados});

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("FRANQUEADOS", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16, color: Color(0xFF00E87A)),
              label: const Text("Novo"),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF00E87A)),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
    );
  }
}


class _EventsFeed extends StatelessWidget {
  final AsyncValue<List<AdminEvento>> eventsAsync;
  const _EventsFeed({required this.eventsAsync});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("FEED DE EVENTOS AO VIVO", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
        const SizedBox(height: 16),
        eventsAsync.when(
          data: (events) => AppCard(
            height: 400,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              itemCount: events.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final e = events[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    e.tipo == 'ligou' ? Icons.power : Icons.power_off,
                    color: e.tipo == 'ligou' ? AppTheme.primaryNeon : Colors.grey,
                    size: 16,
                  ),
                  title: Text(
                    "${e.franqueadoNome} > ${e.carroCodigo}",
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "${_formatTime(e.timestamp)}${e.duracao != null ? ' | Duração: ${e.duracao}' : ''}",
                    style: const TextStyle(color: Color(0xFF7A7A9A), fontSize: 11),
                  ),
                  trailing: Text(
                    e.tipo.toUpperCase(),
                    style: TextStyle(
                      color: e.tipo == 'ligou' ? AppTheme.primaryNeon : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          loading: () => const AppCard(height: 400, child: Center(child: CircularProgressIndicator())),
          error: (e, s) => AppCard(height: 400, child: Center(child: Text("Erro: $e"))),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return DateFormatter.time(dt);
  }
}
