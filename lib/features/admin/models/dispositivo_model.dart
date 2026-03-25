import 'package:flutter/material.dart';

class AdminDispositivo {
  final String id;
  final String numeroSerie;
  final String macAddress;
  final String modelo;
  final String versaoFirmware;
  final String status; // 'estoque', 'instalado', 'manutencao', 'inativo'
  final String? carroVinculado;
  final String? franqueadoNome;
  final DateTime? instaladoEm;

  AdminDispositivo({
    required this.id,
    required this.numeroSerie,
    required this.macAddress,
    required this.modelo,
    required this.versaoFirmware,
    required this.status,
    this.carroVinculado,
    this.franqueadoNome,
    this.instaladoEm,
  });

  AdminDispositivo copyWith({
    String? id,
    String? numeroSerie,
    String? macAddress,
    String? modelo,
    String? versaoFirmware,
    String? status,
    String? carroVinculado,
    String? franqueadoNome,
    DateTime? instaladoEm,
  }) {
    return AdminDispositivo(
      id: id ?? this.id,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      macAddress: macAddress ?? this.macAddress,
      modelo: modelo ?? this.modelo,
      versaoFirmware: versaoFirmware ?? this.versaoFirmware,
      status: status ?? this.status,
      carroVinculado: carroVinculado ?? this.carroVinculado,
      franqueadoNome: franqueadoNome ?? this.franqueadoNome,
      instaladoEm: instaladoEm ?? this.instaladoEm,
    );
  }
}

class DispositivoHistorico {
  final String numeroSerie;
  final String carro;
  final DateTime dataInstalacao;
  final DateTime dataRemocao;

  DispositivoHistorico({
    required this.numeroSerie,
    required this.carro,
    required this.dataInstalacao,
    required this.dataRemocao,
  });
}
