class AdminMetric {
  final String label;
  final String value;
  final String icon;

  AdminMetric({required this.label, required this.value, required this.icon});
}

class AdminFranqueado {
  final String id;
  final String nome;
  final String cidade;
  final String estado;
  final int carrosAtivos;
  final int campanhasAtivas;

  AdminFranqueado({
    required this.id,
    required this.nome,
    required this.cidade,
    required this.estado,
    required this.carrosAtivos,
    required this.campanhasAtivas,
  });
}

class AdminCarro {
  final String id;
  final String codigo;
  final String veiculo;
  final String placa;
  final String franqueadoNome;
  final bool isOnline;
  final double latitude;
  final double longitude;
  final String tempoLigadoHoje;

  AdminCarro({
    required this.id,
    required this.codigo,
    required this.veiculo,
    required this.placa,
    required this.franqueadoNome,
    required this.isOnline,
    required this.latitude,
    required this.longitude,
    required this.tempoLigadoHoje,
  });
}

class AdminEvento {
  final String id;
  final DateTime timestamp;
  final String franqueadoNome;
  final String carroCodigo;
  final String tipo; // 'ligou' ou 'desligou'
  final String? duracao;

  AdminEvento({
    required this.id,
    required this.timestamp,
    required this.franqueadoNome,
    required this.carroCodigo,
    required this.tipo,
    this.duracao,
  });
}
