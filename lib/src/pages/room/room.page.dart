import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kakaollama/src/models/room.model.dart';
import 'package:kakaollama/src/services/chatlog.service.dart';
import 'package:kakaollama/src/services/rooms.service.dart';
import 'package:kakaollama/src/utils/build_context_extension.dart';
import 'package:intl/intl.dart';
import 'package:kakaollama/src/widgets/dummy_image.widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({
    super.key,
    required this.room,
  });

  final Room room;

  static const routeName = '/room';

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final Set<int> _animatedMessages = {};

  bool get messageIsValid => _messageController.text.isNotEmpty && _messageController.text.length >= 20;

  /*
    ***********
    ** Logic **
    ***********
  */
  void _sendMessage(String messageContent) async {
    if (!messageIsValid) {
      return;
    }
    _messageController.clear();

    final newMessage = Message(content: messageContent, dateTime: DateTime.now());
    setState(() {
      widget.room.messages.add(newMessage);
    });

    List<Room> allRooms = await RoomsService().loadRooms();

    int roomIndex = allRooms.indexWhere((room) => room.agentName == widget.room.agentName);
    if (roomIndex != -1) {
      allRooms[roomIndex] = widget.room;
    } else {
      allRooms.add(widget.room);
    }

    RoomsService().saveRooms(allRooms);
    await ChatLogService().saveChatLog(widget.room);
    await ChatLogService().saveRoomsMetadata(allRooms);

    try {
      await callGroqApi(messageContent).then((responseContent) {
        final botMessage = Message(content: responseContent, dateTime: DateTime.now(), isAgentName: true);
        setState(() {
          widget.room.messages.add(botMessage);
        });

        int updatedRoomIndex = allRooms.indexWhere((room) => room.agentName == widget.room.agentName);
        if (updatedRoomIndex != -1) {
          allRooms[updatedRoomIndex] = widget.room;
        } else {
          allRooms.add(widget.room);
        }

        RoomsService().saveRooms(allRooms);
        ChatLogService().saveChatLog(widget.room);
      });
    } catch (e) {
      print("Erreur lors de l'appel API: $e");
    }
  }

  Future<String> callGroqApi(String message) async {
    const String url = "https://api.groq.com/openai/v1/chat/completions";
    final String apiKey = dotenv.env['GROQ_API_KEY']!;

    final headers = {
      'content-type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "llama3-8b-8192",
      "messages": [
        {"role": "user", "content": message},
      ]
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return responseData['choices'][0]['message']['content'];
      } else {
        print("Erreur de l'API : ${response.statusCode}");
        return "I'm sorry, I have encountered this error: ${response.statusCode}";
      }
    } catch (e, s) {
      print("Exception: $e");
      return "Error when the tentatives to call the API.\n\n$e\n\n$s";
    }
  }

  void _stickMessage(Message message, BuildContext context, {bool closeAfter = false}) async {
    setState(() {
      widget.room.indexPinnedMessage = widget.room.messages.indexOf(message);
    });

    List<Room> allRooms = await RoomsService().loadRooms();

    int roomIndex = allRooms.indexWhere((room) => room.agentName == widget.room.agentName);
    if (roomIndex != -1) {
      allRooms[roomIndex] = widget.room;
    } else {
      allRooms.add(widget.room);
    }

    await RoomsService().saveRooms(allRooms);

    if (closeAfter) {
      context.nav.pop();
    }
    FocusScope.of(context).unfocus();
  }


  void _deleteMessage(Message message, BuildContext context) {
    setState(() {
      widget.room.messages.remove(message);
    });
    ChatLogService().saveChatLog(widget.room);
    RoomsService().saveRooms([widget.room]);
    context.nav.pop();
    FocusScope.of(context).unfocus();
  }

  /*
    ***********
    ** Build **
    ***********
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      backgroundColor: Colors.blue.shade200,
      body: Stack(
        children: [
          Column(
            children: [
              buildChatMessages(),
              buildBottomActionBar(),
            ],
          ),
          if (widget.room.indexPinnedMessage != -1)
            buildStickyMessage(),
        ],
      ),
    );
  }

  AlertDialog buildActionMessageDialog(Message message, BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            ListTile(
              title: const Text('Copy'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                context.nav.pop();
              },
            ),
            ListTile(
              title: const Text('Share...'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(bottom: 60, left: 10, right: 10),
                    content: Text('Message shared !'),
                  ),
                );
                context.nav.pop();
                FocusScope.of(context).unfocus();
              },
            ),
            ListTile(
              title: const Text('Delete message'),
              onTap: () => _deleteMessage(message, context),
            ),
            ListTile(
              title: const Text('Stick the message on top'),
              onTap: () => _stickMessage(message, context, closeAfter: true),
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue.shade200,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => context.nav.pop(),
      ),
      title: Hero(
        tag: 'nameHero${widget.room.agentName}',
        child: Text(
          widget.room.agentName,
          style: context.text.titleLarge,
        ),
      ),
      actions: [
        Hero(
          tag: 'searchHero',
          child: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => {},
          ),
        ),
        IconButton(
          icon: const Icon(Icons.menu_open_rounded),
          onPressed: () {},
        ),
      ],
    );
  }

  Animate buildStickyMessage() {
    return Animate(
      effects: const [
        FadeEffect(
          delay: Duration(milliseconds: 500),
          duration: Duration(milliseconds: 2000),
        ),
        SlideEffect(
          delay: Duration(milliseconds: 500),
          duration: Duration(milliseconds: 1200),
          begin: Offset(0, 0.2),
          end: Offset.zero,
        ),
      ],
      child: Positioned(
        top: 10,
        left: 5,
        right: 5,
        child: Card(
          child: ExpansionTile(
            expandedAlignment: Alignment.centerLeft,
            leading: const FaIcon(FontAwesomeIcons.bullhorn, size: 20),
            title: Text('Notice!', style: context.text.titleLarge),
            collapsedIconColor: Colors.blue.shade300,
            shape: const Border(),
            onExpansionChanged: (bool expanded) {
            },
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: MarkdownBody(data: widget.room.messages[widget.room.indexPinnedMessage].content),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded buildChatMessages() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        reverse: true,
        itemCount: widget.room.messages.length,
        itemBuilder: (context, index) {
          final message = widget.room.messages[widget.room.messages.length - 1 - index];
          final messageKey = widget.room.messages.length - 1 - index;

          return Animate(
            key: ValueKey(message.dateTime),
            autoPlay: false,
            onInit: (controller) {
              if (!_animatedMessages.contains(messageKey)) {
                controller.forward();
                _animatedMessages.add(messageKey);
              } else {
                controller.value = 1;
              }
            },
            effects: [
              ScaleEffect(
                alignment: message.isAgentName ? Alignment.centerLeft : Alignment.centerRight,
                duration: const Duration(milliseconds: 400),
              ),
              const FadeEffect(),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: message.isAgentName ? MainAxisAlignment.start : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.isAgentName) const DummyImage(),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isAgentName)
                      Text(
                        widget.room.agentName,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[800]),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!message.isAgentName) ...[
                          Text(
                            DateFormat('HH:mm').format(message.dateTime),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 5),
                        ],
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) => buildActionMessageDialog(message, context),
                            ),
                            onLongPress: () => _stickMessage(message, context),
                            child: Ink(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: message.isAgentName ? Colors.white : Colors.yellow[600],
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: MarkdownBody(data: message.content),
                            ),
                          ),
                        ),
                        if (message.isAgentName) ...[
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('HH:mm').format(message.dateTime),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Animate buildBottomActionBar() {
    return Animate(
      effects: const [
        SlideEffect(
          duration: Duration(milliseconds: 800),
          begin: Offset(0, 1.5),
          end: Offset.zero,
        ),
      ],
      child: Container(
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Input message here',
                  border: InputBorder.none,
                ),
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: () {},
            ),
            Container(
              color: Colors.yellow[600],
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _sendMessage(_messageController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
