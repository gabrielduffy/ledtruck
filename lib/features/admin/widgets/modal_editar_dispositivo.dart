import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/features/admin/models/dispositivo_model.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/core/theme/app_theme.dart';

class ModalEditarDispositivo extends ConsumerStatefulWidget {
  final AdminDispositivo dispositivo;

  const ModalEditarDispositivo({super.key, required this.dispositivo});

  @override
  ConsumerState<ModalEditarDispositivo> createState() => _ModalEditarDispositivoState();
}

class _ModalEditarDispositivoState extends ConsumerState<ModalEditarDispositivo> {
  late TextEditingController modeloCtrl;
  late TextEditingController firmwareCtrl;
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    modeloCtrl = TextEditingController(text: widget.dispositivo.modelo);
    firmwareCtrl = TextEditingController(text: widget.dispositivo.versaoFirmware);
    selectedStatus = widget.dispositivo.status;
  }

  @override
  void dispose() {
    modeloCtrl.dispose();
    firmwareCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dispositivo atualizado com sucesso!'), backgroundColor: AppTheme.primaryNeon),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Editar Dispositivo", style: Theme.of(context).textTheme.headlineMedium),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            Text("Série: ${widget.dispositivo.numeroSerie}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
              controller: modeloCtrl,
              decoration: InputDecoration(
                labelText: "Modelo",
                prefixIcon: const Icon(Icons.devices),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: firmwareCtrl,
              decoration: InputDecoration(
                labelText: "Firmware",
                prefixIcon: const Icon(Icons.system_update),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              decoration: InputDecoration(
                labelText: "Status",
                prefixIcon: const Icon(Icons.info),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              dropdownColor: Theme.of(context).cardColor,
              items: const [
                DropdownMenuItem(value: 'estoque', child: Text('Estoque')),
                DropdownMenuItem(value: 'instalado', child: Text('Instalado')),
                DropdownMenuItem(value: 'manutencao', child: Text('Manutenção')),
                DropdownMenuItem(value: 'inativo', child: Text('Inativo')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => selectedStatus = val);
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                ),
                const SizedBox(width: 16),
                AppButton(
                  label: "Salvar",
                  onPressed: _salvar,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
