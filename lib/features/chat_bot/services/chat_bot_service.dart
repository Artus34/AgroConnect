import 'dart:convert';
import 'package:agrolink/features/config.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotService {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  final String AgroBotApiKey =
      Config.AgroBotApiKey; 
  final String apiUrl =
      Config.AgroBotApiUrl;

  Future<List<Map<String, String>>> loadChatHistory() async {
    if (user == null) return [];
    final snapshot = await firestore
        .collection("chats")
        .doc(user!.uid)
        .collection("messages")
        .orderBy("timestamp")
        .get();

    return snapshot.docs
        .map((doc) => {
              "role": doc["role"] as String,
              "text": doc["text"] as String,
            })
        .toList();
  }

  Future<void> saveMessage(String role, String text) async {
    if (user == null) return;
    await firestore
        .collection("chats")
        .doc(user!.uid)
        .collection("messages")
        .add({
      "role": role,
      "text": text,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<String> sendMessage(List<Map<String, String>> messages) async {
    final finalUrl = '$apiUrl$AgroBotApiKey';

    const String systemPrompt =
        Config.AgroBotPrompt;

    final payload = {
      'contents': [
        ...messages.map((m) => {
              'role': m['role'],
              'parts': [
                {'text': m['text']}
              ]
            }),
      ].skip(messages.length - 1).toList(),
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
    };

    final response = await http.post(
      Uri.parse(finalUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['candidates'][0]['content']['parts'][0]['text'] ??
          "Sorry, I couldn't process that.";
    } else {
      return "⚠️ Error: ${response.statusCode}";
    }
  }
}