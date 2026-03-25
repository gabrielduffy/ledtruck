import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';

class AnuncianteDashboardScreen extends ConsumerWidget {
  const AnuncianteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("PAINEL ANUNCIANTE", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: AppTheme.primaryNeon,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Badge(
                backgroundColor: AppTheme.primaryNeon,
                textColor: Colors.white,
                label: Text('1'),
                child: Icon(Icons.notifications_outlined),
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
                // RESUMO DA CAMPANHA
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 600;
                        return isSmall 
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _campanhaHeader(context),
                              const SizedBox(height: 16),
                              AppButton(
                                label: "RELATÓRIO PDF",
                                icon: Icons.picture_as_pdf,
                                onPressed: () => _gerarPDF(context),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _campanhaHeader(context),
                              AppButton(
                                label: "BAIXAR RELATÓRIO PDF",
                                icon: Icons.picture_as_pdf,
                                onPressed: () => _gerarPDF(context),
                              ),
                            ],
                          );
                      }),
                      const SizedBox(height: 32),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildMetric(context, "Horas Contratadas", "400h"),
                            const SizedBox(width: 48),
                            _buildMetric(context, "Horas Exibidas", "324h"),
                            const SizedBox(width: 48),
                            _buildMetric(context, "Progresso", "81%"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 0.81,
                          minHeight: 12,
                          backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 900;
                    return isDesktop 
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _veiculosAoVivo(context)),
                          const SizedBox(width: 24),
                          Expanded(flex: 1, child: _mapaPlaceholder(context)),
                        ],
                      )
                    : Column(
                        children: [
                          _veiculosAoVivo(context),
                          const SizedBox(height: 32),
                          _mapaPlaceholder(context),
                        ],
                      );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campanhaHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Coca-Cola - Verão 2026", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
        Text("Período: 01/03/2026 - 31/03/2026", style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _veiculosAoVivo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("VEÍCULOS AO VIVO", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryNeon),
                  const SizedBox(width: 16),
                  Expanded(child: Text("TRUCK-${105 + index} - Av. Paulista, 1000", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Text("AO VIVO", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _mapaPlaceholder(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("LOCALIZAÇÃO", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, color: AppTheme.primaryNeon, size: 48),
                SizedBox(height: 12),
                Text("Mapa em breve", style: TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryNeon)),
      ],
    );
  }

  void _gerarPDF(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Gerar Relatório"),
        content: const Text("Deseja exportar o relatório de exibição da campanha em PDF?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          AppButton(
            label: "GERAR", 
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚀 PDF gerado: relatorio_cocacola_marco.pdf"), backgroundColor: Colors.green));
            }
          ),
        ],
      ),
    );
  }
}
