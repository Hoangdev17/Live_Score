import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class FootballChatScreen extends StatefulWidget {
  @override
  _FootballChatScreenState createState() => _FootballChatScreenState();
}

class _FootballChatScreenState extends State<FootballChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late GenerativeModel _model;
  late ChatSession _chat;
  String _userName = '';
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();

  // Hệ thống prompt chuyên gia bóng đá thân thiện
  final String footballExpertPrompt = """
Bạn là LiveScoreAI - trợ lý ảo đa năng với kiến thức sâu rộng về bóng đá. Hãy:

1. PHONG CÁCH:
- Luôn thân thiện, nhiệt tình
- Trả lời mọi câu hỏi với thái độ tích cực
- Sử dụng ngôn ngữ tự nhiên, gần gũi
- Kèm biểu tượng cảm xúc phù hợp khi cần

2. KIẾN THỨC:
- Chuyên sâu về bóng đá (giải đấu, cầu thủ, chiến thuật)
- Có thể thảo luận các chủ đề khác khi được hỏi
- Luôn cung cấp thông tin chính xác nhất

3. TƯƠNG TÁC:
- Khuyến khích đối thoại
- Sẵn sàng chuyển chủ đề khi cần
- Luôn tôn trọng người dùng
""";

  @override
  void initState() {
    super.initState();
    _initChat();
    _askForUserName();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _scrollToBottom();
    }
  }

  Future<void> _initChat() async {
    try {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: 'AIzaSyBdYZaPmM-26f3ssdAW_kcztqCSOwyM-0g',
        generationConfig: GenerationConfig(
          temperature: 0.5,
          maxOutputTokens: 2000,
          topP: 0.9,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        ],
      );

      _chat = _model.startChat(history: [
        Content.text(footballExpertPrompt),
      ]);
    } catch (e) {
      debugPrint('Lỗi khởi tạo model: $e');
    }
  }

  void _askForUserName() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Xin chào!", style: TextStyle(color: Colors.blue)),
            content: TextField(
              decoration: InputDecoration(
                hintText: "Tên của bạn là gì? (không bắt buộc)",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _userName = value,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addWelcomeMessages();
                },
                child: Text("Bắt đầu trò chuyện", style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      );
    });
  }

  void _addWelcomeMessages() {
    final welcomeMessages = [
      "Xin chào ${_userName.isNotEmpty ? _userName : 'bạn'}! 👋",
      "Mình là LiveScoreAI - trợ lý đa năng của bạn",
      "Mình có thể:",
      "• Thảo luận chuyên sâu về bóng đá ⚽",
      "• Trò chuyện về nhiều chủ đề khác nhau 💬",
      "• Giải đáp các thắc mắc của bạn ❓",
      "Cứ thoải mái hỏi mình bất cứ điều gì nhé! 😊",
    ];

    setState(() {
      for (var msg in welcomeMessages) {
        _messages.add(ChatMessage(text: msg, isUser: false));
      }
      _scrollToBottom();
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _isLoading = true;
      _messageController.clear();
      _scrollToBottom();
    });

    final thinkingMsg = ChatMessage(
      text: _getRandomThinkingMessage(),
      isUser: false,
    );
    setState(() {
      _messages.add(thinkingMsg);
      _scrollToBottom();
    });

    try {
      final response = await _chat.sendMessage(Content.text(message));

      setState(() {
        _messages.removeLast();
        _messages.add(
          ChatMessage(
            text: _addPersonalTouch(response.text ?? "Mình chưa thể trả lời câu hỏi này ngay bây giờ."),
            isUser: false,
          ),
        );
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(
          ChatMessage(
            text: "Xin lỗi, có chút trục trặc. Bạn vui lòng thử lại nhé! 😢",
            isUser: false,
          ),
        );
        _scrollToBottom();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getRandomThinkingMessage() {
    final messages = [
      "Để mình suy nghĩ một chút... 🤔",
      "Mình đang tìm câu trả lời tốt nhất cho bạn... 🔍",
      "Một lát thôi, mình đang xử lý... ⏳",
    ];
    return messages[_random.nextInt(messages.length)];
  }

  String _addPersonalTouch(String response) {
    if (_userName.isNotEmpty) {
      response = response.replaceFirst(RegExp(r'(Chào|Xin chào|Hi|Hello)'), "Chào $_userName");
    }

    // Thêm cảm xúc phù hợp
    if (response.length < 100) {
      final emojis = ['😊', '👍', '🌟', '💡', '🎯'];
      response += ' ${emojis[_random.nextInt(emojis.length)]}';
    }

    return response;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text('LiveScoreAI 💬', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Text("AI", style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blueAccent : Color(0xFF333333),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(12),
      color: Color(0xFF1E1E1E),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Nhập nội dung trò chuyện...",
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Color(0xFF333333),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isLoading ? Colors.grey : Colors.blueAccent,
            ),
            child: IconButton(
              icon: Icon(_isLoading ? Icons.hourglass_top : Icons.send_rounded),
              color: Colors.white,
              onPressed: _isLoading ? null : _sendMessage,
              tooltip: 'Gửi tin nhắn',
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}