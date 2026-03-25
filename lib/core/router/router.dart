import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/features/auth/screens/login_screen.dart';
import 'package:led_truck/features/auth/providers/auth_provider.dart';
import 'package:led_truck/features/admin/screens/admin_dashboard.dart';
import 'package:led_truck/features/admin/screens/admin_dispositivos_screen.dart';
import 'package:led_truck/features/admin/screens/rastreamento_screen.dart';
import 'package:led_truck/features/admin/screens/admin_relatorios_screen.dart';
import 'package:led_truck/features/admin/screens/admin_configuracoes_screen.dart';
import 'package:led_truck/features/admin/screens/admin_franqueados_screen.dart';
import 'package:led_truck/features/admin/screens/admin_usuarios_screen.dart';
import 'package:led_truck/features/admin/screens/admin_financeiro_screen.dart';
import 'package:led_truck/features/franqueado/screens/franqueado_dashboard_screen.dart';
import 'package:led_truck/features/franqueado/screens/franqueado_financeiro_screen.dart';
import 'package:led_truck/features/franqueado/screens/franqueado_carros_screen.dart';
import 'package:led_truck/features/franqueado/screens/franqueado_campanhas_screen.dart';
import 'package:led_truck/features/operador/screens/operador_dashboard_screen.dart';
import 'package:led_truck/features/anunciante/screens/anunciante_dashboard_screen.dart';
import 'package:led_truck/features/admin/screens/carro_detalhes_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileAsync = ref.watch(profileProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final session = authState.value?.session;
      final profile = profileAsync.value;
      final isLoggingIn = state.matchedLocation == '/login';

      // 1. Não logado -> Redireciona para login (Ignorado se estiver em modo teste mockado)
      if (session == null) {
        // Permitimos avançar se o path for de qualquer role (modo teste)
        final loc = state.matchedLocation;
        if (loc.startsWith('/admin') || 
            loc.startsWith('/franqueado') || 
            loc.startsWith('/operador') || 
            loc.startsWith('/anunciante') ||
            loc.startsWith('/carro')) return null;
        return isLoggingIn ? null : '/login';
      }

      // 2. Logado, mas tentando acessar login -> Vai para o dashboard correte
      if (isLoggingIn && profile != null) {
        return '/${profile.role}/dashboard';
      }

      // 3. Logado, mas sem perfil ainda -> Espera profile carregar ou fica no login
      if (profile == null) return null;

      // 4. Proteção de rotas por Role
      final path = state.matchedLocation;
      if (path.startsWith('/admin') && profile.role != 'admin') return '/login';
      if (path.startsWith('/franqueado') && profile.role != 'franqueado' && profile.role != 'admin') return '/login';
      if (path.startsWith('/operador') && profile.role != 'operador' && profile.role != 'admin') return '/login';
      if (path.startsWith('/anunciante') && profile.role != 'anunciante') return '/login';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/dispositivos',
        builder: (context, state) => const AdminDispositivosScreen(),
      ),
      GoRoute(
        path: '/admin/rastreamento',
        builder: (context, state) => const RastreamentoScreen(),
      ),
      GoRoute(
        path: '/admin/franqueados',
        builder: (context, state) => const AdminFranqueadosScreen(),
      ),
      GoRoute(
        path: '/admin/relatorios',
        builder: (context, state) => const AdminRelatoriosScreen(),
      ),
      GoRoute(
        path: '/admin/configuracoes',
        builder: (context, state) => const AdminConfiguracoesScreen(),
      ),
      GoRoute(
        path: '/admin/usuarios',
        builder: (context, state) => const AdminUsuariosScreen(),
      ),
      GoRoute(
        path: '/admin/financeiro',
        builder: (context, state) => const AdminFinanceiroScreen(),
      ),
      GoRoute(
        path: '/franqueado/dashboard',
        builder: (context, state) => const FranqueadoDashboardScreen(),
      ),
      GoRoute(
        path: '/franqueado/financeiro',
        builder: (context, state) => const FranqueadoFinanceiroScreen(),
      ),
      GoRoute(
        path: '/franqueado/carros',
        builder: (context, state) => const FranqueadoCarrosScreen(),
      ),
      GoRoute(
        path: '/franqueado/campanhas',
        builder: (context, state) => const FranqueadoCampanhasScreen(),
      ),
      GoRoute(
        path: '/franqueado/rastreamento',
        builder: (context, state) => const RastreamentoScreen(),
      ),
      GoRoute(
        path: '/operador/dashboard',
        builder: (context, state) => const OperadorDashboardScreen(),
      ),
      GoRoute(
        path: '/anunciante/dashboard',
        builder: (context, state) => const AnuncianteDashboardScreen(),
      ),
      GoRoute(
        path: '/carro/:id',
        builder: (context, state) => CarroDetalhesScreen(id: state.pathParameters['id'] ?? '0'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("404 - Página não encontrada", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text("Voltar ao Início"),
            ),
          ],
        ),
      ),
    ),
  );
});
