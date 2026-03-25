import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';
import '../providers/rastreamento_provider.dart';
import '../widgets/rastreamento/tab_rota.dart';
import '../widgets/rastreamento/tab_estatisticas.dart';
import '../widgets/rastreamento/tab_historico.dart';
import '../widgets/rastreamento/tab_mapa_calor.dart';

class RastreamentoScreen extends ConsumerWidget {
  const RastreamentoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rastreamentoList = ref.watch(rastreamentoListProvider);
    final selectedCarroId = ref.watch(selectedCarroRastreamentoProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("Rastreamento", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<String>(
              dropdownColor: Theme.of(context).cardColor,
              value: selectedCarroId,
              underline: const SizedBox(),
              icon: const Icon(Icons.directions_car, color: AppTheme.primaryNeon),
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
              items: rastreamentoList.map((c) {
                return DropdownMenuItem(
                  value: c.idCarro,
                  child: Text("${c.placa} - ${c.cidade}"),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(selectedCarroRastreamentoProvider.notifier).state = val;
                }
              },
            ),
          ),
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
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              indicatorColor: AppTheme.primaryNeon,
              labelColor: AppTheme.primaryNeon,
              unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: "Rota", icon: Icon(Icons.map)),
                Tab(text: "Estatísticas", icon: Icon(Icons.analytics)),
                Tab(text: "Histórico", icon: Icon(Icons.history)),
                Tab(text: "Mapa de Calor", icon: Icon(Icons.layers)),
              ],
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(), // Evitar briga com gestos do map
                children: [
                  TabRota(),
                  TabEstatisticas(),
                  TabHistorico(),
                  TabMapaCalor(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
