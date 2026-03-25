import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';

class CarroDetalhesScreen extends ConsumerStatefulWidget {
  final String id;
  const CarroDetalhesScreen({super.key, required this.id});

  @override
  ConsumerState<CarroDetalhesScreen> createState() => _CarroDetalhesScreenState();
}

class _CarroDetalhesScreenState extends ConsumerState<CarroDetalhesScreen> {
  bool is30Days = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("DETALHES DO VEÍCULO: ${widget.id}", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: AppTheme.primaryNeon),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // HEADER INFO
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                return AppCard(
                  padding: const EdgeInsets.all(24),
                  child: isMobile 
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderInfo(context, "Código", widget.id),
                        const Divider(height: 24),
                        _buildHeaderInfo(context, "Modelo", "VW Delivery 11.180"),
                        const Divider(height: 24),
                        _buildHeaderInfo(context, "Placa", "ABC-1234"),
                        const Divider(height: 24),
                        _buildHeaderInfo(context, "Status", "ONLINE", color: Colors.green),
                        const Divider(height: 24),
                        _buildHeaderInfo(context, "Operador", "João Silva"),
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeaderInfo(context, "Código", widget.id),
                          VerticalDivider(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
                          _buildHeaderInfo(context, "Modelo", "VW Delivery 11.180"),
                          VerticalDivider(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
                          _buildHeaderInfo(context, "Placa", "ABC-1234"),
                          VerticalDivider(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
                          _buildHeaderInfo(context, "Status", "ONLINE", color: Colors.green),
                          VerticalDivider(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
                          _buildHeaderInfo(context, "Operador", "João Silva"),
                        ],
                      ),
                    ),
                );
              }
            ),
            const SizedBox(height: 32),

            // GRÁFICOS
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 900;
                return isMobile 
                ? Column(
                    children: [
                      _buildChartCard(context),
                      const SizedBox(height: 24),
                      _buildActionsCard(context),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildChartCard(context)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildActionsCard(context)),
                    ],
                  );
              }
            ),
            const SizedBox(height: 32),

            // HISTÓRICO DE EVENTOS
            Text("HISTÓRICO DE EVENTOS", style: Theme.of(context).textTheme.headlineMedium),
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
                      DataColumn(label: Text("Data/Hora", style: Theme.of(context).textTheme.bodySmall)),
                      DataColumn(label: Text("Tipo", style: Theme.of(context).textTheme.bodySmall)),
                      DataColumn(label: Text("Duração", style: Theme.of(context).textTheme.bodySmall)),
                      DataColumn(label: Text("Localização", style: Theme.of(context).textTheme.bodySmall)),
                    ],
                    rows: List.generate(5, (i) => DataRow(cells: [
                      DataCell(Text("24/03/2026 14:20", style: Theme.of(context).textTheme.bodyMedium)),
                      DataCell(Text(i % 2 == 0 ? "LIGOU" : "DESLIGOU", style: TextStyle(color: i % 2 == 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 13))),
                      DataCell(Text("4h 12m", style: Theme.of(context).textTheme.bodyMedium)),
                      DataCell(Text("Av. Paulista, 1000", style: Theme.of(context).textTheme.bodyMedium)),
                    ])),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildChartCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("DESEMPENHO", style: Theme.of(context).textTheme.titleLarge),
              Row(
                children: [
                  const Text("7d", style: TextStyle(fontSize: 12)),
                  Switch(
                    value: is30Days, 
                    activeColor: AppTheme.primaryNeon,
                    onChanged: (val) => setState(() => is30Days = val),
                  ),
                  const Text("30d", style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                         const dias = ["SEG", "TER", "QUA", "QUI", "SEX", "SAB", "DOM"];
                         return Text(dias[val.toInt() % 7], style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5, getDrawingHorizontalLine: (v) => FlLine(color: Theme.of(context).dividerColor.withOpacity(0.05))),
                barGroups: List.generate(7, (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(toY: 8 + (i * 1.5), color: AppTheme.primaryNeon, width: 12, borderRadius: BorderRadius.circular(4)),
                    BarChartRodData(toY: 10 + (i * 0.8), color: Colors.amber, width: 12, borderRadius: BorderRadius.circular(4)),
                  ],
                )),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chartLegend("Horas Ligado", AppTheme.primaryNeon),
              const SizedBox(width: 24),
              _chartLegend("KM Rodados (x10)", Colors.amber),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("AÇÕES", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 32),
          AppButton(label: "VER ROTA NO MAPA", icon: Icons.map, isFullWidth: true, onPressed: () {}),
          const SizedBox(height: 16),
          AppButton(label: "EXPORTAR CSV", icon: Icons.download, isSecondary: true, isFullWidth: true, onPressed: () {}),
          const SizedBox(height: 16),
          AppButton(label: "VER OPERADOR", icon: Icons.person, isSecondary: true, isFullWidth: true, onPressed: () {}),
        ],
      ),
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
