import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/features/admin/models/dispositivo_model.dart';
import 'package:led_truck/features/admin/providers/dispositivos_provider.dart';

class ModalDesvincularDispositivo extends ConsumerStatefulWidget {
  final AdminDispositivo dispositivo;
  const ModalDesvincularDispositivo({super.key, required this.dispositivo});

  @override
  ConsumerState<ModalDesvincularDispositivo> createState() => _ModalDesvincularDispositivoState();
}

class _ModalDesvincularDispositivoState extends ConsumerState<ModalDesvincularDispositivo> {
  String selectedStatus = 'estoque';

  void _onConfirm() {
    final updated = widget.dispositivo.copyWith(
      status: selectedStatus,
      franqueadoNome: null,
      carroVinculado: null,
      instaladoEm: null, // Clears the DateTime since we must allow null
    );
    ref.read(dispositivosProvider.notifier).updateDispositivo(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dispositivo desvinculado com sucesso!'), backgroundColor: Color(0xFF00E87A)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Desvincular Dispositivo", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Tem certeza que deseja remover o dispositivo ${widget.dispositivo.numeroSerie} do carro ${widget.dispositivo.carroVinculado}?",
            style: const TextStyle(color: Color(0xFF7A7A9A)),
          ),
          const SizedBox(height: 24),
          const Text("Para onde este dispositivo vai?", style: TextStyle(color: Color(0xFF7A7A9A), fontSize: 12)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            dropdownColor: const Color(0xFF1A1A26),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFF1A1A26),
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
            ),
            value: selectedStatus,
            items: const [
              DropdownMenuItem(value: 'estoque', child: Text('Retornar ao Estoque')),
              DropdownMenuItem(value: 'manutencao', child: Text('Enviar para Manutenção')),
              DropdownMenuItem(value: 'inativo', child: Text('Marcar como Inativo')),
            ],
            onChanged: (val) => setState(() => selectedStatus = val!),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: "Confirmar Desvinculação",
              onPressed: _onConfirm,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
