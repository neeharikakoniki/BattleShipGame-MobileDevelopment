/* Topics demonstrated:
 * - Drawsers, Tabs, etc.
 */

import 'dart:convert';
import 'package:battleships/views/gameplay.dart';
import 'drawer.dart';
import 'package:battleships/views/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/sessionmanager.dart';

class HomeScreen extends StatefulWidget {
  final String baseUrl = 'http://165.227.117.48/games';

  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<dynamic>>? futurePosts;
  bool showCompleted = false;

  @override
  void initState() {
    super.initState();
    futurePosts = _loadPosts();
  }

  void _doLogout({bool isSessionTimedOut = true}) {
    // get rid of the session token
    SessionManager.clearSession();

    if (!mounted) return;

    if (isSessionTimedOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session timeout')),
      );
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ));
  }

  Future<List<dynamic>> _loadPosts() async {
    String token = await SessionManager.getSessionToken();
    final response = await http.get(Uri.parse(widget.baseUrl), headers: {
      "Authorization": token,
    });
    if (response.statusCode == 401) {
      _doLogout();
    }
    final games = json.decode(response.body);
    return games["games"] ?? [];
  }

  Future<void> _refreshPosts(bool showCompltedLoc) async {
    setState(() {
      showCompleted = showCompltedLoc;
      futurePosts = _loadPosts();
    });
  }

  Future<void> _deletePost(int id) async {
    String token = await SessionManager.getSessionToken();

    final response = await http.delete(
      Uri.parse('${widget.baseUrl}/$id'),
      headers: {
        "Authorization": token,
      },
    );

    if (response.statusCode == 401) {
      _doLogout();
    }
    _refreshPosts(showCompleted);
  }

  String getTrailingMessage(dynamic game) {
    if (game["status"] == 0) {
      return "matchmaking";
    } else if (game["status"] == 3) {
      return game["turn"] == game["position"] ? 'Your turn' : 'oppenent turn';
    } else {
      return game["status"] == game["position"] ? 'You won' : 'Opponent won';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Games"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => (_refreshPosts(showCompleted),),
          ),
        ],
      ),
      drawer: MyDrawer(
          showcompleted: showCompleted,
          refreshPage: _refreshPosts,
          logout: _doLogout),
      body: FutureBuilder<List<dynamic>>(
        future: futurePosts,
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final filteredGames = showCompleted
                ? snapshot.data!
                    .where(
                        (game) => (game['status'] == 1 || game['status'] == 2))
                    .toList()
                : snapshot.data!
                    .where(
                        (game) => (game['status'] == 0 || game['status'] == 3))
                    .toList();
            return ListView.builder(
              itemCount: filteredGames.length,
              itemBuilder: (context, index) {
                final game = filteredGames[index];
                return Dismissible(
                  key: Key(game['id'].toString()),
                  onDismissed: (_) {
                    snapshot.data!.removeAt(index);
                    _deletePost(game['id']);
                  },
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete),
                  ),
                  child: ListTile(
                    onTap: () async {
                      if (game["status"] != 0) {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                GamePlay(gameId: game['id'].toString()),
                          ),
                        );
                        setState(() {
                          _refreshPosts(showCompleted);
                        });
                      }
                    },
                    title: Text('#${game['id']}'),
                    subtitle: Text(game['player2'] != null
                        ? game['player1'] + ' vs ' + game['player2']
                        : "Waiting for opponent"),
                    trailing: Text(getTrailingMessage(game)),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
