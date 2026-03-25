import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';
import 'package:led_truck/features/shared/providers/notificacoes_provider.dart';
import 'package:led_truck/features/admin/widgets/modais_usuarios.dart';

class AdminUsuariosScreen extends ConsumerStatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  ConsumerState<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends ConsumerState<AdminUsuariosScreen> {
  final List<Map<String, dynamic>> _usuariosMockados = [
    {'avatar': 'JS', 'nome': 'João Silva', 'email': 'joao@franquiasp.com.br', 'role': 'Franqueado', 'franqueado': 'Franqueado SP', 'status': 'Ativo', 'ultimo_acesso': 'Hoje, 14:32'},
    {'avatar': 'MS', 'nome': 'Maria Souza', 'email': 'maria@admin.com', 'role': 'Admin', 'franqueado': '-', 'status': 'Ativo', 'ultimo_acesso': 'Ontem, 09:15'},
    {'avatar': 'PT', 'nome': 'Pedro Tavares', 'email': 'pedro@operacao.com', 'role': 'Operador', 'franqueado': 'Franqueado SP', 'status': 'Inativo', 'ultimo_acesso': '20/03/2026'},
    {'avatar': 'AL', 'nome': 'Ana Lima', 'email': 'ana@mkt.com', 'role': 'Anunciante', 'franqueado': '-', 'status': 'Ativo', 'ultimo_acesso': 'Há 2 horas'},
    {'avatar': 'RC', 'nome': 'Roberto Costa', 'email': 'roberto@franquiasul.com', 'role': 'Franqueado', 'franqueado': 'Franqueado Sul', 'status': 'Ativo', 'ultimo_acesso': 'Há 5 dias'},
    {'avatar': 'LG', 'nome': 'Lucas Gomes', 'email': 'lucas@operacao.com', 'role': 'Operador', 'franqueado': 'Franqueado Sul', 'status': 'Ativo', 'ultimo_acesso': 'Hoje, 08:00'},
    {'avatar': 'FJ', 'nome': 'Fernanda Jorge', 'email': 'fe@admin.com', 'role': 'Admin', 'franqueado': '-', 'status': 'Ativo', 'ultimo_acesso': 'Hoje, 11:20'},
    {'avatar': 'BM', 'nome': 'Bruno Mendes', 'email': 'bruno@coca.com', 'role': 'Anunciante', 'franqueado': '-', 'status': 'Ativo', 'ultimo_acesso': 'Ontem, 16:40'},
  ];

  Color _getBadgeColor(String role) {
    switch (role) {
      case 'Admin': return Colors.purple;
      case 'Franqueado': return const Color(0xFFFF7200);
      case 'Operador': return Colors.blue;
      case 'Anunciante': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("USUÁRIOS", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: AppTheme.primaryNeon),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: Badge(
                backgroundColor: AppTheme.primaryNeon,
                textColor: Colors.white,
                label: Consumer(
                  builder: (context, ref, child) {
                    final count = ref.watch(unreadNotificacoesCountProvider);
                    if (count == 0) return const SizedBox.shrink();
                    return Text(count.toString());
                  },
                ),
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cards de estatísticas
                LayoutBuilder(
                  builder: (context, constraints) {
                    int colCount = constraints.maxWidth > 1000 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
                    return GridView.count(
                      crossAxisCount: colCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.2,
                      children: [
                        _infoCard("Total", "8", Colors.white),
                        _infoCard("Admins", "2", Colors.purple),
                        _infoCard("Franqueados", "2", const Color(0xFFFF7200)),
                        _infoCard("Operadores", "2", Colors.blue),
                        _infoCard("Anunciantes", "2", Colors.green),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 32),

                // Lista de Usuarios
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Diretório de Usuários", style: Theme.of(context).textTheme.headlineMedium),
                    AppButton(
                      label: "Novo Usuário",
                      icon: Icons.person_add,
                      onPressed: () {
                        showDialog(context: context, builder: (_) => const ModalNovoUsuario());
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Barra de busca e filtros
                Row(
                  children: [
                    const Expanded(child: AppTextField(label: "Buscar por nome ou e-mail", icon: Icons.search)),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        value: 'Todos',
                        decoration: InputDecoration(filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        dropdownColor: Theme.of(context).cardColor,
                        items: const [DropdownMenuItem(value: 'Todos', child: Text('Todas Roles')), DropdownMenuItem(value: 'Admin', child: Text('Admin'))],
                        onChanged: (v) {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        value: 'Todos',
                        decoration: InputDecoration(filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        dropdownColor: Theme.of(context).cardColor,
                        items: const [DropdownMenuItem(value: 'Todos', child: Text('Status')), DropdownMenuItem(value: 'Ativo', child: Text('Ativo')), DropdownMenuItem(value: 'Inativo', child: Text('Inativo'))],
                        onChanged: (v) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                AppCard(
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        showCheckboxColumn: false,
                        columns: const [
                          DataColumn(label: Text("Usuário")),
                          DataColumn(label: Text("Role")),
                          DataColumn(label: Text("Franqueado")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Último Acesso")),
                        ],
                        rows: _usuariosMockados.map((u) => DataRow(
                          onSelectChanged: (_) {
                            showDialog(context: context, builder: (_) => ModalUsuarioDetalhes(usuario: u));
                          },
                          cells: [
                          DataCell(Row(
                            children: [
                              CircleAvatar(radius: 16, backgroundColor: AppTheme.primaryNeon.withValues(alpha: 0.2), child: Text(u['avatar'], style: const TextStyle(fontSize: 10, color: AppTheme.primaryNeon))),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(u['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(u['email'], style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6))),
                                ],
                              )
                            ],
                          )),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: _getBadgeColor(u['role']).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: _getBadgeColor(u['role']).withValues(alpha: 0.3))),
                            child: Text(u['role'], style: TextStyle(color: _getBadgeColor(u['role']), fontSize: 11, fontWeight: FontWeight.bold)),
                          )),
                          DataCell(Text(u['franqueado'])),
                          DataCell(Row(
                            children: [
                              Icon(Icons.circle, size: 10, color: u['status'] == 'Ativo' ? Colors.green : Colors.red),
                              const SizedBox(width: 6),
                              Text(u['status']),
                            ],
                          )),
                          DataCell(Text(u['ultimo_acesso'])),
                        ])).toList(),
                      ),
                    ),
                  )
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value, Color color) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Icon(Icons.people, color: color.withValues(alpha: 0.5), size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      )
    );
  }
}
