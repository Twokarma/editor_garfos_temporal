import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class AiServiceException implements Exception{
  final String message;
  AiServiceException(this.message);

  @override
  String toString() => message;
}

class AiService {
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _model = "openai/gpt-oss-20b";
  static const String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  static String? _cachedDocs;

  static Future<String> _loadDocumentation() async {
    _cachedDocs ??= await rootBundle.loadString('assets/docs/app_knowledge.md');
    return _cachedDocs!;
  }

  static Future<String> sendMessage({
    required String userMessage,
    required List<ChatMessage> history,
    required String graphSummaryJson,
  }) async {
    if (_apiKey.isEmpty) {
      throw AiServiceException(
        "No API key configured. Run the app with "
            "--dart-define=GROQ_API_KEY=your-key",
      );
    }

    final documentation = await _loadDocumentation();

    final systemPrompt =
        "You are the in-app AI assistant for Graph Maker, a mobile app for "
        "creating and editing directed, weighted graphs. Answer questions "
        "about how to use the app's features (using the documentation "
        "below), and about the graph the user currently has open (using "
        "the graph state provided). Be concise and friendly.\n\n"
        "App documentation:\n$documentation\n\n"
        "Current graph state (JSON):\n$graphSummaryJson";

    final List<Map<String, dynamic>> messages = [
      {"role": "system", "content": systemPrompt},
      for (final m in history)
        {
          "role": m.role == ChatRole.user ? "user" : "assistant",
          "content": m.text,
        },
      {"role": "user", "content": userMessage},
    ];

    final body = jsonEncode({
      "model": _model,
      "max_tokens": 4096,
      "messages": messages,
    });

    http.Response response;
    try {
      response = await http
          .post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: body,
      )
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw AiServiceException(
        "The request timed out. Please check your connection and try again.",
      );
    } on SocketException {
      throw AiServiceException(
        "No internet connection. Please check your network and try again.",
      );
    } on http.ClientException {
      throw AiServiceException(
        "Couldn't reach the AI service. Please try again.",
      );
    }

    if (response.statusCode != 200) {
      String detail;
      try {
        final decoded = jsonDecode(response.body);
        detail = decoded["error"]?["message"] ?? "HTTP ${response.statusCode}";
      } catch (_) {
        detail = "HTTP ${response.statusCode}";
      }
      throw AiServiceException("AI service error: $detail");
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded["choices"] as List<dynamic>? ?? [];
    final reply = choices.isNotEmpty
        ? (choices[0]["message"]?["content"] as String? ?? "")
        : "";

    if (reply.trim().isEmpty) {
      throw AiServiceException(
        "The assistant didn't return a response. Please try again.",
      );
    }

    return reply;
  }
}