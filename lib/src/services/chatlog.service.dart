import 'dart:io';
import 'dart:convert';
import 'package:kakaollama/src/models/room.model.dart';
import 'package:path_provider/path_provider.dart';

class ChatLogService {
  Future<String> _getDownloadDirectoryPath() async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  Future<File> _getChatLogFile(String agentName) async {
    final path = await _getDownloadDirectoryPath();
    return File('$path/log_$agentName.json');
  }

  Future<File> _getChatRoomsFile() async {
    final path = await _getDownloadDirectoryPath();
    return File('$path/chatlog.json');
  }

  Future<void> saveChatLog(Room room) async {
    final file = await _getChatLogFile(room.agentName);
    final logData = room.messages.map((message) => message.toJson()).toList();
    await file.writeAsString(jsonEncode(logData), flush: true);
  }

  Future<void> saveRoomsMetadata(List<Room> rooms) async {
    final file = await _getChatRoomsFile();
    final roomMetadata = rooms.map((room) => room.toJson()).toList();
    await file.writeAsString(jsonEncode(roomMetadata), flush: true);
  }

  Future<List<Message>> loadChatLog(String agentName) async {
    final file = await _getChatLogFile(agentName);
    if (await file.exists()) {
      final content = await file.readAsString();
      List<dynamic> jsonData = jsonDecode(content);
      return jsonData.map((data) => Message.fromJson(data)).toList();
    }
    return [];
  }

  Future<List<Room>> loadRoomsMetadata() async {
    final file = await _getChatRoomsFile();
    if (await file.exists()) {
      final content = await file.readAsString();
      List<dynamic> jsonData = jsonDecode(content);
      return jsonData.map((data) => Room.fromJson(data)).toList();
    }
    return [];
  }

  Future<void> createEmptyChatLog(String agentName) async {
    final file = await _getChatLogFile(agentName);
    await file.writeAsString(jsonEncode([]), flush: true);
  }
}
