import 'package:chat/api/api.dart';
import 'package:chat/helper/dialogs.dart';
import 'package:chat/main.dart';
import 'package:chat/models/chat_user.dart';
import 'package:chat/screens/auth/login_screen.dart';
import 'package:chat/screens/edit_profile_screen.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: mq.height * .03),
            CircleAvatar(
              radius: mq.width * .25,
              backgroundImage: NetworkImage(widget.user.image),
              onBackgroundImageError: (error, stackTrace) {
                const CircularProgressIndicator();
              },
              child: widget.user.image.isEmpty
                  ? const Icon(CupertinoIcons.person)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                widget.user.name,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                widget.user.email,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                widget.user.about,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            SizedBox(height: mq.height * .05),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: const Color.fromARGB(255, 231, 235, 255),
                shape: const StadiumBorder(),
                elevation: 1,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditProfileScreen(user: widget.user)));
              },
              icon: const Icon(Icons.edit),
              label: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(text: 'Custom profile'),
                  ],
                ),
              ),
            ),
            SizedBox(height: mq.height * .25),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: const Color.fromARGB(255, 231, 235, 255),
                shape: const StadiumBorder(),
                elevation: 1,
              ),
              onPressed: () async {
                if (await confirm(context)) {
                  Dialogs.showProgressBar(context);
                  await APIs.auth.signOut().then((value) async {
                    await GoogleSignIn().signOut().then((value) {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    });
                  });
                  return;
                }
              },
              icon: const Icon(Icons.logout),
              label: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(text: 'Logout'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
