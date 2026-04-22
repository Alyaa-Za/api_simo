import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("سجل التدريبات السابقة")),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 2,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const ListTile(
            leading: Icon(Icons.history_edu, color: Colors.orange, size: 35),
            title: Text("تدريب صيفي - مطور ويب"),
            subtitle: Text("شركة الاتصالات | 2023"),
          ),
        ),
      ),
    );
  }
}
