import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsDrawer extends StatelessWidget {
  const NotificationsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Carro Ligado',
        'desc': 'Fiat Strada BDQ-2099 iniciou trajeto em SP.',
        'time': 'Agora',
        'icon': Icons.power,
        'color': AppTheme.statusLigado,
        'unread': true,
      },
      {
        'title': 'Campanha Concluída',
        'desc': 'Campanha "Verão" atingiu 100% (200h).',
        'time': 'Há 2 min',
        'icon': Icons.check_circle,
        'color': AppTheme.statusEstoque,
        'unread': true,
      },
      {
        'title': 'Campanha Vencendo',
        'desc': 'Campanha "Inverno" encerra em 2 dias.',
        'time': 'Há 1 hora',
        'icon': Icons.warning_amber_rounded,
        'color': AppTheme.statusManutencao,
        'unread': false,
      },
    ];

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 16, left: 16, right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Notificações",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Marcar todas lidas", style: TextStyle(color: AppTheme.primaryNeon, fontSize: 12)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: notifications.length,
              separatorBuilder: (context, i) => Divider(color: Theme.of(context).dividerColor, height: 1),
              itemBuilder: (context, i) {
                final notif = notifications[i];
                final unread = notif['unread'] as bool;
                return Container(
                  color: unread ? AppTheme.primaryNeon.withOpacity(0.05) : Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: (notif['color'] as Color).withOpacity(0.15),
                      child: Icon(notif['icon'] as IconData, color: notif['color'] as Color, size: 20),
                    ),
                    title: Text(
                      notif['title'] as String,
                      style: TextStyle(fontWeight: unread ? FontWeight.bold : FontWeight.normal, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notif['desc'] as String, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(notif['time'] as String, style: const TextStyle(color: AppTheme.textSecondaryLight, fontSize: 10)),
                            if (unread)
                               InkWell(
                                 onTap: () {},
                                 child: const Text("Marcar como lida", style: TextStyle(color: AppTheme.primaryNeon, fontSize: 10, fontWeight: FontWeight.bold)),
                               )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
