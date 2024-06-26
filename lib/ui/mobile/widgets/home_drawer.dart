import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/tiles/character_tile.dart';
import 'package:maid/ui/mobile/widgets/tiles/session_tile.dart';
import 'package:maid/ui/mobile/widgets/tiles/user_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<Session> sessions = [];
  Key current = UniqueKey();

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String sessionsJson = prefs.getString("sessions") ?? '[]';
    final List sessionsList = json.decode(sessionsJson);

    setState(() {
      sessions.clear();
      for (final characterMap in sessionsList) {
        sessions.add(Session.fromMap(characterMap));
      }
    });
  }

  @override
  void dispose() {
    saveSessions();
    super.dispose();
  }

  Future<void> saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    sessions.removeWhere((session) => session.key == current);
    final String sessionsJson = json.encode(sessions.map((session) => session.toMap()).toList());
    await prefs.setString("sessions", sessionsJson);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Drawer Menu",
      onTapHint: "Close Drawer",
      onTap: () {
        Navigator.pop(context);
      },
      child: Consumer<Session>(
        builder: drawerBuilder
      )
    );
  }

  Widget drawerBuilder(BuildContext context, Session session, Widget? child) {
    current = session.key;

    var contains = false;

    for (var element in sessions) {
      if (element.key == current) {
        contains = true;
        break;
      }
    }

    if (!contains) {
      sessions.insert(0, session.copy());
    }

    session.save();

    return Drawer(
      semanticLabel: "Drawer Menu",
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20)
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const CharacterTile(),
            const SizedBox(height: 5.0),
            characterButtonsRow(context),
            Divider(
              color: Theme.of(context).colorScheme.primary,
            ),
            FilledButton(
              onPressed: () {
                if (!session.chat.tail.finalised) return;
                setState(() {
                  final newSession = Session();
                  sessions.add(newSession);
                  session.from(newSession);
                });
              },
              child: const Text(
                "New Chat"
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.primary,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sessions.length, 
                itemBuilder: (context, index) {
                  return SessionTile(
                    session: sessions[index], 
                    onDelete: () {
                      if (!session.chat.tail.finalised) return;
                      setState(() {
                        if (sessions[index].key == session.key) {
                          session.from(sessions.firstOrNull ?? Session());
                        }
                        sessions.removeAt(index);
                      });
                    },
                    onRename: (value) {
                      setState(() {
                        if (sessions[index].key == session.key) {
                          session.name = value;
                        }
                        sessions[index].name = value;
                      });
                    },
                  );
                }
              ),
            ),
            Divider(
              height: 0.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 5.0),
            const UserTile()
          ]
        )
      )
    );
  }

  Widget characterButtonsRow(BuildContext context) {
    return ListTile(
      leading: FilledButton(
        onPressed: () {
          Navigator.pop(context); // Close the drawer
          Navigator.pushNamed(
            context,
            '/character'
          );
        },
        child: const Text(
          "Customize"
        ),
      ),
      trailing: FilledButton(
        onPressed: () {
          Navigator.pop(context); // Close the drawer
          Navigator.pushNamed(
            context,
            '/characters'
          );
        },
        child: const Text(
          "Browse"
        ),
      )
    );
  }
}
