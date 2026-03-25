import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Imports do mapa removidos temporariamente
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong2.dart';
import '../../shared/widgets/base_components.dart';
import '../../shared/widgets/side_menu.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/skeleton_loader.dart';
import '../../shared/widgets/notifications_drawer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../providers/admin_provider.dart';
import '../models/admin_models.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(adminMetricsProvider);
    final franqueados = ref.watch(franqueadosProvider);
    final carros = ref.watch(carrosMapaProvider);
    final eventsAsync = ref.watch(eventsStreamProvider);

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
            // 1. CARDS DE MÉTRICAS
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
                return AppCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E87A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getIcon(metric.icon), color: AppTheme.primaryNeon),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(metric.label, style: const TextStyle(color: Color(0xFF7A7A9A), fontSize: 12)),
                          Text(metric.value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // 2. MAPA EM TEMPO REAL
            const Text("MAPA EM TEMPO REAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AppCard(
              padding: EdgeInsets.zero,
              height: 400,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.map, color: AppTheme.primaryNeon, size: 48),
                    SizedBox(height: 16),
                    Text(
                      "Mapa em tempo real — em breve",
                      style: TextStyle(
                        color: AppTheme.primaryNeon,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 3. TABELA DE FRANQUEADOS E FEED DE EVENTOS
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                return isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _FranqueadosTable(franqueados: franqueados)),
                          const SizedBox(width: 24),
                          Expanded(flex: 1, child: _EventsFeed(eventsAsync: eventsAsync)),
                        ],
                      )
                    : Column(
                        children: [
                          _FranqueadosTable(franqueados: franqueados),
                          const SizedBox(height: 32),
                          _EventsFeed(eventsAsync: eventsAsync),
                        ],
                      );
              },
            ),
          ],
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
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12121A),
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
                    Text(carro.codigo, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(carro.veiculo, style: const TextStyle(color: Color(0xFF7A7A9A))),
                  ],
                ),
                StatusChip(status: carro.isOnline ? 'ligado' : 'desligado', label: carro.isOnline ? "LIGADO" : "DESLIGADO"),
              ],
            ),
            const Divider(height: 32, color: Colors.white10),
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
              color: const Color(0xFF00E87A).withOpacity(0.5),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("FRANQUEADOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text("Nome", style: TextStyle(color: Color(0xFF7A7A9A)))),
                DataColumn(label: Text("Cidade", style: TextStyle(color: Color(0xFF7A7A9A)))),
                DataColumn(label: Text("Carros", style: TextStyle(color: Color(0xFF7A7A9A)))),
                DataColumn(label: Text("Campanhas", style: TextStyle(color: Color(0xFF7A7A9A)))),
                DataColumn(label: Text("Ações", style: TextStyle(color: Color(0xFF7A7A9A)))),
              ],
              rows: franqueados.map((f) => DataRow(
                cells: [
                  DataCell(Text(f.nome, style: const TextStyle(color: Colors.white))),
                  DataCell(Text("${f.cidade}/${f.estado}")),
                  DataCell(Text("${f.carrosAtivos}")),
                  DataCell(Text("${f.campanhasAtivas}")),
                  DataCell(TextButton(onPressed: () {}, child: const Text("Ver Detalhes", style: TextStyle(color: AppTheme.primaryNeon)))),
                ],
              )).toList(),
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
        const Text("FEED DE EVENTOS AO VIVO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
