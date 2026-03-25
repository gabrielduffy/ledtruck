import 'package:flutter/material.dart';
import 'package:led_truck/core/theme/app_theme.dart';
import 'package:led_truck/features/shared/widgets/base_components.dart';

class ModalUsuarioDetalhes extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const ModalUsuarioDetalhes({super.key, required this.usuario});

  @override
  State<ModalUsuarioDetalhes> createState() => _ModalUsuarioDetalhesState();
}

class _ModalUsuarioDetalhesState extends State<ModalUsuarioDetalhes> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController nomeCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController telefoneCtrl;
  late String status;
  late String role;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    nomeCtrl = TextEditingController(text: widget.usuario['nome']);
    emailCtrl = TextEditingController(text: widget.usuario['email']);
    telefoneCtrl = TextEditingController(text: "(11) 99999-9999");
    status = widget.usuario['status'];
    role = widget.usuario['role'];
  }

  @override
  void dispose() {
    _tabController.dispose();
    nomeCtrl.dispose();
    emailCtrl.dispose();
    telefoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            width: 600,
            constraints: const BoxConstraints(maxHeight: 700),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Detalhes do Usuário", style: Theme.of(context).textTheme.headlineMedium),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primaryNeon,
                  labelColor: AppTheme.primaryNeon,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [Tab(text: "Informações"), Tab(text: "Atividade")]
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInfoTab(isDark),
                      _buildAtividadeTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab(bool isDark) {
    String iniciais = (widget.usuario['nome'] as String).substring(0, 2).toUpperCase();
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 30, backgroundColor: AppTheme.primaryNeon.withValues(alpha: 0.2), child: Text(iniciais, style: const TextStyle(color: AppTheme.primaryNeon, fontSize: 20))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Cadastro: 01/01/2026", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("Último Acesso: ${widget.usuario['ultimo_acesso']}", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          AppTextField(label: "Nome", icon: Icons.person, controller: nomeCtrl),
          const SizedBox(height: 16),
          AppTextField(label: "E-mail", icon: Icons.email, controller: emailCtrl),
          const SizedBox(height: 16),
          AppTextField(label: "Telefone", icon: Icons.phone, controller: telefoneCtrl),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: role,
                  decoration: InputDecoration(labelText: "Role", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  dropdownColor: Theme.of(context).cardColor,
                  items: const [
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'Franqueado', child: Text('Franqueado')),
                    DropdownMenuItem(value: 'Operador', child: Text('Operador')),
                    DropdownMenuItem(value: 'Anunciante', child: Text('Anunciante')),
                  ],
                  onChanged: (v) => setState(() => role = v!),
                )
              ),
              const SizedBox(width: 16),
               Expanded(
                child: DropdownButtonFormField<String>(
                  value: 'Nenhum',
                  decoration: InputDecoration(labelText: "Franqueado Vinculado", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  dropdownColor: Theme.of(context).cardColor,
                  items: const [
                    DropdownMenuItem(value: 'Nenhum', child: Text('Nenhum')),
                    DropdownMenuItem(value: 'Franqueado SP', child: Text('Franqueado SP')),
                  ],
                  onChanged: (v) {},
                )
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Status Ativo:"),
              Switch(value: status == 'Ativo', onChanged: (v) => setState(() => status = v ? 'Ativo' : 'Inativo'), activeColor: AppTheme.primaryNeon),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton(label: "Excluir", color: Colors.red, isSecondary: true, onPressed: () {
                // Confirm
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Excluído"), backgroundColor: Colors.red));
              }),
              Row(
                children: [
                  AppButton(label: "Redefinir Senha", isSecondary: true, color: Colors.grey, onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("E-mail de redefinição enviado."), backgroundColor: Colors.orange));
                  }),
                  const SizedBox(width: 16),
                  AppButton(label: "Salvar", onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Salvo com sucesso!"), backgroundColor: AppTheme.primaryNeon));
                  }),
                ],
              )
            ],
          )
        ],
      )
    );
  }

  Widget _buildAtividadeTab() {
    final list = [
      {"ts": "24/03 15:30", "acao": "Login", "detalhe": "Login via Web App"},
      {"ts": "23/03 10:15", "acao": "Edição", "detalhe": "Alterou cadastro de Veículo LT-001"},
      {"ts": "20/03 09:00", "acao": "Senha", "detalhe": "Redefinição de senha solicitada"},
    ];
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (ctx, i) => ListTile(
        leading: const Icon(Icons.history, color: AppTheme.primaryNeon),
        title: Text(list[i]['acao']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(list[i]['detalhe']!),
        trailing: Text(list[i]['ts']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      )
    );
  }
}

