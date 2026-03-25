import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/rastreamento_provider.dart';
import '../../../shared/widgets/base_components.dart';

class TabHistorico extends ConsumerWidget {
  const TabHistorico({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(rastreamentoListProvider);
    final selectedId = ref.watch(selectedCarroRastreamentoProvider);
    final activeData = list.firstWhere((e) => e.idCarro == selectedId, orElse: () => list.first);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          AppCard(
            height: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Quilometragem por dia (Últimos dias)", style: TextStyle(color: Color(0xFF7A7A9A), fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Expanded(
                  child: Padding(
                     padding: const EdgeInsets.only(top: 16),
                     child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                if (val.toInt() >= 0 && val.toInt() < activeData.historicoKms.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(activeData.historicoKms[val.toInt()]['dia'].toString(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                                  );
                                }
                                return const SizedBox();
                              }
                            )
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: activeData.historicoKms.asMap().entries.map((e) {
                           return BarChartGroupData(
                             x: e.key,
                             barRods: [
                               BarChartRodData(
                                 toY: (e.value['km'] as num).toDouble(),
                                 color: const Color(0xFF00E87A),
                                 width: 16,
                                 borderRadius: BorderRadius.circular(4),
                               )
                             ]
                           );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
          const SizedBox(height: 16),
           Row(
            children: [
              Expanded(child: AppCard(child: Column(children: const [Text("Total na Semana", style: TextStyle(color: Color(0xFF7A7A9A))), SizedBox(height:8), Text("954 km", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]))),
              const SizedBox(width: 16),
              Expanded(child: AppCard(child: Column(children: const [Text("Média/Dia", style: TextStyle(color: Color(0xFF7A7A9A))), SizedBox(height:8), Text("136 km", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]))),
            ],
          )
        ],
      ),
    );
  }
}
