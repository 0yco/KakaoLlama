import 'dart:convert';
import 'package:kakaollama/src/services/shared_pref.service.dart';
import 'package:kakaollama/src/models/room.model.dart';

class RoomsService {
  static final RoomsService _instance = RoomsService._internal();
  factory RoomsService() => _instance;
  RoomsService._internal();

  Future<void> saveRooms(List<Room> rooms) async {
    List<String> roomsJson = rooms.map((room) => jsonEncode(room.toJson())).toList();
    await SharedPrefService().prefs.setStringList('rooms', roomsJson);
  }

  Future<List<Room>> loadRooms() async {
    List<String>? roomsJson = SharedPrefService().prefs.getStringList('rooms');
    if (roomsJson != null) {
      return roomsJson.map((room) => Room.fromJson(jsonDecode(room))).toList();
    }
    return [];
  }

  Future<void> deleteRoom(Room room) async {
    List<Room> currentRooms = await loadRooms();
    currentRooms.removeWhere((r) => r.agentName == room.agentName);
    await saveRooms(currentRooms);
  }

  Future<void> clearRooms() async {
    await SharedPrefService().prefs.remove('rooms');
  }
}
