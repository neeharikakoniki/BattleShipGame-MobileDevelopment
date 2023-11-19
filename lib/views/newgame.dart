import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/sessionmanager.dart';
import 'loginpage.dart';

class NewGame extends StatefulWidget {
  final bool isAgainstAI;
  final String typeOfAI;
  const NewGame({required this.isAgainstAI, required this.typeOfAI, super.key});

  @override
  MyFormState createState() => MyFormState();
}

class MyFormState extends State<NewGame> {
  Set<String> selectedLabels = <String>{};

  void _doLogout() async {
    // get rid of the session token
    await SessionManager.clearSession();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session timeout')),
    );

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ));
  }

  Future<void> _addPost() async {
    String token = await SessionManager.getSessionToken();
    List<String> shipList = selectedLabels.toList();
    var js = jsonEncode({
      'ships': shipList,
      if (widget.isAgainstAI) 'ai': widget.typeOfAI,
    });
    final url = Uri.parse('http://165.227.117.48/games');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": token,
        },
        body: js);
    if (response.statusCode == 401) {
      _doLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add ships'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Grid without spaces between cells
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6, // 5 columns + 1 for labels
                    crossAxisSpacing: 0.0,
                    mainAxisSpacing: 0.0,
                  ),
                  itemCount: 36, // 5 rows * 6 columns
                  itemBuilder: (BuildContext context, int index) {
                    String label;

                    if (index == 0) {
                      label = '';
                    } else if (index <= 5) {
                      label = index.toString();
                    } else {
                      label = String.fromCharCode((index / 6).floor() + 64);
                    }

                    // Skip the first column for labels
                    if (index <= 5 || index % 6 == 0) {
                      return Container(
                        color: Colors.white10,
                        child: Center(
                          child: Text(
                            label,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    }

                    // Calculate the row and column index for the grid cells
                    int row = ((index - 1) / 6).floor();
                    int col = (index - 1) % 6;
                    label = '${String.fromCharCode(row + 65 - 1)}${col + 1}';
                    // You can replace the Placeholder widget with your form fields

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedLabels.contains(label)) {
                            selectedLabels.remove(label);
                          } else {
                            selectedLabels.add(label);
                          }
                        });
                      },
                      child: Container(
                        color: selectedLabels.contains(label)
                            ? Colors.green
                            : Colors.white10,
                      ),
                    );
                  },
                ),
              ),
              //const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async{
                  if (selectedLabels.length != 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Plesae select 5 ships to submit the game')),
                    );
                  } else {
                    await _addPost();

                    if(!mounted) return;
                    Navigator.pop(context);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
