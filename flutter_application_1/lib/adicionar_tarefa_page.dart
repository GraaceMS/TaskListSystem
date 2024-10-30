import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tarefas_model.dart';

class AdicionarTarefaPage extends StatefulWidget {
  final Tarefa? tarefa; // Receber a tarefa a ser editada

  const AdicionarTarefaPage({super.key, this.tarefa});

  @override
  _AdicionarTarefaPageState createState() => _AdicionarTarefaPageState();
}

class _AdicionarTarefaPageState extends State<AdicionarTarefaPage> {
  final nomeController = TextEditingController();
  final custoController = TextEditingController();
  final dataLimiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.tarefa != null) {
      // Se houver uma tarefa, preencha os controladores
      nomeController.text = widget.tarefa!.nome;
      custoController.text = widget.tarefa!.custo.toString();
      dataLimiteController.text =
          widget.tarefa!.dataLimite.toIso8601String().split('T')[0];
    }
  }

  void _salvarTarefa() {
    final nome = nomeController.text;
    final custo = double.tryParse(custoController.text);
    final dataLimite = DateTime.tryParse(dataLimiteController.text);

    if (nome.isNotEmpty && custo != null && dataLimite != null) {
      final tarefa = Tarefa(
        id: widget.tarefa?.id ??
            0, // Se a tarefa existir, pegue o ID, caso contrário, use 0
        nome: nome,
        custo: custo,
        dataLimite: dataLimite,
        ordem: widget.tarefa?.ordem ?? 0,
      );

      if (widget.tarefa == null) {
        // Se não for edição, adiciona a nova tarefa
        Provider.of<TarefasModel>(context, listen: false)
            .adicionarTarefa(tarefa);
      } else {
        // Se for edição, atualiza a tarefa existente
        Provider.of<TarefasModel>(context, listen: false).editarTarefa(tarefa);
      }
      Navigator.pop(context); // Retorna à tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.tarefa == null ? 'Adicionar Tarefa' : 'Editar Tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome da Tarefa'),
            ),
            TextField(
              controller: custoController,
              decoration: const InputDecoration(labelText: 'Custo'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: dataLimiteController,
              decoration:
                  const InputDecoration(labelText: 'Data Limite (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvarTarefa,
              child: Text(
                  widget.tarefa == null ? 'Adicionar Tarefa' : 'Salvar Tarefa'),
            ),
          ],
        ),
      ),
    );
  }
}