class ModalNovoUsuario extends StatefulWidget {
  const ModalNovoUsuario({super.key});

  @override
  State<ModalNovoUsuario> createState() => _ModalNovoUsuarioState();
}

class _ModalNovoUsuarioState extends State<ModalNovoUsuario> {
  String _role = 'Admin';
  String _vencimento = '10';
  int _carencia = 0;
  double _desconto = 0.0;
  DateTime _dataInicio = DateTime.now();
  DateTime? _descontoAte;
  
  final _valorCtrl = TextEditingController(text: "497.00");
  final _obsCtrl = TextEditingController();

  @override
  void dispose() {
    _valorCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isInicio) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isInicio ? _dataInicio : (_descontoAte ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryNeon,
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A26),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF12121A),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        if (isInicio) _dataInicio = date;
        else _descontoAte = date;
      });
    }
  }

  String _formatDate(DateTime d) => "${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      title: Text("Novo Usuário", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: "Nome", icon: Icons.person, controller: TextEditingController()),
              const SizedBox(height: 16),
              AppTextField(label: "E-mail", icon: Icons.email, controller: TextEditingController()),
              const SizedBox(height: 16),
              AppTextField(label: "Telefone", icon: Icons.phone, controller: TextEditingController()),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(labelText: "Role", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                dropdownColor: Theme.of(context).cardColor,
                items: const [
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'Franqueado', child: Text('Franqueado')),
                  DropdownMenuItem(value: 'Operador', child: Text('Operador')),
                  DropdownMenuItem(value: 'Anunciante', child: Text('Anunciante')),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
              const SizedBox(height: 16),
              if (_role != 'Franqueado') 
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Franqueado", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  dropdownColor: Theme.of(context).cardColor,
                  items: const [
                    DropdownMenuItem(value: 'Franqueado SP', child: Text('Franqueado SP')),
                    DropdownMenuItem(value: 'Sem Vínculo', child: Text('Sem Vínculo')),
                  ],
                  onChanged: (v) {},
                ),
                
              if (_role == 'Franqueado') ...[
                const SizedBox(height: 24),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                Text("DADOS DO CONTRATO", style: TextStyle(color: AppTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: AppTextField(label: "Valor Mensal (R\$)", icon: Icons.attach_money, controller: _valorCtrl)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _vencimento,
                        decoration: InputDecoration(labelText: "Dia Vencimento", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        dropdownColor: Theme.of(context).cardColor,
                        items: List.generate(28, (i) => DropdownMenuItem(value: '${i+1}', child: Text('${i+1}'))),
                        onChanged: (v) => setState(() => _vencimento = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _pickDate(context, true),
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: "Data Início Cobrança", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    child: Text(_formatDate(_dataInicio)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _carencia,
                        decoration: InputDecoration(labelText: "Carência (meses)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        dropdownColor: Theme.of(context).cardColor,
                        items: List.generate(13, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                        onChanged: (v) => setState(() => _carencia = v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        value: _desconto,
                        decoration: InputDecoration(labelText: "Desconto (%)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                        dropdownColor: Theme.of(context).cardColor,
                        items: [
                          const DropdownMenuItem(value: 0.0, child: Text('0%')),
                          const DropdownMenuItem(value: 10.0, child: Text('10%')),
                          const DropdownMenuItem(value: 20.0, child: Text('20%')),
                          const DropdownMenuItem(value: 50.0, child: Text('50%')),
                          const DropdownMenuItem(value: 100.0, child: Text('100%')),
                        ],
                        onChanged: (v) => setState(() => _desconto = v!),
                      ),
                    ),
                  ],
                ),
                if (_carencia > 0) ...[
                  const SizedBox(height: 16),
                  Text("Carência calculada até: ${_formatDate(DateTime(_dataInicio.year, _dataInicio.month + _carencia, _dataInicio.day))}", style: const TextStyle(color: Colors.blue, fontSize: 12)),
                ],
                if (_desconto > 0) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _pickDate(context, false),
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: "Desconto válido até", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      child: Text(_descontoAte != null ? _formatDate(_descontoAte!) : "Selecione a data limite"),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AppTextField(label: "Observações do Contrato", icon: Icons.notes, controller: _obsCtrl),
              ]
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
        AppButton(label: "Salvar", onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Usuário e Contrato criados com sucesso!", style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.primaryNeon));
        }),
      ],
    );
  }
}
