import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import 'package:intl/intl.dart';
import '../../providers/rastreamento_provider.dart';

class TabRota extends ConsumerWidget {
  const TabRota({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(rastreamentoListProvider);
    final selectedId = ref.watch(selectedCarroRastreamentoProvider);
    final activeData = list.firstWhere((e) => e.idCarro == selectedId, orElse: () => list.first);

    if (activeData.rota.isEmpty) {
      return const Center(child: Text("Sem rota disponível", style: TextStyle(color: Colors.white)));
    }

    // Dividimos por cores de painel se precisássemos na Polyline, mas aqui usaremos cor única com markers exibindo status e velocidade.
    return FlutterMap(
      options: MapOptions(
        initialCenter: activeData.rota.first.posicao,
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: activeData.rota.map((r) => r.posicao).toList(),
              color: const Color(0xFF00E87A),
              strokeWidth: 4.0,
            ),
          ],
        ),
        MarkerLayer(
          markers: activeData.rota.map((p) {
            return Marker(
              point: p.posicao,
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A26),
                      title: const Text("Ponto GPS", style: TextStyle(color: Colors.white)),
                      content: Text(
                        "Horário: ${DateFormat('HH:mm:ss').format(p.horario)}\n"
                        "Velocidade: ${p.velocidade} km/h\n"
                        "Painel: ${p.painelLigado ? 'LIGADO' : 'DESLIGADO'}",
                        style: const TextStyle(color: Color(0xFF7A7A9A)),
                      ),
                      actions: [
                        TextButton(
                           onPressed: () => Navigator.pop(context), 
                           child: const Text("OK", style: TextStyle(color: Color(0xFF00E87A)))
                        )
                      ],
                    )
                  );
                },
                child: Icon(Icons.circle, color: p.painelLigado ? const Color(0xFF00E87A) : Colors.grey, size: 12),
              ),
            );
          }).toList(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: activeData.rota.first.posicao,
              width: 40,
              height: 40,
              child: const Icon(Icons.outlined_flag, color: Colors.blueAccent, size: 32),
            ),
            Marker(
              point: activeData.rota.last.posicao,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, color: Colors.redAccent, size: 32),
            ),
          ]
        )
      ],
    );
  }
}
