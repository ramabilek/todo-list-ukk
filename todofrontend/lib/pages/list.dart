import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'task.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});
  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<dynamic> lists = [];
  final baseUrl = 'http://127.0.0.1:8001/api/lists';
  final color = const Color.fromARGB(255, 91, 255, 192);

  @override
  void initState() {
    super.initState();
    fetchLists();
  }

  Future<void> fetchLists() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/get'));
      if (res.statusCode == 200) {
        setState(() => lists = json.decode(res.body));
      }
    } catch (_) {}
  }

  Future<void> submitList(String name, {int? id}) async {
    if (name.isEmpty) return;
    final url =
        Uri.parse(id == null ? '$baseUrl/create' : '$baseUrl/update/$id');
    final res = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}));
    if ([200, 201].contains(res.statusCode)) fetchLists();
  }

  Future<void> deleteList(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/delete/$id'));
    if (res.statusCode == 200) fetchLists();
  }

  void showInput({Map<String, dynamic>? list}) {
    final ctrl = TextEditingController(text: list?['name'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(list != null ? 'Edit' : 'Tambah'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nama tugas'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: color, foregroundColor: Colors.black),
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                submitList(name, id: list?['id']);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget buildListTile(Map<String, dynamic> list) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(list['name'], style: const TextStyle(color: Colors.black)),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskPage(list: list)),
        ).then((_) => fetchLists()),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () => showInput(list: list)),
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.black),
                onPressed: () => deleteList(list['id'])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        centerTitle: true,
        title:
            const Text('Todos Esemka', style: TextStyle(color: Colors.black)),
      ),
      body: lists.isEmpty
          ? const Center(child: Text('Belum ada tugas'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lists.length,
              itemBuilder: (_, i) => buildListTile(lists[i])),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        onPressed: () => showInput(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}