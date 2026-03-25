import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';

class AdminRelatoriosScreen extends ConsumerStatefulWidget {
  const AdminRelatoriosScreen({super.key});

  @override
  ConsumerState<AdminRelatoriosScreen> createState() => _AdminRelatoriosScreenState();
}

class _AdminRelatoriosScreenState extends ConsumerState<AdminRelatoriosScreen> {
  void _exportarPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✨ Exportando PDF... (Em breve PDF via package pdf/printing)"), backgroundColor: AppTheme.primaryNeon),
    );
  }

  void _exportarCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✨ Exportando CSV... (Em breve via package csv)"), backgroundColor: AppTheme.primaryNeon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("RELATÓRIOS", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
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
                Text(
                  "Desempenho da Rede",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _exportarCSV,
                      icon: const Icon(Icons.table_chart, color: AppTheme.primaryNeon),
                      label: const Text("Exportar CSV", style: TextStyle(color: AppTheme.primaryNeon)),
                    ),
                    const SizedBox(width: 16),
                    AppButton(
                      label: "Exportar PDF",
                      icon: Icons.picture_as_pdf,
                      onPressed: _exportarPDF,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Horas de Exibição (Últimos 7 dias)", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 300,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text('${value.toInt()}h', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 12));
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      const dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
                                      if (value.toInt() >= 0 && value.toInt() < dias.length) {
                                        return Text(dias[value.toInt()], style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 12));
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 45),
                                    FlSpot(1, 60),
                                    FlSpot(2, 55),
                                    FlSpot(3, 80),
                                    FlSpot(4, 75),
                                    FlSpot(5, 120),
                                    FlSpot(6, 95),
                                  ],
                                  isCurved: true,
                                  color: AppTheme.primaryNeon,
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppTheme.primaryNeon.withValues(alpha: 0.15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total de Horas", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 14)),
                            const SizedBox(height: 8),
                            Text("530h", style: TextStyle(color: AppTheme.primaryNeon, fontSize: 32, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            const Text("+12% vs semana anterior", style: TextStyle(color: Colors.green, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Carros Ativos", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 14)),
                            const SizedBox(height: 8),
                            Text("42", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 32, fontWeight: FontWeight.w800)),
                             const SizedBox(height: 8),
                            const Text("De 50 painéis instalados", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                       AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Campanhas Rodando", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 14)),
                            const SizedBox(height: 8),
                            Text("18", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 32, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
