import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dispositivo_model.dart';

class DispositivosNotifier extends StateNotifier<List<AdminDispositivo>> {
  DispositivosNotifier() : super([
    AdminDispositivo(
      id: '${DateTime.now().millisecondsSinceEpoch}_1',
      numeroSerie: 'LT-2025-0001',
      macAddress: 'AA:BB:CC:DD:EE:01',
      modelo: 'ESP32 DevKit v1',
      versaoFirmware: '1.2.4',
      status: 'instalado',
      carroVinculado: 'FIAT STRADA - ABC1234',
      franqueadoNome: 'João Silva',
      instaladoEm: DateTime.now().subtract(const Duration(days: 30)),
    ),
    AdminDispositivo(
      id: '${DateTime.now().millisecondsSinceEpoch}_2',
      numeroSerie: 'LT-2025-0002',
      macAddress: 'AA:BB:CC:DD:EE:02',
      modelo: 'ESP32 DevKit v1',
      versaoFirmware: '1.2.4',
      status: 'estoque',
    ),
    AdminDispositivo(
      id: '${DateTime.now().millisecondsSinceEpoch}_3',
      numeroSerie: 'LT-2025-0003',
      macAddress: 'AA:BB:CC:DD:EE:03',
      modelo: 'ESP32 DevKit v1',
      versaoFirmware: '1.2.3',
      status: 'manutencao',
    ),
     AdminDispositivo(
      id: '${DateTime.now().millisecondsSinceEpoch}_4',
      numeroSerie: 'LT-2024-0015',
      macAddress: 'AA:BB:CC:DD:EE:15',
      modelo: 'ESP32 DevKit v1',
      versaoFirmware: '1.2.2',
      status: 'inativo',
    ),
  ]);

  void addDispositivo(AdminDispositivo dispositivo) {
    state = [...state, dispositivo];
  }

  void updateDispositivo(AdminDispositivo dispositivo) {
    state = [
      for (final d in state)
        if (d.id == dispositivo.id) dispositivo else d
    ];
  }
}

final dispositivosProvider = StateNotifierProvider<DispositivosNotifier, List<AdminDispositivo>>((ref) {
  return DispositivosNotifier();
});

class DispositivoMetrics {
  final String label;
  final String value;
  final String icon;
  final String colorHex;
  
  DispositivoMetrics(this.label, this.value, this.icon, this.colorHex);
}

final dispositivosMetricsProvider = Provider<List<DispositivoMetrics>>((ref) {
  final devices = ref.watch(dispositivosProvider);
  final emEstoque = devices.where((d) => d.status == 'estoque').length;
  final instalados = devices.where((d) => d.status == 'instalado').length;
  final emManutencao = devices.where((d) => d.status == 'manutencao').length;

  return [
    DispositivoMetrics("EM ESTOQUE", emEstoque.toString(), "inventory_2", "2196F3"),
    DispositivoMetrics("INSTALADOS", instalados.toString(), "check_circle", "00E87A"),
    DispositivoMetrics("EM MANUTENÇÃO", emManutencao.toString(), "build", "FFC107"),
  ];
});

final dispositivoHistoricoProvider = Provider<List<DispositivoHistorico>>((ref) {
  return [
    DispositivoHistorico(
      numeroSerie: 'LT-2025-0001',
      carro: 'Montana - XYZ9876',
      dataInstalacao: DateTime.now().subtract(const Duration(days: 90)),
      dataRemocao: DateTime.now().subtract(const Duration(days: 30)),
    ),
     DispositivoHistorico(
      numeroSerie: 'LT-2025-0001',
      carro: 'Saveiro - DEF4567',
       dataInstalacao: DateTime.now().subtract(const Duration(days: 150)),
      dataRemocao: DateTime.now().subtract(const Duration(days: 91)),
     ),
  ];
});
