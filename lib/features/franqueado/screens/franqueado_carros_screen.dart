import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';

class FranqueadoCarrosScreen extends ConsumerWidget {
  const FranqueadoCarrosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("MEUS CARROS", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Gerenciamento da Frota", style: Theme.of(context).textTheme.headlineMedium),
                AppButton(
                  label: "Exportar Relatório",
                  icon: Icons.download,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: AppTextField(label: "Buscar carro ou placa", icon: Icons.search)),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  dropdownColor: Theme.of(context).cardColor,
                  value: "Todos",
                  items: const [DropdownMenuItem(value: "Todos", child: Text("Todos os Status")), DropdownMenuItem(value: "Online", child: Text("Online")), DropdownMenuItem(value: "Offline", child: Text("Offline"))],
                  onChanged: (val) {},
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  underline: Container(height: 1, color: AppTheme.primaryNeon.withOpacity(0.3)),
                )
              ],
            ),
             const SizedBox(height: 24),
             AppCard(
              padding: const EdgeInsets.all(0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontWeight: FontWeight.bold),
                  dataTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  columns: const [
                    DataColumn(label: Text("Código")),
                    DataColumn(label: Text("Veículo")),
                    DataColumn(label: Text("Placa")),
                    DataColumn(label: Text("Status ao Vivo")),
                    DataColumn(label: Text("Operador")),
                    DataColumn(label: Text("Tempo ligado hoje")),
                    DataColumn(label: Text("Ações")),
                  ],
                  rows: [
                    _carroRow(context, "LT-001", "Fiorino Branca", "ABC-1234", "Online", "João Silva", "4h 30m"),
                    _carroRow(context, "LT-002", "Kombi Laranja", "XYZ-9876", "Offline", "Maria", "2h 10m"),
                    _carroRow(context, "LT-003", "HR Hyundai", "DEF-5678", "Online", "Carlos", "1h 15m"),
                    _carroRow(context, "LT-004", "Fiorino Prata", "GHI-9012", "Online", "Ana", "6h 45m"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _carroRow(BuildContext context, String code, String veiculo, String placa, String status, String operador, String tempo) {
    bool isOnline = status == "Online";
    return DataRow(cells: [
      DataCell(Text(code, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(veiculo)),
      DataCell(Text(placa)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: (isOnline ? Colors.green : Colors.red).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Text(status, style: TextStyle(color: isOnline ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
      )),
      DataCell(Text(operador)),
      DataCell(Text(tempo)),
      DataCell(Row(
        children: [
          IconButton(icon: const Icon(Icons.map, color: AppTheme.primaryNeon, size: 20), onPressed: () => context.go('/franqueado/rastreamento'), tooltip: "Ver Rota"),
          IconButton(icon: const Icon(Icons.campaign, color: Colors.blue, size: 20), onPressed: () => context.go('/franqueado/campanhas'), tooltip: "Ver Campanhas"),
        ],
      )),
    ]);
  }
}
