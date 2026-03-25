import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';

class FranqueadoCampanhasScreen extends ConsumerWidget {
  const FranqueadoCampanhasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      appBar: AppBar(
        title: Text("CAMPANHAS", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Campanhas Ativas e Histórico", style: Theme.of(context).textTheme.headlineMedium),
                AppButton(
                  label: "Nova Campanha",
                  icon: Icons.add,
                  onPressed: () => _openNovaCampanhaModal(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: AppTextField(label: "Buscar anunciante", icon: Icons.search)),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  dropdownColor: Theme.of(context).cardColor,
                  value: "Ativas",
                  items: const [DropdownMenuItem(value: "Todas", child: Text("Todas")), DropdownMenuItem(value: "Ativas", child: Text("Ativas")), DropdownMenuItem(value: "Concluídas", child: Text("Concluídas"))],
                  onChanged: (val) {},
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  underline: Container(height: 1, color: AppTheme.primaryNeon.withOpacity(0.3)),
                )
              ],
            ),
            const SizedBox(height: 24),
            AppCard(
              padding: const EdgeInsets.all(0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontWeight: FontWeight.bold),
                  dataTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  columns: const [
                    DataColumn(label: Text("Anunciante")),
                    DataColumn(label: Text("E-mail Contato")),
                    DataColumn(label: Text("Período")),
                    DataColumn(label: Text("Progresso")),
                    DataColumn(label: Text("Meta (Horas)")),
                    DataColumn(label: Text("Carros")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Ações")),
                  ],
                  rows: [
                    _campanhaRow(context, "Coca-Cola", "mkt@coca.com", "01/03 a 31/03", 0.75, "75h / 100h", 4, "Em Execução"),
                    _campanhaRow(context, "McDonald's", "ads@mcd.com", "10/03 a 20/03", 0.90, "90h / 100h", 2, "Em Execução"),
                    _campanhaRow(context, "Nike", "promo@nike.com", "01/02 a 28/02", 1.0, "150h / 150h", 5, "Concluída"),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  DataRow _campanhaRow(BuildContext context, String nome, String email, String periodo, double progresso, String horas, int carros, String status) {
    bool isDone = status == "Concluída";
    return DataRow(cells: [
      DataCell(Text(nome, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(email)),
      DataCell(Text(periodo)),
      DataCell(SizedBox(
        width: 100,
        child: LinearProgressIndicator(value: progresso, backgroundColor: Colors.white10, color: isDone ? Colors.green : AppTheme.primaryNeon),
      )),
      DataCell(Text(horas)),
      DataCell(Text("$carros carros")),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: (isDone ? Colors.green : Colors.blue).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Text(status, style: TextStyle(color: isDone ? Colors.green : Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
      )),
      DataCell(Row(
        children: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.amber, size: 20), onPressed: () => _openEditarCampanhaModal(context, nome, horas, periodo, carros), tooltip: "Editar"),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () {}, tooltip: "Remover"),
        ],
      )),
    ]);
  }

  void _openEditarCampanhaModal(BuildContext context, String nome, String horas, String datas, int carros) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardColor,
        title: Text("Editar Campanha", style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(label: "Nome do Anunciante", icon: Icons.business, controller: TextEditingController(text: nome)),
                const SizedBox(height: 16),
                AppTextField(label: "Horas Contratadas", icon: Icons.timer, controller: TextEditingController(text: horas.contains(' / ') ? horas.split(' / ')[1] : horas)),
                const SizedBox(height: 16),
                AppTextField(label: "Período (Datas)", icon: Icons.calendar_today, controller: TextEditingController(text: datas)),
                const SizedBox(height: 16),
                AppTextField(label: "Nº de Carros", icon: Icons.directions_car, controller: TextEditingController(text: carros.toString())),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          AppButton(label: "Salvar", onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Campanha atualizada com sucesso!", style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.primaryNeon));
          }),
        ],
      )
    );
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
}
