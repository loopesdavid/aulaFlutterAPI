import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue
        ),
      home: const DisneyPage(),
      );
  }
}

class DisneyPage extends StatefulWidget{
  const DisneyPage({super.key});

  @override
  State<DisneyPage> createState()=> _DisneyPageState();
}

class _DisneyPageState extends State<DisneyPage>{
  List personagens = [];

  final TextEditingController pesquisaController = TextEditingController();

  @override
  void initState(){
    super.initState();
    buscarPersonagens();
  }

  Future<void> buscarPersonagens([
    String nome ='',
  ]) async {
    String endpoint = 'https://api.disneyapi.dev/character';

    if (nome.isNotEmpty) {
      endpoint = 'https://api.disneyapi.dev/character?name=$nome';
    }
    
    final url = Uri.parse(endpoint);

    final resposta = await http.get(url);

    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);

      setState((){
        personagens = dados ['data'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disney API'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: pesquisaController,
              decoration: InputDecoration(
                hintText: 'Pesquisar personagem',
                prefixIcon:
                  const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    pesquisaController.clear();
                    buscarPersonagens();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: 
                    BorderRadius.circular(12),
                ),
              ),
              onChanged: (valor) {
                buscarPersonagens(valor);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: personagens.length,
              itemBuilder: (context, index) {
                final personagem = personagens [index];

              return Card(
                margin:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                elevation: 4,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius:
                      BorderRadius.circular(8),
                    child: Image.network(
                      personagem['imageUrl'] ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                      (
                        context,
                        error,
                        stack,
                      ) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 35,
                          ),
                        );
                      }
                    ), 
                  ),
                  title: Text(
                    personagem['name']
                        ?? 'Sem nome',
                  ),
                  subtitle: Text(
                    'ID: ${personagem['_id']} - Filme: ${personagem['films']}',
                  )
                )
              );
              }
            )
          )
        ],
      )
    );
  }
}
