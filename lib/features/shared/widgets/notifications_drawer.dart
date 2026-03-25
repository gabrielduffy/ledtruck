import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/features/shared/providers/notificacoes_provider.dart';
import 'package:led_truck/core/utils/date_formatter.dart';

class NotificationsDrawer extends ConsumerWidget {
  const NotificationsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificacoesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  onPressed: () => ref.read(notificacoesProvider.notifier).markAllAsRead(),
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
                final unread = !notif.isRead;
                return Opacity(
                  opacity: unread ? 1.0 : 0.5,
                  child: Container(
                    color: unread ? AppTheme.primaryNeon.withOpacity(0.05) : Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryNeon.withOpacity(0.15),
                        child: const Icon(Icons.notifications, color: AppTheme.primaryNeon, size: 20),
                      ),
                      title: Text(
                        notif.titulo,
                        style: TextStyle(fontWeight: unread ? FontWeight.bold : FontWeight.normal, fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notif.descricao, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormatter.dateTime(notif.timestamp), style: TextStyle(color: isDark ? AppTheme.textSecondaryLight : AppTheme.textSecondaryDark, fontSize: 10)),
                              if (unread)
                                 InkWell(
                                   onTap: () => ref.read(notificacoesProvider.notifier).markAsRead(notif.id),
                                   child: const Row(
                                     children: [
                                       Icon(Icons.check, size: 14, color: AppTheme.primaryNeon),
                                       SizedBox(width: 4),
                                       Text("Lida", style: TextStyle(color: AppTheme.primaryNeon, fontSize: 10, fontWeight: FontWeight.bold)),
                                     ],
                                   ),
                                 )
                            ],
                          ),
                        ],
                      ),
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
