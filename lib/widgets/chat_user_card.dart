import 'package:chat/api/api.dart';
import 'package:chat/helper/dialogs.dart';
import 'package:chat/helper/format_date.dart';
import 'package:chat/main.dart';
import 'package:chat/models/chat_user.dart';
import 'package:chat/models/message.dart';
import 'package:chat/screens/chat_screen.dart';
import 'package:chat/screens/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});
  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message; // để gán tin nhắn cuối cùng
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onLongPress: () {
          _showBottomSheet();
        },
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                user: widget.user,
              ),
            ),
          ),
        },
        child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(widget.user.image),
                  onBackgroundImageError: (error, stackTrace) {
                    const CircularProgressIndicator();
                  },
                  child: widget.user.image.isEmpty
                      ? const Icon(CupertinoIcons.person)
                      : null,
                ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.user.uid
                        ? Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )
                        : Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: const TextStyle(color: Colors.black54),
                          ),
                title: Text(
                  widget.user.name,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  _message != null
                      ? _message!.type == Type.image
                          ? 'image'
                          : _message!.msg
                      : widget.user.about,
                  maxLines: 1,
                ),
              );
            }),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
              _OptionItem(
                  icon: const Icon(Icons.people, color: Colors.blue, size: 26),
                  name: 'View Profile',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewProfileScreen(
                          user: widget.user,
                        ),
                      ),
                    );
                  }),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              _OptionItem(
                icon: const Icon(Icons.delete_forever,
                    color: Colors.red, size: 26),
                name: 'Delete friend',
                onTap: () async {
                  await APIs.deleteFriend(widget.user.email).then((value) {
                    if (value) {
                      Navigator.pop(context);
                      Dialogs.showSnackbar(
                        context,
                        'Delete friended',
                      );
                    } else {
                      Navigator.pop(context);
                      Dialogs.showSnackbar(
                        context,
                        'Delete Error',
                      );
                    }
                  });
                },
              ),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              // _OptionItem(
              //     icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
              //     name:
              //         'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
              //     onTap: () {}),
              // _OptionItem(
              //     icon: const Icon(Icons.remove_red_eye, color: Colors.green),
              //     name: widget.message.read.isEmpty
              //         ? 'Read At: Not seen yet'
              //         : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
              //     onTap: () {}),
            ],
          );
        });
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
