enum ChatRole{ user, assistant}

class ChatMessage {
  final ChatRole role;
  final String text;

  ChatMessage(this.role, this.text);
}