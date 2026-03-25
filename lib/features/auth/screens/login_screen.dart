import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../shared/widgets/base_components.dart';
import '../../../core/theme/app_theme.dart';

class AnimatedGridBackground extends StatefulWidget {
  const AnimatedGridBackground({super.key});

  @override
  State<AnimatedGridBackground> createState() => _AnimatedGridBackgroundState();
}

class _AnimatedGridBackgroundState extends State<AnimatedGridBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GridPainter(
            offset: _controller.value,
            color: AppTheme.primaryNeon.withOpacity(0.05),
          ),
          child: Container(),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final double offset;
  final Color color;

  _GridPainter({required this.offset, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    double gridSpace = 40;
    double startY = (offset * gridSpace) % gridSpace;
    double startX = (offset * gridSpace) % gridSpace;

    for (double i = startX; i < size.width; i += gridSpace) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = startY; i < size.height; i += gridSpace) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos")),
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).signIn(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro ao entrar: ${error.toString()}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const AnimatedGridBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: AppCard(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flash_on, 
                      color: AppTheme.primaryNeon, 
                      size: 48,
                      shadows: [BoxShadow(color: AppTheme.primaryNeon.withOpacity(0.5), blurRadius: 15)],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "LED TRUCK",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        shadows: [Shadow(color: AppTheme.primaryNeon.withOpacity(0.3), blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Painéis de LED em movimento",
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 32),
                    
                    AppTextField(
                      label: "E-mail",
                      controller: _emailController,
                      hint: "seu@email.com",
                      type: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    
                    AppTextField(
                      label: "Senha",
                      controller: _passwordController,
                      isPassword: true,
                      hint: "••••••••",
                    ),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: "ENTRAR",
                        onPressed: _onLogin,
                        isLoading: authState is AsyncLoading,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: "MODO TESTE (ADMIN)",
                        isSecondary: true,
                        onPressed: () => context.go('/admin/dashboard'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Esqueci minha senha",
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
