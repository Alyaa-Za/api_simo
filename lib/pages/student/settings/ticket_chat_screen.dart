import 'package:flutter/material.dart';
import '../../../core/ui/app_color.dart';

class TicketChatScreen extends StatelessWidget {
  const TicketChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المحادثة مع الدعم")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _chatBubble("مرحباً، لدي مشكلة في رفع ملف السيرة الذاتية", true),
                _chatBubble("أهلاً بك، يرجى التأكد أن حجم الملف لا يتجاوز 5 ميجابايت وبصيغة PDF", false),
                _chatBubble("شكراً لك، سأحاول الآن", true),
              ],
            ),
          ),
          _messageInputField(),
        ],
      ),
    );
  }

  Widget _chatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isMe ? 0 : 15),
            bottomRight: Radius.circular(isMe ? 15 : 0),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _messageInputField() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "اكتب رسالتك...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            backgroundColor: AppColors.primaryBlue,
            child: Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
