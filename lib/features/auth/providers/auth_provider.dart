import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/profile.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

final profileProvider = FutureProvider<AppProfile?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final supabase = ref.watch(supabaseProvider);

  final session = authState.value?.session;
  if (session == null) return null;

  try {
    final data = await supabase
        .from('perfis')
        .select()
        .eq('id', session.user.id)
        .single();
    
    return AppProfile.fromMap(data);
  } catch (e) {
    return null;
  }
});

// Notificador para gerenciar o estado da autenticação (login/logout)
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseClient _supabase;

  AuthNotifier(this._supabase) : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(supabaseProvider));
});
