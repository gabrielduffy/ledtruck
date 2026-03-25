import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final currentPath = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flash_on, color: AppTheme.primaryNeon, size: 40,
                     shadows: [BoxShadow(color: AppTheme.primaryNeon.withOpacity(0.5), blurRadius: 10)]
                ),
                const SizedBox(height: 8),
                Text(
                  "LED TRUCK",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: AppTheme.primaryNeon.withOpacity(0.3), blurRadius: 8)
                    ]
                  ),
                ),
              ],
            ),
          ),
          _MenuTile(
            label: "Dashboard",
            icon: Icons.dashboard_outlined,
            path: "/admin/dashboard",
            isSelected: currentPath == "/admin/dashboard",
          ),
          _MenuTile(
            label: "Dispositivos",
            icon: Icons.devices_outlined,
            path: "/admin/dispositivos",
            isSelected: currentPath == "/admin/dispositivos",
          ),
          _MenuTile(
            label: "Rastreamento",
            icon: Icons.map_outlined,
            path: "/admin/rastreamento",
            isSelected: currentPath.contains("/rastreamento"),
          ),
          _MenuTile(
            label: "Franqueados",
            icon: Icons.business_outlined,
            path: "/admin/franqueados",
            isSelected: currentPath == "/admin/franqueados",
          ),
          _MenuTile(
            label: "Relatórios",
            icon: Icons.bar_chart_outlined,
            path: "/admin/relatorios",
            isSelected: currentPath == "/admin/relatorios",
          ),
          _MenuTile(
            label: "Integrações",
            icon: Icons.sync_alt_outlined,
            path: "/admin/integracoes",
            isSelected: currentPath == "/admin/integracoes",
          ),
          _MenuTile(
            label: "Configurações",
            icon: Icons.settings_outlined,
            path: "/admin/configuracoes",
            isSelected: currentPath == "/admin/configuracoes",
          ),
          const Spacer(),
          const Divider(color: Colors.white10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF1A1A26),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile?.nome ?? "Usuário",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        profile?.role.toUpperCase() ?? "ADMIN",
                        style: const TextStyle(color: Color(0xFF7A7A9A), fontSize: 10),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                  icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String path;
  final bool isSelected;

  const _MenuTile({
    required this.label,
    required this.icon,
    required this.path,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryNeon : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
        shadows: isSelected ? [BoxShadow(color: AppTheme.primaryNeon.withOpacity(0.4), blurRadius: 6)] : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () => context.go(path),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: isSelected ? AppTheme.primaryNeon.withOpacity(0.1) : null,
      selectedTileColor: AppTheme.primaryNeon.withOpacity(0.1),
    );
  }
}
