import 'package:battleships/utils/sessionmanager.dart';
import 'package:battleships/views/newgame.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final void Function(bool) refreshPage;
  final void Function({bool isSessionTimedOut}) logout;
  final bool showcompleted;

  const MyDrawer(
      {required this.showcompleted,
      required this.refreshPage,
      required this.logout,
      super.key});

  Future<String> getusername() async {
    return await SessionManager.getSessionUserName();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getusername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Return a loading indicator or placeholder widget while waiting for the future to complete.
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle the error case
          return Text('Error: ${snapshot.error}');
        } else {
          // The future is completed successfully, use the result
          String username = snapshot.data ??
              ''; // Default to an empty string if the result is null

          // Now you can use the username variable in your widget tree
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blue),
                  curve: Curves.fastOutSlowIn,
                  child: ListTile(
                    title: const Text('Battleships'),
                    subtitle: Text('Logged in as: $username'),
                  ),
                ),
                ListTile(
                  title: const Text("New Game"),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const NewGame(
                          isAgainstAI: false,
                          typeOfAI: '',
                        ),
                      ),
                    );
                    if (!context.mounted) return;
                    refreshPage(showcompleted);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text("New game (AI)"),
                  onTap: () async {
                    await showOptionsDialog(context);
                    if (!context.mounted) return;
                    refreshPage(showcompleted);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(
                      !showcompleted ? "Show Completed" : "Show active games"),
                  onTap: () {
                    refreshPage(!showcompleted);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text("Log out"),
                  onTap: () {
                    logout(isSessionTimedOut: false);
                  },
                )
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> showOptionsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Which AI do you want to play against?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const NewGame(
                        isAgainstAI: true,
                        typeOfAI: "random",
                      ),
                    ),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Random'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const NewGame(
                        isAgainstAI: true,
                        typeOfAI: "perfect",
                      ),
                    ),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Perfect'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const NewGame(
                        isAgainstAI: true,
                        typeOfAI: "oneship",
                      ),
                    ),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('One ship (AI)'),
              ),
            ],
          ),
        );
      },
    );
  }
}
