import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/dispositivo_model.dart';
import '../providers/dispositivos_provider.dart';

class ModalHistoricoDispositivo extends ConsumerWidget {
  final AdminDispositivo dispositivo;
  const ModalHistoricoDispositivo({super.key, required this.dispositivo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosHistoricos = ref.watch(dispositivoHistoricoProvider);
    final historico = todosHistoricos.where((h) => h.numeroSerie == dispositivo.numeroSerie).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Histórico: ${dispositivo.numeroSerie}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (historico.isEmpty)
            const Expanded(child: Center(child: Text("Nenhum histórico encontrado para este dispositivo.", style: TextStyle(color: Color(0xFF7A7A9A)))))
          else
            Expanded(
              child: ListView.separated(
                itemCount: historico.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                itemBuilder: (context, index) {
                  final h = historico[index];
                  final installStr = DateFormat('dd/MM/yyyy HH:mm').format(h.dataInstalacao);
                  final removeStr = DateFormat('dd/MM/yyyy HH:mm').format(h.dataRemocao);
                  final duracao = h.dataRemocao.difference(h.dataInstalacao).inDays;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("Carro: ${h.carro}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Instalado em: $installStr", style: const TextStyle(color: Color(0xFF7A7A9A), fontSize: 12)),
                        Text("Removido em: $removeStr", style: const TextStyle(color: Color(0xFF7A7A9A), fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("Tempo de uso: $duracao dias", style: const TextStyle(color: Color(0xFF00E87A), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
