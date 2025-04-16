import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskPage extends StatefulWidget {
  final Map<String, dynamic> list;
  const TaskPage({super.key, required this.list});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List tasks = [];
  final baseUrl = 'http://127.0.0.1:8001/api/tasks';
  final color = const Color.fromARGB(255, 91, 255, 192);
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/get'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        tasks = data.where((t) => t['list_id'] == widget.list['id']).toList();
      }
    } catch (_) {}
    setState(() => loading = false);
  }

  Future<void> submit(String name, TimeOfDay time,
      {int? id, String status = 'in progress'}) async {
    final body = {
      'name': name,
      'deadline':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'status': status,
      if (id == null) 'list_id': widget.list['id']
    };
    await http.post(
      Uri.parse(id == null ? '$baseUrl/create' : '$baseUrl/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    fetch();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> updateStatus(int id, String status) async {
    await http.post(Uri.parse('$baseUrl/update/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}));
    fetch();
  }

  Future<void> delete(int id) async {
    await http.delete(Uri.parse('$baseUrl/delete/$id'));
    fetch();
  }

  void showForm({Map? task}) {
    final nameCtrl = TextEditingController(text: task?['name'] ?? '');
    TimeOfDay? time = task != null
        ? TimeOfDay(
            hour: int.parse(task['deadline'].split(':')[0]),
            minute: int.parse(task['deadline'].split(':')[1]))
        : null;
    String status = task?['status'] ?? 'in progress';

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(task != null ? 'Edit Task' : 'Tambah Task',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nama')),
                ListTile(
                  title: Text(time != null
                      ? '${time?.hour.toString().padLeft(2, '0')}:${time?.minute.toString().padLeft(2, '0')}'
                      : 'Pilih Deadline'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final t = await showTimePicker(
                        context: context, initialTime: time ?? TimeOfDay.now());
                    if (t != null) setState(() => time = t);
                  },
                ),
                if (task != null)
                  DropdownButtonFormField(
                    value: status,
                    items: ['in progress', 'completed']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => status = v!,
                  ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: color),
                    onPressed: () {
                      if (nameCtrl.text.isEmpty || time == null) return;
                      submit(nameCtrl.text, time!,
                          id: task?['id'], status: status);
                    },
                    child: Text(task != null ? 'Perbarui' : 'Tambah'))
              ]),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: color,
            title: Text(widget.list['name'],
                style: const TextStyle(color: Colors.black))),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : tasks.isEmpty
                ? const Center(child: Text('Belum ada task'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (_, i) {
                      final t = tasks[i], done = t['status'] == 'completed';
                      return Card(
                          child: ListTile(
                              title: Text(t['name'],
                                  style: TextStyle(
                                      decoration: done
                                          ? TextDecoration.lineThrough
                                          : null)),
                              subtitle: Text(
                                  'Deadline: ${t['deadline'].substring(0, 5)}'),
                              trailing: Wrap(spacing: 4, children: [
                                IconButton(
                                    icon: Icon(
                                        done ? Icons.refresh : Icons.check,
                                        color: done
                                            ? Colors.orange
                                            : Colors.green),
                                    onPressed: () => updateStatus(t['id'],
                                        done ? 'in progress' : 'completed')),
                                IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => showForm(task: t)),
                                IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => delete(t['id']))
                              ])));
                    }),
        floatingActionButton: FloatingActionButton(
            backgroundColor: color,
            onPressed: showForm,
            child: const Icon(Icons.add, color: Colors.black)));
  }
}