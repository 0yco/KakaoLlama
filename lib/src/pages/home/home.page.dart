import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kakaollama/src/models/room.model.dart';
import 'package:kakaollama/src/controller/settings.controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kakaollama/src/pages/home/widgets/room_tile.widget.dart';
import 'package:kakaollama/src/pages/room/room.page.dart';
import 'package:kakaollama/src/services/chatlog.service.dart';
import 'package:kakaollama/src/services/rooms.service.dart';
import 'package:kakaollama/src/utils/build_context_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Room> rooms = [];
  String _sortOption = 'name';
  bool refreshAnimation = true;

  /*
    ***********
    ** Logic **
    ***********
  */
  @override
  void initState() {
    super.initState();
    _loadRooms();
    _loadSortPreference();
  }

  void _loadRooms() async {
    final loadedRooms = await RoomsService().loadRooms();
    setState(() {
      rooms = loadedRooms;
      _sortRooms();
    });
  }

  Future<void> _loadSortPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _sortOption = prefs.getString('sortOption') ?? 'name';
      _sortRooms();
    });
  }

  void _showAddRoomDialog() {
   
  }

  void _addRoom(String agentName) async {
    setState(() {
      rooms.add(Room(agentName: agentName));
      _sortRooms();
    });
    await ChatLogService().createEmptyChatLog(agentName);
    await RoomsService().saveRooms(rooms);
  }

  Future<void> _saveSortPreference(String option) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sortOption', option);
  }

  void _sortRooms() {
    rooms.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      if (_sortOption == 'name') {
        return a.agentName.compareTo(b.agentName);
      } else if (_sortOption == 'date') {
        return (b.lastMessage?.dateTime ?? DateTime(0)).compareTo(a.lastMessage?.dateTime ?? DateTime(0));
      }
      return 0;
    });
  }

  void _onEnterRoom(Room room) async {
    setState(() {
      refreshAnimation = false;
      if (room.nbNewMessages > 0) {
        room.nbNewMessages = 0;
      }
    });
    await context.nav.pushNamed(
      RoomPage.routeName,
      arguments: room,
    );
    setState(() {
      refreshAnimation = true;
    });
  }

  void _confirmOnPin(Room room, BuildContext context) {
    setState(() {
      room.isPinned = !room.isPinned;
      _sortRooms();
    });
    RoomsService().saveRooms(rooms);
    context.nav.pop();
  }

  void _deleteRoom(int index, BuildContext context, Room room) {
    setState(() {
      rooms.removeAt(index);
    });
    RoomsService().saveRooms(rooms);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${room.agentName} supprimé')),
    );
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
      body: buildListRooms(),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  AlertDialog buildAddRoomDialog(BuildContext context) {
    final roomNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text('Agent Name'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: roomNameController,
          autofocus: true,
          maxLines: 1,
          decoration: const InputDecoration(
            labelText: 'New chat',
            hintText: 'Ex: Chung-Ang University',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'The name is required';
            }
            if (value.length > 10) {
              return 'Name cannot be longer than 10 characters';
            }
            final regex = RegExp(r'^[a-zA-Z0-9\s\-]+$');
            if (!regex.hasMatch(value)) {
              return 'Use only letters, numbers, and spaces';
            }
            return null;
          },
          onFieldSubmitted: (value) {
            if (formKey.currentState!.validate()) {
              _addRoom(roomNameController.text.trim());
              context.nav.pop();
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.nav.pop(),
          child: Text('Cancel', style: TextStyle(color: context.color.onSurface.withOpacity(0.6))),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              _addRoom(roomNameController.text.trim());
              context.nav.pop();
            }
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

   AlertDialog buildPinnedRoomDialog(Room room, BuildContext context) {
    String title;
    String content;

    if (room.isPinned) {
      title = 'Unstick on Top';
      content = 'Do you want to remove \'${room.agentName}\' from the top of the list ?';
    } else {
      title = 'Stick on Top';
      content = 'Do you want to put \'${room.agentName}\' on top of the list ?';
    }

    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => context.nav.pop(),
          child: Text('No', style: TextStyle(color: context.color.onSurface.withOpacity(0.6))),
        ),
        TextButton(
          onPressed: () => _confirmOnPin(room, context),
          child: const Text('Yes'),
        ),
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Animate(
        target: refreshAnimation ? 1 : 0,
        effects: const [
          ScaleEffect(
            alignment: Alignment.centerLeft,
            delay: Duration(milliseconds: 200),
          ),
          FadeEffect(
            delay: Duration(milliseconds: 200),
          ),
        ],
        child: const Text('Chatting'),
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
          icon: const Icon(Icons.add_comment_outlined),
          onPressed: () => showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => buildAddRoomDialog(context),
          ),
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.moon),
          selectedIcon: const FaIcon(FontAwesomeIcons.sun),
          isSelected: Theme.of(context).brightness == Brightness.dark,
          onPressed: () => SettingsController().toggleThemeMode(),
        ),
        FutureBuilder(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            final packageInfo = snapshot.data as PackageInfo;

            return IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () => showAboutDialog(
                context: context,
                applicationIcon: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  child: Image.asset('assets/icons/kakaollama_logo.png', width: 75),
                ),
                applicationName: 'KakaoLlama',
                barrierDismissible: false,
                applicationVersion: packageInfo.version,
                applicationLegalese: '© 2024 KakaoLlama',
              ),
            );
          },
        ),
      ].animate(
        effects: const [
          ScaleEffect(
            delay: Duration(milliseconds: 200),
          ),
          FadeEffect(
            delay: Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Animate buildListRooms() {
    return Animate(
      effects: const [
        SlideEffect(
          duration: Duration(milliseconds: 800),
          begin: Offset(0, 0.2),
          end: Offset.zero,
        ),
        FadeEffect(
          delay: Duration(milliseconds: 200),
          duration: Duration(milliseconds: 1500),
        ),
      ],
      child: ListView.builder(
        restorationId: 'roomListView',
        itemCount: rooms.length,
        itemBuilder: (BuildContext context, int index) {
          final room = rooms[index];

          return Dismissible(
            key: Key(room.agentName),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: AlignmentDirectional.centerEnd,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) => _deleteRoom(index, context, room),
            child: RoomTile(
              room: room,
              onEnterRoom: () => _onEnterRoom(room),
              onPin: () => showDialog(
                context: context,
                builder: (BuildContext context) => buildPinnedRoomDialog(room, context),
              ),
            ),
          );
        },
      ),
    );
  }

  Animate buildBottomNavigationBar() {
    return Animate(
      target: refreshAnimation ? 1 : 0,
      effects: const [
        SlideEffect(
          duration: Duration(milliseconds: 800),
          begin: Offset(0, 1.5),
          end: Offset.zero,
        ),
      ],
      child: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Sort by name',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Sort by date',
          ),
        ],
        currentIndex: _sortOption == 'name' ? 0 : 1,
        onTap: (index) {
          String selectedSort = index == 0 ? 'name' : 'date';
          setState(() {
            _sortOption = selectedSort;
            _saveSortPreference(selectedSort);
            _sortRooms();
          });
        },
      ),
    );
  }
}
