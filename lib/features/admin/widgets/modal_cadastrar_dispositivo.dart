import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/features/admin/models/dispositivo_model.dart';
import 'package:led_truck/features/admin/providers/dispositivos_provider.dart';

class ModalCadastrarDispositivo extends ConsumerStatefulWidget {
  const ModalCadastrarDispositivo({super.key});

  @override
  ConsumerState<ModalCadastrarDispositivo> createState() => _ModalCadastrarDispositivoState();
}

class _ModalCadastrarDispositivoState extends ConsumerState<ModalCadastrarDispositivo> {
  final _macController = TextEditingController();
  final _modeloController = TextEditingController(text: 'ESP32 DevKit v1');
  final _firmwareController = TextEditingController(text: '1.0.0');
  
  String _serialMock = "LT-2025-0004";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = ref.read(dispositivosProvider).length + 1;
      setState(() {
        _serialMock = "LT-2025-${size.toString().padLeft(4, '0')}";
      });
    });
  }

  void _onSave() {
    final novo = AdminDispositivo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      numeroSerie: _serialMock,
      macAddress: _macController.text.isNotEmpty ? _macController.text : '00:00:00:00:00:00',
      modelo: _modeloController.text,
      versaoFirmware: _firmwareController.text,
      status: 'estoque',
    );
    ref.read(dispositivosProvider.notifier).addDispositivo(novo);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dispositivo cadastrado no estoque!'), backgroundColor: Color(0xFF00E87A)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24, 
        left: 24, right: 24, top: 24
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Cadastrar Dispositivo", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 24),
          AbsorbPointer(child: AppTextField(label: "Número de Série (Automático)", icon: Icons.tag, hint: _serialMock, controller: TextEditingController(text: _serialMock))),
          const SizedBox(height: 8),
          AppTextField(label: "Endereço MAC", icon: Icons.router, hint: "Ex: AA:BB:CC:11:22:33", controller: _macController),
          const SizedBox(height: 8),
          AppTextField(label: "Modelo", icon: Icons.memory, hint: "Modelo", controller: _modeloController),
          const SizedBox(height: 8),
          AppTextField(label: "Versão do Firmware", icon: Icons.system_update, hint: "Versão", controller: _firmwareController),
          const SizedBox(height: 8),
          AbsorbPointer(child: AppTextField(label: "Status inicial", icon: Icons.inventory_2, controller: TextEditingController(text: 'Estoque'))),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E87A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text("Salvar no Estoque", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
