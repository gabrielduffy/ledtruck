import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';

class FranqueadoDashboardScreen extends ConsumerWidget {
  const FranqueadoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("DASHBOARD - FRANQUEADO", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
              color: AppTheme.primaryNeon,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: Badge(
                backgroundColor: AppTheme.primaryNeon,
                textColor: Colors.white,
                label: const Text('2'),
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
                // CARDS
                LayoutBuilder(builder: (context, constraints) {
                  int cols = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: constraints.maxWidth > 1200 ? 2.5 : 3.0,
                    children: [
                      _MetricCard(title: "Horas exibidas hoje", value: "24h 30m", icon: Icons.timer, color: AppTheme.primaryNeon),
                      _MetricCard(title: "Horas exibidas no mês", value: "720h", icon: Icons.calendar_month, color: AppTheme.primaryNeon),
                      const _MetricCard(title: "Carros ativos agora", value: "8 / 10", icon: Icons.directions_car, color: Colors.green),
                      const _MetricCard(title: "Campanhas ativas", value: "15", icon: Icons.campaign, color: Colors.blue),
                    ],
                  );
                }),
            const SizedBox(height: 32),
            
                // GRAFICO & BOTOES RAPIDOS
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 1000;
                    return isDesktop 
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildChart(context),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: _buildQuickActions(context),
                        ),
                      ],
                    )
                    : Column(
                      children: [
                        _buildChart(context),
                        const SizedBox(height: 24),
                        _buildQuickActions(context),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 32),
                
                // TABELA DE CARROS (RESUMO)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Meus Carros Ativos", style: Theme.of(context).textTheme.headlineMedium),
                    TextButton(onPressed: () => context.go('/franqueado/carros'), child: const Text("Ver Todos", style: TextStyle(color: AppTheme.primaryNeon))),
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
                    columnSpacing: 24,
                    columns: [
                      DataColumn(label: Text("Código", style: Theme.of(context).textTheme.bodySmall)),
                      DataColumn(label: Text("Placa", style: Theme.of(context).textTheme.bodySmall)),
                      DataColumn(label: Text("Status", style: Theme.of(context).textTheme.bodySmall)),
                      DataColumn(label: Text("Operador", style: Theme.of(context).textTheme.bodySmall)),
                      DataColumn(label: Text("Tempo hoje", style: Theme.of(context).textTheme.bodySmall)),
                      DataColumn(label: Text("Ações", style: Theme.of(context).textTheme.bodySmall)),
                    ],
                    rows: [
                      _carroRow(context, "LT-001", "ABC-1234", "Online", "João Silva", "4h 30m"),
                      _carroRow(context, "LT-002", "XYZ-9876", "Offline", "Maria", "2h 10m"),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // TABELA DE CAMPANHAS
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Campanhas em Execução", style: Theme.of(context).textTheme.headlineMedium),
                TextButton(onPressed: () => context.go('/franqueado/campanhas'), child: const Text("Ver Todas", style: TextStyle(color: AppTheme.primaryNeon))),
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
                    columnSpacing: 24,
                    columns: [
                      DataColumn(label: Text("Anunciante", style: Theme.of(context).textTheme.bodySmall)),
                      DataColumn(label: Text("Período", style: Theme.of(context).textTheme.bodySmall)),
                      DataColumn(label: Text("Progresso", style: Theme.of(context).textTheme.bodySmall)),
                      DataColumn(label: Text("Horas (Exibidas/Contratadas)", style: Theme.of(context).textTheme.bodySmall)),
                      DataColumn(label: Text("Carros Alocados", style: Theme.of(context).textTheme.bodySmall)),
                    ],
                    rows: [
                      _campanhaRow(context, "Coca-Cola", "01/03 a 31/03", 0.75, "75h / 100h", 4),
                      _campanhaRow(context, "McDonald's", "10/03 a 20/03", 0.90, "90h / 100h", 2),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Horas Exibidas (Últimos dias)", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
              DropdownButton<String>(
                dropdownColor: Theme.of(context).cardColor,
                value: "7 dias",
                items: const [DropdownMenuItem(value: "7 dias", child: Text("7 dias")), DropdownMenuItem(value: "30 dias", child: Text("30 dias"))],
                onChanged: (val) {},
                style: const TextStyle(color: AppTheme.primaryNeon),
                underline: Container(),
              )
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 40,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
                        if (val.toInt() >= dias.length) return Container();
                        return Padding(padding: const EdgeInsets.only(top: 8), child: Text(dias[val.toInt()], style: Theme.of(context).textTheme.bodySmall));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 10,
                      getTitlesWidget: (val, meta) => Text('${val.toInt()}h', style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(color: Theme.of(context).dividerColor.withOpacity(0.1), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarData(0, 24),
                  _makeBarData(1, 30),
                  _makeBarData(2, 35),
                  _makeBarData(3, 28),
                  _makeBarData(4, 38),
                  _makeBarData(5, 12),
                  _makeBarData(6, 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Ações Rápidas", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
          const SizedBox(height: 24),
          AppButton(
            label: "Nova Campanha",
            icon: Icons.add_circle,
            onPressed: () {
              _openNovaCampanhaModal(context);
            },
          ),
          const SizedBox(height: 16),
          AppButton(
            label: "Gerenciar Operadores",
            icon: Icons.people,
            onPressed: () {
              _openGerenciarOperadoresModal(context);
            },
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppTheme.primaryNeon,
          width: 22,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: 40, color: Colors.white10),
        ),
      ],
    );
  }

  DataRow _carroRow(BuildContext context, String code, String placa, String status, String operador, String tempo) {
    bool isOnline = status == "Online";
    return DataRow(cells: [
      DataCell(Text(code, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(placa)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: (isOnline ? Colors.green : Colors.red).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Text(status, style: TextStyle(color: isOnline ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
      )),
      DataCell(Text(operador)),
      DataCell(Text(tempo)),
      DataCell(Row(
        children: [
          IconButton(icon: const Icon(Icons.map, color: AppTheme.primaryNeon, size: 20), onPressed: () => context.go('/franqueado/rastreamento'), tooltip: "Ver Rota"),
          IconButton(icon: const Icon(Icons.campaign, color: Colors.blue, size: 20), onPressed: () => context.go('/franqueado/campanhas'), tooltip: "Ver Campanhas"),
        ],
      )),
    ]);
  }

  DataRow _campanhaRow(BuildContext context, String nome, String periodo, double progresso, String horas, int carros) {
    return DataRow(cells: [
      DataCell(Text(nome, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(periodo)),
      DataCell(SizedBox(
        width: 100,
        child: LinearProgressIndicator(value: progresso, backgroundColor: Colors.white10, color: AppTheme.primaryNeon),
      )),
      DataCell(Text(horas)),
      DataCell(Text("$carros carros")),
    ]);
  }

  void _openNovaCampanhaModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardColor,
         title: Text("Nova Campanha", style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
         content: SingleChildScrollView(
           child: SizedBox(
             width: 500,
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 const AppTextField(label: "Nome do Anunciante", icon: Icons.business),
                 const SizedBox(height: 16),
                 const AppTextField(label: "E-mail do Anunciante", icon: Icons.email),
                 const SizedBox(height: 16),
                 const Row(
                   children: [
                     Expanded(child: AppTextField(label: "Horas Contratadas", icon: Icons.timer)),
                     SizedBox(width: 16),
                     Expanded(child: AppTextField(label: "Data Início", icon: Icons.calendar_today)),
                   ],
                 ),
                 const SizedBox(height: 16),
                 Text("Selecione os carros:", style: TextStyle(color: Theme.of(ctx).textTheme.bodyMedium?.color)),
                 CheckboxListTile(
                   title: Text("LT-001 (ABC-1234)", style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
                   value: true,
                   onChanged: (v) {},
                   activeColor: AppTheme.primaryNeon,
                 ),
                 CheckboxListTile(
                   title: Text("LT-002 (XYZ-9876)", style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
                   value: false,
                   onChanged: (v) {},
                   activeColor: AppTheme.primaryNeon,
                 ),
                 const SizedBox(height: 8),
                 Text("Ao salvar, uma conta será criada automaticamente via Supabase Auth Invite para o anunciante.", style: TextStyle(color: Theme.of(ctx).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 12)),
               ],
             ),
           ),
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
           AppButton(label: "Criar Campanha", onPressed: () {
             Navigator.pop(ctx);
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Campanha criada e convite enviado!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
           }),
         ],
      )
    );
  }

  void _openGerenciarOperadoresModal(BuildContext context) {
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardColor,
         title: Text("Gerenciar Operadores", style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
         content: SingleChildScrollView(
           child: SizedBox(
             width: 500,
             child: Column(
               mainAxisSize: MainAxisSize.min,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const AppTextField(label: "Nome do Novo Operador", icon: Icons.person),
                 const SizedBox(height: 16),
                 const AppTextField(label: "E-mail", icon: Icons.email),
                 const SizedBox(height: 16),
                 AppButton(label: "Convidar Operador", onPressed: () {}, icon: Icons.send),
                 const SizedBox(height: 32),
                 Text("Operadores Vinculados", style: TextStyle(color: Theme.of(ctx).textTheme.headlineMedium?.color, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 16),
                 ListTile(
                   leading: const CircleAvatar(backgroundColor: AppTheme.primaryNeon, child: Icon(Icons.person, color: Colors.white)),
                   title: Text("João Silva", style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
                   subtitle: Text("LT-001 atribuído", style: TextStyle(color: Theme.of(ctx).textTheme.bodyMedium?.color)),
                   trailing: TextButton(onPressed: () {}, child: const Text("Alterar Carro", style: TextStyle(color: AppTheme.primaryNeon))),
                 ),
                 ListTile(
                   leading: const CircleAvatar(backgroundColor: AppTheme.primaryNeon, child: Icon(Icons.person, color: Colors.white)),
                   title: Text("Maria Souza", style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
                   subtitle: Text("Sem carro atribuído", style: TextStyle(color: Theme.of(ctx).textTheme.bodyMedium?.color)),
                   trailing: TextButton(onPressed: () {}, child: const Text("Atribuir", style: TextStyle(color: AppTheme.primaryNeon))),
                 ),
               ],
             ),
           ),
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Fechar", style: TextStyle(color: Colors.grey))),
         ],
      )
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
