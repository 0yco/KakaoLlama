import 'package:flutter/material.dart';
import 'package:kakaollama/src/models/room.model.dart';
import 'package:kakaollama/src/utils/build_context_extension.dart';
import 'package:intl/intl.dart';
import 'package:kakaollama/src/widgets/dummy_image.widget.dart';

class RoomTile extends StatelessWidget {
  const RoomTile({
    super.key,
    required this.room,
    required this.onEnterRoom,
    required this.onPin,
  });

  final Room room;
  final VoidCallback onEnterRoom;
  final VoidCallback onPin;

  String get _readableDate {
    final now = DateTime.now();
    final date = room.lastMessage!.dateTime;
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else if (difference.inDays < 30) {
      return '${difference.inDays ~/ 7} weeks';
    } else if (difference.inDays < 365) {
      return '${difference.inDays ~/ 30} months';
    } else {
      return '${difference.inDays ~/ 365} years';
    }
  }

  /*
    ***********
    ** Build **
    ***********
  */
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Hero(
            tag: 'nameHero${room.agentName}',
            child: Text(
              room.agentName,
              style: context.text.titleMedium,
            ),
          ),
          if (room.nbMessages != 0)
            Text(
              ' ${room.nbMessages}',
              style: context.text.labelSmall!.copyWith(color: Colors.grey.shade300),
            ),
          if (room.isPinned)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.push_pin_rounded,
                color: Theme.of(context).colorScheme.tertiary,
                size: 18,
              ),
            ),
        ],
      ),
      subtitle: room.lastMessage?.content.isEmpty ?? true
          ? null
          : Text(
              room.lastMessage!.content,
              style: context.text.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      leading: const DummyImage(),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (room.lastMessage != null)
            Text(
              _readableDate,
              style: context.text.labelSmall,
            ),
          if (room.nbNewMessages != 0)
            Badge(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              label: Text(room.nbNewMessages.toString()),
            ),
        ],
      ),
      onTap: onEnterRoom,
      onLongPress: onPin,
    );
  }
}
