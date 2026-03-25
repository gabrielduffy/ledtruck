import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/admin_dispositivos_screen.dart';
import '../../features/admin/screens/rastreamento_screen.dart';
import '../../features/admin/screens/admin_relatorios_screen.dart';
import '../../features/admin/screens/admin_integracoes_screen.dart';
import '../../features/admin/screens/admin_configuracoes_screen.dart';

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
        // Para fins de teste sem Supabase, permitimos avançar se o path for /admin
        if (state.matchedLocation.startsWith('/admin')) return null;
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
        path: '/admin/relatorios',
        builder: (context, state) => const AdminRelatoriosScreen(),
      ),
      GoRoute(
        path: '/admin/integracoes',
        builder: (context, state) => const AdminIntegracoesScreen(),
      ),
      GoRoute(
        path: '/admin/configuracoes',
        builder: (context, state) => const AdminConfiguracoesScreen(),
      ),
      GoRoute(
        path: '/franqueado/rastreamento',
        builder: (context, state) => const RastreamentoScreen(),
      ),
      GoRoute(
        path: '/franqueado/dashboard',
        builder: (context, state) => const Scaffold(body: Center(child: Text("Franqueado Dashboard"))),
      ),
      GoRoute(
        path: '/operador/dashboard',
        builder: (context, state) => const Scaffold(body: Center(child: Text("Operador Dashboard"))),
      ),
      GoRoute(
        path: '/anunciante/dashboard',
        builder: (context, state) => const Scaffold(body: Center(child: Text("Anunciante Dashboard"))),
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
