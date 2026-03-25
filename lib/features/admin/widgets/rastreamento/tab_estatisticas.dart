import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/rastreamento_provider.dart';
import '../../../shared/widgets/base_components.dart';

class TabEstatisticas extends ConsumerWidget {
  const TabEstatisticas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(rastreamentoListProvider);
    final selectedId = ref.watch(selectedCarroRastreamentoProvider);
    final activeData = list.firstWhere((e) => e.idCarro == selectedId, orElse: () => list.first);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatCard(title: "KM Rodados", value: "${activeData.kmTotal.toStringAsFixed(1)}", suffix: " km", icon: Icons.map)),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(title: "Vel. Média", value: "${activeData.mediaVelocidade.toStringAsFixed(1)}", suffix: " km/h", icon: Icons.speed)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatCard(title: "Máx. Vel", value: "${activeData.maxVelocidade.toStringAsFixed(1)}", suffix: " km/h", icon: Icons.warning_amber)),
              const SizedBox(width: 16),
              Expanded(child: _StatCard(title: "Painel Ligado", value: "${(activeData.minutosLigado / 60).toStringAsFixed(1)}", suffix: "h", icon: Icons.lightbulb, valueColor: const Color(0xFF00E87A))),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Movimento vs Parado", style: TextStyle(color: Color(0xFF7A7A9A), fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TimeColumn(label: "Em Movimento", minutos: activeData.minutosMovimento, color: const Color(0xFF00E87A)),
                    _TimeColumn(label: "Parado", minutos: activeData.minutosParado, color: Colors.orangeAccent),
                  ],
                )
              ]
            )
          )
        ],
      )
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final IconData icon;
  final Color? valueColor;

  const _StatCard({required this.title, required this.value, required this.suffix, required this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Icon(icon, color: const Color(0xFF7A7A9A), size: 16),
               const SizedBox(width: 8),
               Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF7A7A9A), fontSize: 12), overflow: TextOverflow.ellipsis)),
            ]
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                TextSpan(text: suffix, style: const TextStyle(color: Color(0xFF7A7A9A), fontSize: 14)),
              ]
            ),
          )
        ],
      )
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String label;
  final int minutos;
  final Color color;

  const _TimeColumn({required this.label, required this.minutos, required this.color});

  @override
  Widget build(BuildContext context) {
    final horas = (minutos / 60).toStringAsFixed(1);
    return Column(
      children: [
        Text("${horas}h", style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Color(0xFF7A7A9A))),
      ],
    );
  }
}
