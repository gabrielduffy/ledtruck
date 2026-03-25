import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_models.dart';

// MOCK DATA GENERATOR
final adminMetricsProvider = Provider<List<AdminMetric>>((ref) {
  return [
    AdminMetric(label: "Franqueados ativos", value: "3", icon: "people"),
    AdminMetric(label: "Carros ligados agora", value: "4", icon: "flash_on"),
    AdminMetric(label: "Campanhas em andamento", value: "8", icon: "ads_click"),
    AdminMetric(label: "Horas exibidas hoje", value: "42h 15m", icon: "schedule"),
  ];
});

final franqueadosProvider = Provider<List<AdminFranqueado>>((ref) {
  return [
    AdminFranqueado(id: "1", nome: "Led Truck Curitiba", cidade: "Curitiba", estado: "PR", carrosAtivos: 4, campanhasAtivas: 3),
    AdminFranqueado(id: "2", nome: "Led Truck Londrina", cidade: "Londrina", estado: "PR", carrosAtivos: 2, campanhasAtivas: 2),
    AdminFranqueado(id: "3", nome: "Led Truck Floripa", cidade: "Florianópolis", estado: "SC", carrosAtivos: 3, campanhasAtivas: 3),
  ];
});

final carrosMapaProvider = Provider<List<AdminCarro>>((ref) {
  return [
    AdminCarro(id: "c1", codigo: "LTC-01", veiculo: "Fiat Strada", placa: "ABC-1234", franqueadoNome: "Led Truck Curitiba", isOnline: true, latitude: -25.4284, longitude: -49.2733, tempoLigadoHoje: "2h 30m"),
    AdminCarro(id: "c2", codigo: "LTC-02", veiculo: "Fiat Strada", placa: "DEF-5678", franqueadoNome: "Led Truck Curitiba", isOnline: false, latitude: -25.4411, longitude: -49.2768, tempoLigadoHoje: "1h 15m"),
    AdminCarro(id: "c3", codigo: "LTL-01", veiculo: "VW Saveiro", placa: "GHI-9012", franqueadoNome: "Led Truck Londrina", isOnline: true, latitude: -23.3103, longitude: -51.1594, tempoLigadoHoje: "3h 05m"),
    AdminCarro(id: "c4", codigo: "LTF-01", veiculo: "Chevrolet Montana", placa: "JKL-3456", franqueadoNome: "Led Truck Floripa", isOnline: true, latitude: -27.5954, longitude: -48.5480, tempoLigadoHoje: "4h 45m"),
  ];
});

final eventsStreamProvider = StreamProvider<List<AdminEvento>>((ref) {
  final controller = StreamController<List<AdminEvento>>();
  
  final initialEvents = [
    AdminEvento(id: "e1", timestamp: DateTime.now().subtract(const Duration(minutes: 5)), franqueadoNome: "Curitiba", carroCodigo: "LTC-01", tipo: "ligou"),
    AdminEvento(id: "e2", timestamp: DateTime.now().subtract(const Duration(minutes: 15)), franqueadoNome: "Floripa", carroCodigo: "LTF-01", tipo: "desligou", duracao: "1h 20m"),
    AdminEvento(id: "e3", timestamp: DateTime.now().subtract(const Duration(minutes: 45)), franqueadoNome: "Londrina", carroCodigo: "LTL-01", tipo: "ligou"),
  ];

  controller.add(initialEvents);

  // Simular Novos Eventos em Tempo Real
  final timer = Timer.periodic(const Duration(seconds: 15), (t) {
    final newEvent = AdminEvento(
      id: "enew-${t.tick}",
      timestamp: DateTime.now(),
      franqueadoNome: t.tick % 2 == 0 ? "Curitiba" : "Londrina",
      carroCodigo: t.tick % 2 == 0 ? "LTC-02" : "LTL-02",
      tipo: t.tick % 3 == 0 ? "desligou" : "ligou",
      duracao: t.tick % 3 == 0 ? "45m" : null,
    );
    initialEvents.insert(0, newEvent);
    if (initialEvents.length > 50) initialEvents.removeLast();
    controller.add(List.from(initialEvents));
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
