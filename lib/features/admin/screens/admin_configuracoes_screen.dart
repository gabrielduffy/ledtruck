import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_truck/features/shared/widgets/side_menu.dart';
import 'package:led_truck/features/shared/widgets/notifications_drawer.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/core/theme/theme_provider.dart';
import 'package:led_truck/features/shared/widgets/support_fab.dart';
import 'package:led_truck/core/utils/export_utils.dart';

class AdminConfiguracoesScreen extends ConsumerStatefulWidget {
  const AdminConfiguracoesScreen({super.key});

  @override
  ConsumerState<AdminConfiguracoesScreen> createState() => _AdminConfiguracoesScreenState();
}

class _AdminConfiguracoesScreenState extends ConsumerState<AdminConfiguracoesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openConfigModal(String title, String description, List<Widget> fields) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text("Configurar $title", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(description, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                const SizedBox(height: 24),
                ...fields,
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5))),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚀 Teste enviado!")));
              },
              child: const Text("Testar Conexão", style: TextStyle(color: Colors.blueAccent)),
            ),
            const SizedBox(width: 8),
            AppButton(
              label: "Salvar",
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$title salvo!"), backgroundColor: AppTheme.primaryNeon));
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAbaIntegracoes() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            int cols = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              childAspectRatio: constraints.maxWidth > 1200 ? 1.2 : 1.4,
              children: [
                _buildIntegracaoCard(
                  "E-mail (SMTP)",
                  "Envio de relatórios semanais e alertas.",
                  Icons.email,
                  true,
                  [
                    const AppTextField(label: "Host SMTP", icon: Icons.lan),
                    const SizedBox(height: 16),
                    const AppTextField(label: "Porta", icon: Icons.numbers),
                    const SizedBox(height: 16),
                    const AppTextField(label: "Usuário", icon: Icons.person),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Senha", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextField(
                          obscureText: true, 
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: "Senha SMTP", 
                            prefixIcon: const Icon(Icons.password), 
                            filled: true, 
                            fillColor: Theme.of(context).cardColor, 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)))
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const AppTextField(label: "E-mail Remetente", icon: Icons.alternate_email),
                  ]
                ),
                _buildIntegracaoCard(
                  "WhatsApp (Z-API)",
                  "Notificações em tempo real para os clientes e franqueados.",
                  Icons.chat,
                  true,
                  [
                    const AppTextField(label: "Instance ID", icon: Icons.api),
                    const SizedBox(height: 16),
                    const AppTextField(label: "Token", icon: Icons.vpn_key),
                    const SizedBox(height: 16),
                    const AppTextField(label: "Número do Bot", icon: Icons.phone),
                  ]
                ),
                _buildIntegracaoCard(
                  "Webhook",
                  "Envie eventos para sistemas externos",
                  Icons.webhook,
                  false,
                  [],
                  disabled: true
                ),
                _buildIntegracaoCard(
                  "Asaas Pagamentos",
                  "Geração automática de cobranças para franqueados e gestão de faturas.",
                  Icons.payments,
                  false,
                  [],
                  disabled: true
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIntegracaoCard(String title, String description, IconData icon, bool connected, List<Widget> fields, {bool disabled = false}) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.primaryNeon.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppTheme.primaryNeon, size: 32)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: (disabled ? Colors.grey : (connected ? Colors.green : Colors.orange)).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(disabled ? "Em breve" : (connected ? "Conectado" : "Desconectado"), style: TextStyle(color: disabled ? Colors.grey : (connected ? Colors.green : Colors.orange), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(child: Text(description, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 14))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: disabled 
              ? AppButton(label: "Em Breve", onPressed: () {})
              : AppButton(label: "Configurar", onPressed: () => _openConfigModal(title, "Insira as credenciais para integrar com $title.", fields)),
          ),
        ],
      ),
    );
  }

  void _openTemplateModal(String tipo) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(ctx).cardColor,
          title: Text("Template: $tipo", style: TextStyle(color: Theme.of(ctx).textTheme.bodyLarge?.color)),
          content: SizedBox(
            width: 600,
            child: DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    indicatorColor: AppTheme.primaryNeon,
                    labelColor: AppTheme.primaryNeon,
                    unselectedLabelColor: Theme.of(ctx).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    tabs: const [Tab(text: "E-mail"), Tab(text: "WhatsApp")],
                  ),
                  const SizedBox(height: 16),
                  Text("Variáveis disponíveis: {franqueado}, {veiculo}, {placa}, {horario}, {tempo_ligado}, {km_rodados}, {campanha}, {horas_exibidas}, {horas_contratadas}", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 11)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: TabBarView(
                      children: [
                        Column(
                          children: [
                            const AppTextField(label: "Assunto do E-mail", icon: Icons.title),
                            const SizedBox(height: 16),
                             Expanded(child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text("Corpo HTML", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                                 const SizedBox(height: 8),
                                 Expanded(child: TextField(maxLines: 5, style: Theme.of(context).textTheme.bodyMedium, decoration: InputDecoration(hintText: "HTML aqui...", prefixIcon: const Icon(Icons.code), filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)))))),
                               ],
                             )),
                          ],
                        ),
                        Column(
                          children: [
                             Expanded(child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text("Mensagem WhatsApp (Markdown)", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                                 const SizedBox(height: 8),
                                 Expanded(child: TextField(maxLines: 6, style: Theme.of(context).textTheme.bodyMedium, decoration: InputDecoration(hintText: "Mensagem aqui...", prefixIcon: const Icon(Icons.message), filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)))))),
                               ],
                             )),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancelar", style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5))),
            ),
             TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚀 Teste enviado!")));
              },
              child: const Text("Enviar Teste", style: TextStyle(color: Colors.blueAccent)),
            ),
            const SizedBox(width: 8),
            AppButton(
              label: "Salvar Template",
              onPressed: () {
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      }
    );
  }

  Widget _buildAbaTemplates() {
    final templates = [
      "Painel ligado", "Painel desligado", "Campanha 90% atingida",
      "Campanha concluída", "Relatório diário", "Dispositivo sem sinal",
      "Novo franqueado cadastrado", "Novo anunciante cadastrado"
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (ctx, i) {
              return AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(templates[i], style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const DefaultTextStyle(style: TextStyle(fontSize: 12), child: Row(
                      children: [
                        Icon(Icons.email, size: 20, color: Colors.blue), SizedBox(width: 4), Text("ON", style: TextStyle(color: Colors.blue)),
                        SizedBox(width: 16),
                        Icon(Icons.chat, size: 20, color: Colors.green), SizedBox(width: 4), Text("ON", style: TextStyle(color: Colors.green)),
                      ],
                    )),
                    const SizedBox(width: 32),
                    AppButton(
                      label: "Editar Template",
                      onPressed: () => _openTemplateModal(templates[i]),
                    )
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          Text("Configuração de CronJobs", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Horário do Relatório Diário", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                    DropdownButton<String>(
                      dropdownColor: Theme.of(context).cardColor,
                      value: "23:00",
                      items: const [DropdownMenuItem(value: "23:00", child: Text("23:00")), DropdownMenuItem(value: "00:00", child: Text("00:00"))],
                      onChanged: (val) {},
                      style: TextStyle(color: AppTheme.primaryNeon),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Verificação Dispositivos Sem Sinal", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                    DropdownButton<String>(
                      dropdownColor: Theme.of(context).cardColor,
                      value: "1h",
                      items: const [DropdownMenuItem(value: "30min", child: Text("30 min")), DropdownMenuItem(value: "1h", child: Text("1 hora")), DropdownMenuItem(value: "2h", child: Text("2 horas"))],
                      onChanged: (val) {},
                      style: TextStyle(color: AppTheme.primaryNeon),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                AppButton(label: "Salvar CronJobs", onPressed: () {})
              ],
            )
          )
        ],
      )
    );
  }

  Widget _buildAbaLogs() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Auditoria de Sistema", style: Theme.of(context).textTheme.headlineMedium),
              TextButton.icon(
                onPressed: () async {
                  final rows = [
                    ['Timestamp', 'Tipo', 'Canal', 'Status', 'Mensagem'],
                    ['24/03/2026 23:01', 'Relatório Env', 'WhatsApp', 'sucesso', 'Enviado a 551199999999'],
                    ['24/03/2026 23:00', 'Relatório Env', 'E-mail', 'sucesso', 'Enviado a user@test.com'],
                    ['24/03/2026 18:30', 'Sem Sinal', 'WhatsApp', 'falha', 'Timeout API Z-API'],
                    ['24/03/2026 14:20', 'Painel Ligou', 'Sistema', 'sucesso', 'Trigger acionada'],
                  ];
                  await ExportUtils.exportarCSV(rows, "auditoria_sistema");
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("CSV de Auditoria gerado!"), backgroundColor: AppTheme.primaryNeon));
                },
                icon: const Icon(Icons.download, color: AppTheme.primaryNeon, size: 24),
                label: const Text("Exportar CSV", style: TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 16)),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: AppTextField(label: "Buscar", icon: Icons.search)),
              const SizedBox(width: 16),
              DropdownButton<String>(
                dropdownColor: Theme.of(context).cardColor,
                value: "Todos",
                items: const [DropdownMenuItem(value: "Todos", child: Text("Todos os Canais")), DropdownMenuItem(value: "Email", child: Text("E-mail")), DropdownMenuItem(value: "Zap", child: Text("WhatsApp"))],
                onChanged: (val) {},
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                underline: Container(height: 1, color: AppTheme.primaryNeon.withValues(alpha: 0.3)),
              )
            ],
          ),
          const SizedBox(height: 24),
          AppCard(
            padding: const EdgeInsets.all(0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                dataTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                columns: [
                  DataColumn(label: Text("Timestamp", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                  DataColumn(label: Text("Tipo", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                  DataColumn(label: Text("Canal", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                  DataColumn(label: Text("Status", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                  DataColumn(label: Text("Mensagem", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                  DataColumn(label: Text("Ações", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))),
                ],
                rows: [
                  _logRow("24/03/2026 23:01", "Relatório Env", "WhatsApp", "sucesso", "Enviado a 551199999999", Colors.green, Icons.chat),
                  _logRow("24/03/2026 23:00", "Relatório Env", "E-mail", "sucesso", "Enviado a user@test.com", Colors.blue, Icons.email),
                  _logRow("24/03/2026 18:30", "Sem Sinal", "WhatsApp", "falha", "Timeout API Z-API", Colors.red, Icons.chat),
                  _logRow("24/03/2026 14:20", "Painel Ligou", "Sistema", "sucesso", "Trigger acionada", Colors.grey, Icons.settings),
                ],
              ),
            ),
          )
        ],
      )
    );
  }

  DataRow _logRow(String ts, String tipo, String canal, String status, String msg, Color cor, IconData icon) {
    return DataRow(cells: [
      DataCell(Text(ts, style: const TextStyle(fontSize: 12))),
      DataCell(Text(tipo)),
      DataCell(Row(children: [Icon(icon, size: 16, color: cor), const SizedBox(width: 8), Text(canal)])),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: (status == 'sucesso' ? Colors.green : Colors.red).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Text(status.toUpperCase(), style: TextStyle(color: status == 'sucesso' ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
      )),
      DataCell(Text(msg)),
      DataCell(TextButton(
        onPressed: () {
          String payloadJSON = '{\n  "event": "update",\n  "table": "eventos"\n}';
          if (tipo == 'Relatório Env') {
            payloadJSON = '{\n  "destinatario": "joao@ledtruck.com",\n  "template": "relatorio_diario",\n  "status": "enviado",\n  "timestamp": "24/03/2026 23:01"\n}';
          } else if (tipo == 'Sem Sinal') {
            payloadJSON = '{\n  "dispositivo": "LT-2025-0003",\n  "ultima_leitura": "24/03/2026 18:30",\n  "tentativas": 3\n}';
          } else if (tipo == 'Painel Ligou') {
            payloadJSON = '{\n  "carro_id": "TRK-001",\n  "tipo": "ligou",\n  "latitude": -23.5505,\n  "longitude": -46.6333\n}';
          }
          showDialog(context: context, builder: (_) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text("Payload JSON"),
            content: SelectableText(payloadJSON, style: TextStyle(fontFamily: 'Courier', color: AppTheme.primaryNeon)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fechar"))]
          ));
        },
        child: const Text("Ver detalhes", style: TextStyle(color: AppTheme.primaryNeon)),
      ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const SideMenu(),
      endDrawer: const NotificationsDrawer(),
      floatingActionButton: const SupportFAB(),
      appBar: AppBar(
        title: Text("CONFIGURAÇÕES", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryNeon,
          labelColor: AppTheme.primaryNeon,
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          tabs: const [
            Tab(text: "Integrações", icon: Icon(Icons.api)),
            Tab(text: "Templates", icon: Icon(Icons.edit_document)),
            Tab(text: "Logs", icon: Icon(Icons.list_alt)),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAbaIntegracoes(),
              _buildAbaTemplates(),
              _buildAbaLogs(),
            ],
          ),
        ),
      ),
    );
  }
}
