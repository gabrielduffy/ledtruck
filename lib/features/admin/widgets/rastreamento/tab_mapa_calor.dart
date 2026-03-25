import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import '../../providers/rastreamento_provider.dart';

class TabMapaCalor extends ConsumerWidget {
  const TabMapaCalor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(rastreamentoListProvider);
    final selectedId = ref.watch(selectedCarroRastreamentoProvider);
    final activeData = list.firstWhere((e) => e.idCarro == selectedId, orElse: () => list.first);

    if (activeData.rota.isEmpty) {
      return const Center(child: Text("Sem rota disponível", style: TextStyle(color: Colors.white)));
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: activeData.rota.first.posicao,
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
           urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
           subdomains: const ['a', 'b', 'c', 'd'],
        ),
        // Simulating a heatmap with multiple large transparent circle markers
        CircleLayer(
          circles: activeData.rota.map((p) {
             return CircleMarker(
               point: p.posicao,
               color: Colors.redAccent.withOpacity(0.3),
               borderColor: Colors.transparent,
               radius: 35, // Raio expandido para dar o overlay de calor
             );
          }).toList(),
        )
      ],
    );
  }
}
