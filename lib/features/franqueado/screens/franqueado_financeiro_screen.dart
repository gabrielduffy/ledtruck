import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/features/shared/widgets/support_fab.dart';
import 'package:led_truck/core/utils/export_utils.dart';

class FranqueadoFinanceiroScreen extends ConsumerStatefulWidget {
  const FranqueadoFinanceiroScreen({super.key});

  @override
  ConsumerState<FranqueadoFinanceiroScreen> createState() => _FranqueadoFinanceiroScreenState();
}

class _FranqueadoFinanceiroScreenState extends ConsumerState<FranqueadoFinanceiroScreen> {
  final _cobrancasMock = [
    {'mes': '04/2026', 'venc': '10/04/2026', 'valor': '497.00', 'status': 'pendente'},
    {'mes': '03/2026', 'venc': '10/03/2026', 'valor': '497.00', 'status': 'pago'},
    {'mes': '02/2026', 'venc': '10/02/2026', 'valor': '497.00', 'status': 'pago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      floatingActionButton: const SupportFAB(),
      appBar: AppBar(
        title: Text("MEU FINANCEIRO", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode, color: AppTheme.primaryNeon),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Badge(backgroundColor: AppTheme.primaryNeon, textColor: Colors.white, label: Text('1'), child: Icon(Icons.notifications_outlined)),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResumoCards(),
              const SizedBox(height: 32),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Histórico de Cobranças", style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 16),
                        _buildCobrancasTable(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Meu Contrato", style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 16),
                        _buildContratoCard(),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumoCards() {
    return Row(
      children: [
        _kpiCard("Próximo Vencimento", "10/04/2026", Icons.date_range, Colors.blue),
        const SizedBox(width: 16),
        _kpiCard("Valor", "R\$ 497,00", Icons.attach_money, Colors.green),
        const SizedBox(width: 16),
        _kpiCard("Status Atual", "EM DIA", Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: AppCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCobrancasTable() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text("Mês Ref.", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Vencimento", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Valor", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Status", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
              DataColumn(label: Text("Ações", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
            ],
            rows: _cobrancasMock.map((c) => DataRow(
              cells: [
                DataCell(Text(c['mes']!)),
                DataCell(Text(c['venc']!)),
                DataCell(Text('R\$ ${c['valor']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(_buildStatus(c['status']!)),
                DataCell(
                  c['status'] == 'pago' ? TextButton.icon(
                    onPressed: () {
                      ExportUtils.exportarPDF(['Descrição', 'Valor'], [['Cobrança LedTruck', c['valor']!]], "Recibo", "recibo_${c['venc']?.replaceAll('/', '')}");
                    },
                    icon: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryNeon, size: 20),
                    label: const Text("Ver Recibo", style: TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold)),
                  ) : const SizedBox.shrink(),
                ),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(String status) {
    Color bg;
    Color text;
    switch (status) {
      case 'pago': bg = Colors.green.withValues(alpha: 0.12); text = Colors.green; break;
      case 'atrasado': bg = Colors.redAccent.withValues(alpha: 0.12); text = Colors.redAccent; break;
      case 'carencia': bg = Colors.blue.withValues(alpha: 0.12); text = Colors.blue; break;
      default: bg = Colors.amber.withValues(alpha: 0.12); text = Colors.amber; break; // pendente
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: text.withValues(alpha: 0.3))),
      child: Text(status.toUpperCase(), style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildContratoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.description, color: AppTheme.primaryNeon, size: 32),
            title: Text("CONTRATO ATIVO", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Licença Box Led Truck"),
          ),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          _infoRow("Valor Mensal Atual:", "R\$ 497,00"),
          _infoRow("Dia de Vencimento:", "Dia 10"),
          _infoRow("Desconto Ativo:", "Nenhum"),
          _infoRow("Carência Ativa:", "Nenhuma"),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
