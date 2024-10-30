import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Tarefa {
  final int id;
  final String nome;
  final double custo;
  final DateTime dataLimite;
  int ordem; // Mude de final para int

  Tarefa({
    required this.id,
    required this.nome,
    required this.custo,
    required this.dataLimite,
    required this.ordem,
  });

  // Construtor para criar a tarefa a partir do JSON da API
  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'],
      nome: json['nome_tarefa'],
      custo: double.parse(json['custo'].toString()),
      dataLimite: DateTime.parse(json['data_limite']),
      ordem: json['ordem_apresentacao'],
    );
  }

  // Converte a tarefa para JSON para enviar ao backend
  Map<String, dynamic> toJson() => {
        'nome_tarefa': nome,
        'custo': custo,
        'data_limite': dataLimite.toIso8601String(),
      };
}

class TarefasModel extends ChangeNotifier {
  List<Tarefa> _tarefas = [];

  List<Tarefa> get tarefas => _tarefas;

  final String apiUrl = 'http://localhost:3000/tarefas';

  // Busca todas as tarefas da API
  Future<void> fetchTarefas() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> tarefasData = json.decode(response.body);
      _tarefas = tarefasData.map((data) => Tarefa.fromJson(data)).toList();
      notifyListeners();
    } else {
      throw Exception('Erro ao carregar tarefas');
    }
  }

  // Adiciona uma nova tarefa usando a API
  Future<void> adicionarTarefa(Tarefa tarefa) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tarefa.toJson()),
    );
    if (response.statusCode == 200) {
      final novaTarefa = Tarefa.fromJson(json.decode(response.body));
      _tarefas.add(novaTarefa);
      notifyListeners();
    } else {
      throw Exception('Erro ao adicionar tarefa');
    }
  }

  // Edita uma tarefa existente usando a API
  Future<void> editarTarefa(Tarefa tarefa) async {
    final response = await http.put(
      Uri.parse('$apiUrl/${tarefa.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tarefa.toJson()),
    );
    if (response.statusCode == 200) {
      final index = _tarefas.indexWhere((t) => t.id == tarefa.id);
      if (index != -1) {
        _tarefas[index] = Tarefa.fromJson(json.decode(response.body));
        notifyListeners();
      }
    } else {
      throw Exception('Erro ao editar tarefa');
    }
  }

  // Exclui uma tarefa usando a API
  Future<void> excluirTarefa(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      _tarefas.removeWhere((tarefa) => tarefa.id == id);
      notifyListeners();
    } else {
      throw Exception('Erro ao excluir tarefa');
    }
  }

  // Função para subir a tarefa
  void subirTarefa(int id) {
    final index = _tarefas.indexWhere((tarefa) => tarefa.id == id);
    if (index > 0) {
      // Troca a ordem
      final tarefa = _tarefas[index];
      tarefa.ordem--;
      _tarefas[index] = _tarefas[index - 1];
      _tarefas[index - 1] = tarefa;

      // Atualiza as ordens
      _tarefas[index].ordem++;
      _tarefas[index - 1].ordem--;

      notifyListeners();
    }
  }

  // Função para descer a tarefa
  void descerTarefa(int id) {
    final index = _tarefas.indexWhere((tarefa) => tarefa.id == id);
    if (index < _tarefas.length - 1) {
      // Troca a ordem
      final tarefa = _tarefas[index];
      tarefa.ordem++;
      _tarefas[index] = _tarefas[index + 1];
      _tarefas[index + 1] = tarefa;

      // Atualiza as ordens
      _tarefas[index].ordem--;
      _tarefas[index + 1].ordem++;

      notifyListeners();
    }
  }
}
