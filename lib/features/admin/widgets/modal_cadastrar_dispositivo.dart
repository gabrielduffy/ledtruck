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
  
  // Logic to generate next serial LT-2025-000X mock
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
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Cadastrar Dispositivo", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const _FieldLabel("Número de Série (Automático)"),
          AppTextField(label: '', hint: _serialMock, controller: TextEditingController(text: _serialMock)),
          const SizedBox(height: 16),
          const _FieldLabel("Endereço MAC"),
          AppTextField(label: '', hint: "Ex: AA:BB:CC:11:22:33", controller: _macController),
          const SizedBox(height: 16),
          const _FieldLabel("Modelo"),
          AppTextField(label: '', hint: "Modelo", controller: _modeloController),
          const SizedBox(height: 16),
          const _FieldLabel("Versão do Firmware"),
          AppTextField(label: '', hint: "Versão", controller: _firmwareController),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: AppButton(label: "Salvar no Estoque", onPressed: _onSave),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: const TextStyle(color: Color(0xFF7A7A9A), fontSize: 12)),
    );
  }
}
