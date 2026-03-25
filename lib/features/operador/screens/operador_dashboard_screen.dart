import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';

class OperadorDashboardScreen extends ConsumerWidget {
  const OperadorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("PAINEL OPERADOR", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
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
              icon: Badge(
                backgroundColor: AppTheme.primaryNeon,
                textColor: Colors.white,
                label: const Text('3'),
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
                // CARDS RESUMO
                LayoutBuilder(builder: (context, constraints) {
                  int cols = constraints.maxWidth > 800 ? 2 : 1;
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: constraints.maxWidth > 800 ? 3.5 : 2.5,
                    children: [
                      _ResumoCard(
                        title: "Carros sob responsabilidade",
                        value: "04",
                        context: context,
                      ),
                      _ResumoCard(
                        title: "Horas ligado hoje",
                        value: "18h 45m",
                        context: context,
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 32),

                Text("MINHA FROTA", style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),

                // LISTA DE CARROS
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final status = index % 2 == 0 ? "ONLINE" : "OFFLINE";
                    final corStatus = status == "ONLINE" ? Colors.green : Colors.red;
                    
                    return AppCard(
                      padding: const EdgeInsets.all(24),
                      child: LayoutBuilder(builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 600;
                        
                        return isSmall 
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _carIcon(),
                                  const SizedBox(width: 16),
                                  _carInfo(context, index),
                                  const Spacer(),
                                  _carStatus(status, corStatus),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("4h 12m hoje", style: Theme.of(context).textTheme.bodySmall),
                                  AppButton(
                                    label: "EVENTO",
                                    isSecondary: true,
                                    onPressed: () => _registrarEventoManual(context, "TRUCK-${100 + index}"),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              _carIcon(),
                              const SizedBox(width: 24),
                              Expanded(child: _carInfo(context, index)),
                              const SizedBox(width: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _carStatus(status, corStatus),
                                  const SizedBox(height: 8),
                                  Text("4h 12m hoje", style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                              const SizedBox(width: 32),
                              AppButton(
                                label: "REGISTRAR EVENTO",
                                isSecondary: true,
                                onPressed: () => _registrarEventoManual(context, "TRUCK-${100 + index}"),
                              ),
                            ],
                          );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _registrarEventoManual(BuildContext context, String codigo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text("Registrar Evento - $codigo", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Selecione o tipo de evento manual para este veículo.", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                dropdownColor: Theme.of(context).cardColor,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                decoration: InputDecoration(
                  labelText: "Evento",
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
                ),
                items: const [
                  DropdownMenuItem(value: "ligou", child: Text("Ligou Painel")),
                  DropdownMenuItem(value: "desligou", child: Text("Desligou Painel")),
                  DropdownMenuItem(value: "manutencao", child: Text("Início Manutenção")),
                ],
                onChanged: (val) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5))),
            ),
            AppButton(
              label: "REGISTRAR",
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Evento registrado com sucesso!"), backgroundColor: Colors.green));
              },
            ),
          ],
        );
      },
    );
  }



  Widget _carIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primaryNeon.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.directions_car, color: AppTheme.primaryNeon),
    );
  }

  Widget _carInfo(BuildContext context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("TRUCK-${100 + index}", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text("VW Delivery 11.180", style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _carStatus(String status, Color corStatus) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: corStatus.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: corStatus, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String title;
  final String value;
  final BuildContext context;

  const _ResumoCard({required this.title, required this.value, required this.context});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.primaryNeon, fontSize: 32)),
        ],
      ),
    );
  }
}
