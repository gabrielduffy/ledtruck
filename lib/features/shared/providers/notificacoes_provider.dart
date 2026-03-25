import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificacaoItem {
  final String id;
  final String titulo;
  final String descricao;
  final bool isRead;
  final DateTime timestamp;

  NotificacaoItem({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.isRead = false,
    required this.timestamp,
  });
  
  NotificacaoItem copyWith({bool? isRead}) {
    return NotificacaoItem(
      id: id,
      titulo: titulo,
      descricao: descricao,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp,
    );
  }
}

class NotificacoesNotifier extends StateNotifier<List<NotificacaoItem>> {
  NotificacoesNotifier() : super(_initialMock);

  static final _initialMock = [
    NotificacaoItem(id: '6', titulo: 'Cobrança em Atraso', descricao: 'Franqueado João Silva — cobrança em atraso R\$497,00 — venceu em 10/03/2026', isRead: false, timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    NotificacaoItem(id: '7', titulo: 'Vencimento Próximo', descricao: 'Franqueado Carlos Lima — vencimento amanhã R\$497,00 — vence em 26/03/2026', isRead: false, timestamp: DateTime.now().subtract(const Duration(hours: 3))),
    NotificacaoItem(id: '1', titulo: 'Alerta Rastreamento', descricao: 'TRK-001 desligou às 14:32', isRead: false, timestamp: DateTime.now().subtract(const Duration(minutes: 10))),
    NotificacaoItem(id: '2', titulo: 'Campanha', descricao: 'Campanha Claro atingiu 90% das horas', isRead: false, timestamp: DateTime.now().subtract(const Duration(hours: 1))),
    NotificacaoItem(id: '3', titulo: 'Sistema', descricao: 'Novo franqueado: João Silva', isRead: true, timestamp: DateTime.now().subtract(const Duration(days: 1))),
    NotificacaoItem(id: '4', titulo: 'Alerta Dispositivo', descricao: 'Dispositivo LT-2025-0003 sem sinal', isRead: false, timestamp: DateTime.now().subtract(const Duration(days: 2))),
    NotificacaoItem(id: '5', titulo: 'Relatório', descricao: 'Relatório diário enviado', isRead: true, timestamp: DateTime.now().subtract(const Duration(days: 3))),
  ];

  void markAsRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }
}

final notificacoesProvider = StateNotifierProvider<NotificacoesNotifier, List<NotificacaoItem>>((ref) {
  return NotificacoesNotifier();
});

final unreadNotificacoesCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificacoesProvider);
  return list.where((n) => !n.isRead).length;
});
