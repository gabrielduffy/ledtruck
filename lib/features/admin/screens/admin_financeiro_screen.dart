import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/features/shared/widgets/support_fab.dart';
import 'package:led_truck/core/utils/export_utils.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminFinanceiroScreen extends ConsumerStatefulWidget {
  const AdminFinanceiroScreen({super.key});

  @override
  ConsumerState<AdminFinanceiroScreen> createState() => _AdminFinanceiroScreenState();
}

class _AdminFinanceiroScreenState extends ConsumerState<AdminFinanceiroScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _cobrancasMock = [
    {'franq': 'Franqueado 1', 'mes': '03/2026', 'venc': '10/03/2026', 'valor': '497.00', 'desc': '0.00', 'final': '497.00', 'status': 'pago'},
    {'franq': 'Franqueado 1', 'mes': '04/2026', 'venc': '10/04/2026', 'valor': '497.00', 'desc': '0.00', 'final': '497.00', 'status': 'pendente'},
    {'franq': 'Franqueado 1', 'mes': '02/2026', 'venc': '10/02/2026', 'valor': '497.00', 'desc': '0.00', 'final': '497.00', 'status': 'pago'},
    {'franq': 'Franqueado 2', 'mes': '03/2026', 'venc': '15/03/2026', 'valor': '497.00', 'desc': '100.00', 'final': '397.00', 'status': 'carencia'},
    {'franq': 'Franqueado 3', 'mes': '03/2026', 'venc': '05/03/2026', 'valor': '497.00', 'desc': '0.00', 'final': '497.00', 'status': 'atrasado'},
    {'franq': 'Franqueado 3', 'mes': '02/2026', 'venc': '05/02/2026', 'valor': '497.00', 'desc': '0.00', 'final': '497.00', 'status': 'pago'},
  ];

  final _contratosMock = [
    {'franq': 'Franqueado 1', 'valor': '497.00', 'venc': '10', 'inicio': '01/01/2026', 'carencia': '-', 'desc': '-', 'status': 'Ativo'},
    {'franq': 'Franqueado 2', 'valor': '397.00', 'venc': '15', 'inicio': '01/03/2026', 'carencia': '30/06/2026', 'desc': 'R\$ 100,00', 'status': 'Ativo'},
    {'franq': 'Franqueado 3', 'valor': '497.00', 'venc': '05', 'inicio': '15/12/2025', 'carencia': '-', 'desc': '-', 'status': 'Ativo'},
  ];

  String _formatCurrency(dynamic value) {
    if (value == null) return '';
    if (value.toString().contains('R\$')) return value.toString(); // fall-back para descontos hardcoded
    final doubleVal = double.tryParse(value.toString()) ?? 0.0;
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(doubleVal);
  }

  void _showModalPagar(Map<String, String> c) {
    final dateCtrl = TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
    final obsCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Confirmar Pagamento"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: "Data do Pagamento", icon: Icons.calendar_today, controller: dateCtrl),
            const SizedBox(height: 16),
            AppTextField(label: "Observações", icon: Icons.notes, controller: obsCtrl),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          AppButton(label: "Confirmar pagamento", color: Colors.green, onPressed: () {
            Navigator.pop(ctx);
            setState(() { c['status'] = 'pago'; });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pagamento confirmado com sucesso!"), backgroundColor: Colors.green));
          }),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      floatingActionButton: const SupportFAB(),
      appBar: AppBar(
        title: Text("FINANCEIRO", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode, color: AppTheme.primaryNeon),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Badge(backgroundColor: AppTheme.primaryNeon, textColor: Colors.white, label: Text('2'), child: Icon(Icons.notifications_outlined)),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildResumoCards(),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryNeon,
              labelColor: AppTheme.primaryNeon,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.receipt_long), text: "COBRANÇAS"),
                Tab(icon: Icon(Icons.description), text: "CONTRATOS"),
                Tab(icon: Icon(Icons.bar_chart), text: "RELATÓRIO"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAbaCobrancas(),
                  _buildAbaContratos(),
                  _buildAbaRelatorio(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoCards() {
    return Row(
      children: [
        _kpiCard("Receita do Mês", _formatCurrency("1491.00"), Icons.trending_up, Colors.green),
        const SizedBox(width: 16),
        _kpiCard("A Receber", _formatCurrency("497.00"), Icons.schedule, Colors.amber),
        const SizedBox(width: 16),
        _kpiCard("Em Atraso", _formatCurrency("497.00"), Icons.warning, Colors.redAccent),
        const SizedBox(width: 16),
        _kpiCard("Contratos Ativos", "3", Icons.description, AppTheme.primaryNeon),
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

  Widget _buildAbaCobrancas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Histórico de Cobranças", style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✨ Cobranças do mês geradas com sucesso!"), backgroundColor: Colors.green));
                },
                icon: const Icon(Icons.add_task),
                label: const Text("GERAR COBRANÇAS DO MÊS"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNeon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text("Franqueado", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Mês Ref.", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Vencimento", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Valor", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Desconto", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Valor Final", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Status", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Ações", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                  ],
                  rows: _cobrancasMock.map((c) => DataRow(
                    cells: [
                      DataCell(Text(c['franq']!)),
                      DataCell(Text(c['mes']!)),
                      DataCell(Text(c['venc']!)),
                      DataCell(Text(_formatCurrency(c['valor']))),
                      DataCell(Text(_formatCurrency(c['desc']))),
                      DataCell(Text(_formatCurrency(c['final']), style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(_buildStatus(c['status']!)),
                      DataCell(PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        color: Theme.of(context).colorScheme.surface,
                        onSelected: (val) {
                          if (val == 'pago') {
                            _showModalPagar(c);
                          } else if (val == 'recibo') {
                            ExportUtils.exportarPDF(['Descrição', 'Valor'], [['Cobrança LedTruck', _formatCurrency(c['final'])]], "Recibo - ${c['franq']}", "recibo_${c['venc']?.replaceAll('/', '')}");
                          }
                        },
                        itemBuilder: (ctx) => [
                          if (c['status'] != 'pago') PopupMenuItem(value: 'pago', child: Row(children: const [Icon(Icons.check, color: Colors.green, size: 20), SizedBox(width: 8), Text("Marcar como pago", style: TextStyle(color: Colors.green))])),
                          if (c['status'] == 'pago') const PopupMenuItem(value: 'recibo', child: Text("Gerar recibo PDF")),
                          const PopupMenuItem(value: 'editar', child: Text("Editar")),
                          const PopupMenuItem(value: 'cancelar', child: Text("Cancelar cobrança", style: TextStyle(color: Colors.redAccent))),
                        ],
                      )),
                    ],
                  )).toList(),
                ),
              ),
            ),
          )
        ],
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
      case 'cancelado': bg = Colors.grey.withValues(alpha: 0.12); text = Colors.grey; break;
      default: bg = Colors.amber.withValues(alpha: 0.12); text = Colors.amber; break; // pendente
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: text.withValues(alpha: 0.3))),
      child: Text(status.toUpperCase(), style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAbaContratos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Contratos Ativos", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text("Franqueado", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Valor Mensal", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Dia Venc.", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Início", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Carência até", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Desconto", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Status", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Ações", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                  ],
                  rows: _contratosMock.map((c) => DataRow(
                    cells: [
                      DataCell(Text(c['franq']!)),
                      DataCell(Text(_formatCurrency(c['valor']))),
                      DataCell(Text(c['venc']!)),
                      DataCell(Text(c['inicio']!)),
                      DataCell(Text(c['carencia']!)),
                      DataCell(Text(c['desc']!)),
                      DataCell(_buildStatus(c['status']!.toLowerCase() == 'ativo' ? 'pago' : 'pendente')), // Mock visual apenas
                      DataCell(PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        color: Theme.of(context).colorScheme.surface,
                        itemBuilder: (ctx) => const [
                          PopupMenuItem(value: 'editar', child: Text("Editar contrato")),
                          PopupMenuItem(value: 'historico', child: Text("Ver histórico")),
                        ],
                      )),
                    ],
                  )).toList(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAbaRelatorio() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Desempenho Financeiro (Últimos 6 meses)", style: Theme.of(context).textTheme.headlineMedium),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      ExportUtils.exportarPDF(
                        ['Mês', 'Valor Arrecadado'],
                        [['Out', _formatCurrency(1200)], ['Nov', _formatCurrency(1400)], ['Dez', _formatCurrency(2100)], ['Jan', _formatCurrency(1800)], ['Fev', _formatCurrency(1491)], ['Mar', _formatCurrency(994)]],
                        "Relatório Financeiro", 
                        "relatorio_financeiro"
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryNeon),
                    label: const Text("Exportar PDF", style: TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      ExportUtils.exportarCSV(
                        [
                          ['Mês', 'Valor Arrecadado'],
                          ['Out', _formatCurrency(1200)], ['Nov', _formatCurrency(1400)], ['Dez', _formatCurrency(2100)], ['Jan', _formatCurrency(1800)], ['Fev', _formatCurrency(1491)], ['Mar', _formatCurrency(994)]
                        ],
                        "relatorio_financeiro"
                      );
                    },
                    icon: const Icon(Icons.table_chart, color: AppTheme.primaryNeon),
                    label: const Text("Exportar CSV", style: TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: AppCard(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 2520, // 2100 * 1.2
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 4,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(rod.toY.toInt().toString(), TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.bold, fontSize: 10)),
                    )
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          const titles = ['Out', 'Nov', 'Dez', 'Jan', 'Fev', 'Mar'];
                          if (val.toInt() >= 0 && val.toInt() < titles.length) {
                             return Padding(padding: const EdgeInsets.only(top: 8), child: Text(titles[val.toInt()]));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: 1200, color: AppTheme.primaryNeon, width: 30, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 1, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: 1400, color: AppTheme.primaryNeon, width: 30, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 2, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: 2100, color: AppTheme.primaryNeon, width: 30, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 3, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: 1800, color: AppTheme.primaryNeon, width: 30, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 4, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: 1491, color: AppTheme.primaryNeon, width: 30, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 5, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: 994, color: AppTheme.primaryNeon, width: 30, borderRadius: BorderRadius.circular(4))]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _kpiCard("Total Recebido Ano", _formatCurrency("8985.00"), Icons.account_balance_wallet, Colors.green),
              const SizedBox(width: 16),
              _kpiCard("Inadimplência", "12.5%", Icons.trending_down, Colors.redAccent),
            ],
          )
        ],
      ),
    );
  }
}
