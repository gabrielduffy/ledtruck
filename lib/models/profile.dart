class AppProfile {
  final String id;
  final String nome;
  final String role;
  final String? franqueadoId;

  AppProfile({
    required this.id,
    required this.nome,
    required this.role,
    this.franqueadoId,
  });

  factory AppProfile.fromMap(Map<String, dynamic> map) {
    return AppProfile(
      id: map['id'],
      nome: map['nome'] ?? '',
      role: map['role'] ?? 'operador',
      franqueadoId: map['franqueado_id'],
    );
  }
}
