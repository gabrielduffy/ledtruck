import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeoPoint {
  final double lat;
  final double lng;
  const GeoPoint(this.lat, this.lng);
}

class RastreamentoPonto {
  final GeoPoint posicao;
  final double velocidade;
  final bool painelLigado;
  final DateTime horario;

  RastreamentoPonto({
    required this.posicao,
    required this.velocidade,
    required this.painelLigado,
    required this.horario,
  });
}

class RastreamentoMockData {
  final String idCarro;
  final String placa;
  final String cidade;
  final List<RastreamentoPonto> rota;
  final double kmTotal;
  final double maxVelocidade;
  final double mediaVelocidade;
  final int minutosMovimento;
  final int minutosParado;
  final int minutosLigado;
  final List<Map<String, dynamic>> historicoKms; // { 'dia': 'SEG', 'km': 150 }

  RastreamentoMockData({
    required this.idCarro,
    required this.placa,
    required this.cidade,
    required this.rota,
    required this.kmTotal,
    required this.maxVelocidade,
    required this.mediaVelocidade,
    required this.minutosMovimento,
    required this.minutosParado,
    required this.minutosLigado,
    required this.historicoKms,
  });
}

final rastreamentoListProvider = Provider<List<RastreamentoMockData>>((ref) {
  // Simulação de dados para SP
  final rotaSP = [
    RastreamentoPonto(posicao: const GeoPoint(-23.5505, -46.6333), velocidade: 40, painelLigado: true, horario: DateTime.now().subtract(const Duration(hours: 2))),
    RastreamentoPonto(posicao: const GeoPoint(-23.5515, -46.6343), velocidade: 45, painelLigado: true, horario: DateTime.now().subtract(const Duration(minutes: 110))),
    RastreamentoPonto(posicao: const GeoPoint(-23.5525, -46.6353), velocidade: 0, painelLigado: true, horario: DateTime.now().subtract(const Duration(minutes: 100))),
    RastreamentoPonto(posicao: const GeoPoint(-23.5535, -46.6363), velocidade: 50, painelLigado: false, horario: DateTime.now().subtract(const Duration(minutes: 90))),
    RastreamentoPonto(posicao: const GeoPoint(-23.5545, -46.6373), velocidade: 60, painelLigado: true, horario: DateTime.now().subtract(const Duration(minutes: 80))),
  ];

  return [
    RastreamentoMockData(
      idCarro: 'c1',
      placa: 'STRADA - ABC-1234',
      cidade: 'São Paulo - SP',
      rota: rotaSP,
      kmTotal: 125.4,
      maxVelocidade: 85.0,
      mediaVelocidade: 42.5,
      minutosMovimento: 340,
      minutosParado: 120,
      minutosLigado: 400,
      historicoKms: [
        {'dia': '18', 'km': 120},
        {'dia': '19', 'km': 150},
        {'dia': '20', 'km': 90},
        {'dia': '21', 'km': 200},
        {'dia': '22', 'km': 180},
        {'dia': '23', 'km': 210},
        {'dia': '24', 'km': 125},
      ],
    ),
    RastreamentoMockData(
      idCarro: 'c2',
      placa: 'MONTANA - XYZ-9876',
      cidade: 'Curitiba - PR',
      rota: [
        RastreamentoPonto(posicao: const GeoPoint(-25.4284, -49.2733), velocidade: 60, painelLigado: true, horario: DateTime.now().subtract(const Duration(hours: 1))),
        RastreamentoPonto(posicao: const GeoPoint(-25.4294, -49.2743), velocidade: 65, painelLigado: true, horario: DateTime.now().subtract(const Duration(minutes: 50))),
      ],
      kmTotal: 84.2,
      maxVelocidade: 70.0,
      mediaVelocidade: 35.0,
      minutosMovimento: 200,
      minutosParado: 50,
      minutosLigado: 220,
      historicoKms: [
        {'dia': '18', 'km': 80},
        {'dia': '19', 'km': 85},
        {'dia': '20', 'km': 90},
        {'dia': '21', 'km': 75},
        {'dia': '22', 'km': 100},
        {'dia': '23', 'km': 110},
        {'dia': '24', 'km': 84},
      ],
    ),
    RastreamentoMockData(
      idCarro: 'c3',
      placa: 'SAVEIRO - DEF-4567',
      cidade: 'Florianópolis - SC',
      rota: [
        RastreamentoPonto(posicao: const GeoPoint(-27.5954, -48.5480), velocidade: 40, painelLigado: true, horario: DateTime.now().subtract(const Duration(hours: 2))),
        RastreamentoPonto(posicao: const GeoPoint(-27.6000, -48.5500), velocidade: 50, painelLigado: false, horario: DateTime.now().subtract(const Duration(minutes: 90))),
      ],
      kmTotal: 65.0,
      maxVelocidade: 60.0,
      mediaVelocidade: 32.2,
      minutosMovimento: 180,
      minutosParado: 30,
      minutosLigado: 190,
      historicoKms: [
        {'dia': '18', 'km': 60},
        {'dia': '19', 'km': 50},
        {'dia': '20', 'km': 80},
        {'dia': '21', 'km': 45},
        {'dia': '22', 'km': 70},
        {'dia': '23', 'km': 90},
        {'dia': '24', 'km': 65},
      ],
    ),
  ];
});

final selectedCarroRastreamentoProvider = StateProvider<String?>((ref) => 'c1');
