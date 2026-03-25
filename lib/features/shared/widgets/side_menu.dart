import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:led_truck/features/auth/providers/auth_provider.dart';
import 'package:led_truck/core/theme/app_theme.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta o provider de perfil para pegar o role
    final profile = ref.watch(profileProvider).value;
    final String currentPath = GoRouterState.of(context).uri.toString();
    
    // Fallback para admin caso carregando (ou usar 'franqueado' se preferir testar)
    final role = profile?.role ?? 'admin'; 

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      child: Column(
        children: [
          // CABEÇALHO DO MENU
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Icon(Icons.flash_on, color: AppTheme.primaryNeon, size: 32, shadows: [Shadow(color: AppTheme.primaryNeon.withValues(alpha: 0.5), blurRadius: 10)]),
                const SizedBox(width: 12),
                Text(
                  "LED TRUCK", 
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [Shadow(color: AppTheme.primaryNeon.withValues(alpha: 0.3), blurRadius: 8)]
                  )
                ),
              ],
            ),
          ),
          
          // ITENS DE MENU
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                if (role == 'admin') ...[
                  _MenuTile(label: "Dashboard", icon: Icons.dashboard_outlined, path: "/admin/dashboard", isSelected: currentPath == "/admin/dashboard"),
                  _MenuTile(label: "Dispositivos", icon: Icons.devices_outlined, path: "/admin/dispositivos", isSelected: currentPath == "/admin/dispositivos"),
                  _MenuTile(label: "Rastreamento", icon: Icons.map_outlined, path: "/admin/rastreamento", isSelected: currentPath.contains("/rastreamento")),
                  _MenuTile(label: "Franqueados", icon: Icons.business_outlined, path: "/admin/franqueados", isSelected: currentPath == "/admin/franqueados"),
                  _MenuTile(label: "Relatórios", icon: Icons.bar_chart_outlined, path: "/admin/relatorios", isSelected: currentPath == "/admin/relatorios"),
                  _MenuTile(label: "Usuários", icon: Icons.people_outline, path: "/admin/usuarios", isSelected: currentPath == "/admin/usuarios"),
                  _MenuTile(label: "Configurações", icon: Icons.settings_outlined, path: "/admin/configuracoes", isSelected: currentPath == "/admin/configuracoes"),
                ] else if (role == 'franqueado') ...[
                  _MenuTile(label: "Dashboard", icon: Icons.dashboard_outlined, path: "/franqueado/dashboard", isSelected: currentPath == "/franqueado/dashboard"),
                  _MenuTile(label: "Meus Carros", icon: Icons.directions_car_outlined, path: "/franqueado/carros", isSelected: currentPath == "/franqueado/carros"),
                  _MenuTile(label: "Campanhas", icon: Icons.campaign_outlined, path: "/franqueado/campanhas", isSelected: currentPath == "/franqueado/campanhas"),
                  _MenuTile(label: "Rastreamento", icon: Icons.map_outlined, path: "/franqueado/rastreamento", isSelected: currentPath.contains("/rastreamento")),
                  _MenuTile(label: "Configurações", icon: Icons.settings_outlined, path: "/admin/configuracoes", isSelected: currentPath == "/admin/configuracoes"),
                ] else if (role == 'operador') ...[
                  _MenuTile(label: "Dashboard", icon: Icons.dashboard_outlined, path: "/operador/dashboard", isSelected: currentPath == "/operador/dashboard"),
                  _MenuTile(label: "Configurações", icon: Icons.settings_outlined, path: "/admin/configuracoes", isSelected: currentPath == "/admin/configuracoes"),
                ] else if (role == 'anunciante') ...[
                  _MenuTile(label: "Dashboard", icon: Icons.dashboard_outlined, path: "/anunciante/dashboard", isSelected: currentPath == "/anunciante/dashboard"),
                  _MenuTile(label: "Relatórios", icon: Icons.bar_chart_outlined, path: "/anunciante/relatorios", isSelected: currentPath == "/anunciante/relatorios"),
                ] else ...[
                  _MenuTile(label: "Dashboard", icon: Icons.dashboard_outlined, path: "/", isSelected: true),
                ]
              ],
            ),
          ),

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
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        role.toUpperCase(),
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 10),
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
        color: isSelected ? AppTheme.primaryNeon : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
        shadows: isSelected ? [Shadow(color: AppTheme.primaryNeon.withValues(alpha: 0.4), blurRadius: 6)] : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () => context.go(path),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tileColor: isSelected ? AppTheme.primaryNeon.withValues(alpha: 0.1) : null,
      selectedTileColor: AppTheme.primaryNeon.withValues(alpha: 0.1),
    );
  }
}
