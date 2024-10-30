import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tarefas_model.dart';
import 'adicionar_tarefa_page.dart'; // Certifique-se de que este arquivo existe
import 'package:intl/intl.dart'; // Para formatar a data

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TarefasModel(),
      child: MaterialApp(
        title: 'Lista de Tarefas',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
      ),
      body: const TarefasList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AdicionarTarefaPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TarefasList extends StatelessWidget {
  const TarefasList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TarefasModel>(
      builder: (context, tarefasModel, child) {
        return ListView.builder(
          itemCount: tarefasModel.tarefas.length,
          itemBuilder: (context, index) {
            final tarefa = tarefasModel.tarefas[index];
            return ListTile(
              title: Text(tarefa.nome),
              subtitle: Text(
                  "Custo: R\$${tarefa.custo.toStringAsFixed(2)} - Data Limite: ${DateFormat('dd/MM/yyyy').format(tarefa.dataLimite)}"),
              tileColor: tarefa.custo >= 1000 ? Colors.yellow : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () {
                      tarefasModel.subirTarefa(tarefa.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: () {
                      tarefasModel.descerTarefa(tarefa.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Navega para a página de edição e passa a tarefa
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdicionarTarefaPage(
                              tarefa: tarefa), // Passa a tarefa para edição
                        ),
                      ).then((_) {
                        // Recarrega a lista de tarefas após a edição
                        tarefasModel.fetchTarefas();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Função para excluir a tarefa com confirmação
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Excluir Tarefa'),
                          content: const Text(
                              'Tem certeza que deseja excluir esta tarefa?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                tarefasModel.excluirTarefa(tarefa.id);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
