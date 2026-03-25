import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/base_components.dart';
import '../models/dispositivo_model.dart';
import '../providers/dispositivos_provider.dart';

class ModalVincularCarro extends ConsumerStatefulWidget {
  final AdminDispositivo dispositivo;
  const ModalVincularCarro({super.key, required this.dispositivo});

  @override
  ConsumerState<ModalVincularCarro> createState() => _ModalVincularCarroState();
}

class _ModalVincularCarroState extends ConsumerState<ModalVincularCarro> {
  String? selectedFranqueado;
  String? selectedCarro;

  final franqueados = ['João Silva', 'Maria Souza', 'Pedro Costa'];
  final carros = ['FIAT STRADA - ABC1234', 'MONTANA - XYZ9876', 'SAVEIRO - DEF4567'];

  void _onVincular() {
    if (selectedFranqueado == null || selectedCarro == null) return;
    
    final updated = widget.dispositivo.copyWith(
      status: 'instalado',
      franqueadoNome: selectedFranqueado,
      carroVinculado: selectedCarro,
      instaladoEm: DateTime.now(),
    );
    
    ref.read(dispositivosProvider.notifier).updateDispositivo(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dispositivo vinculado com sucesso!'), backgroundColor: Color(0xFF00E87A)),
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
          Text("Vincular Dispositivo: ${widget.dispositivo.numeroSerie}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text("Selecione o Franqueado", style: TextStyle(color: Color(0xFF7A7A9A), fontSize: 12)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            dropdownColor: const Color(0xFF1A1A26),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFF1A1A26),
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
            ),
            value: selectedFranqueado,
            items: franqueados.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (val) => setState(() => selectedFranqueado = val),
          ),
          const SizedBox(height: 16),
          const Text("Selecione o Carro", style: TextStyle(color: Color(0xFF7A7A9A), fontSize: 12)),
          const SizedBox(height: 8),
           DropdownButtonFormField<String>(
            dropdownColor: const Color(0xFF1A1A26),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFF1A1A26),
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
            ),
            value: selectedCarro,
            items: carros.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() => selectedCarro = val),
          ),
          const SizedBox(height: 32),
          SizedBox(
             width: double.infinity,
             child: AppButton(
               label: "Confirmar Vinculação", 
               onPressed: selectedFranqueado != null && selectedCarro != null ? _onVincular : () {}
             ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
