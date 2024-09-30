import 'package:json_annotation/json_annotation.dart';

part 'room.model.g.dart';

@JsonSerializable()
class Message {
  String content;
  DateTime dateTime;
  bool isAgentName;

  Message({required this.content, required this.dateTime, this.isAgentName = false});

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class Room {
  String agentName;
  int nbNewMessages;
  bool isPinned;
  List<Message> messages;
  int indexPinnedMessage;

  int get nbMessages => messages.length;

  Message? get lastMessage => messages.isEmpty ? null : messages.last;

  Room({
    required this.agentName,
    this.nbNewMessages = 0,
    this.isPinned = false,
    List<Message>? messages,
    this.indexPinnedMessage = -1,
  }) : messages = messages ?? [];

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);
}
