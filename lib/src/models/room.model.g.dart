// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      content: json['content'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      isAgentName: json['isAgentName'] as bool? ?? false,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'content': instance.content,
      'dateTime': instance.dateTime.toIso8601String(),
      'isAgentName': instance.isAgentName,
    };

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
      agentName: json['agentName'] as String,
      nbNewMessages: (json['nbNewMessages'] as num?)?.toInt() ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      indexPinnedMessage: (json['indexPinnedMessage'] as num?)?.toInt() ?? -1,
    );

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'agentName': instance.agentName,
      'nbNewMessages': instance.nbNewMessages,
      'isPinned': instance.isPinned,
      'messages': instance.messages,
      'indexPinnedMessage': instance.indexPinnedMessage,
    };
