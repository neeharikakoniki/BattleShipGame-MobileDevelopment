/// Demonstrates:
/// - Integrating a simple RESTful web service with authentication
/// - Saving session tokens in shared preferences
/// - Replacing the current screen with a new screen

import 'dart:convert';

import 'homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/sessionmanager.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isLoggedIn = false;
  
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // use SessionManager to check if a user is already logged in
  Future<void> _checkLoginStatus() async {
    final loggedIn = await SessionManager.isLoggedIn();

    if (mounted) {
      setState(() {
        isLoggedIn = loggedIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Battleships',
      // start at either the home or login screen
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}

/// Screen for logging in or registering a new user.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => _login(context),
                  child: const Text('Log in'),
                ),
                TextButton(
                  onPressed: () => _register(context),
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.length < 3 || password.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Both username and password should contaion atleast 3 character!')),
      );
      return;
    }
    final url = Uri.parse('http://165.227.117.48/login');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }));

    if (!mounted) return;

    if (response.statusCode == 200) {
      // Successful login. Save the session token or user info.

      // parse the session token from the response header
      await SessionManager.setSessionToken(
          json.decode(response.body)['access_token'], username);

      if (!mounted) return;

      // go to the main screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }

  Future<void> _register(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.length < 3 || password.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Both username and password should contaion atleast 3 character!')),
      );
      return;
    }

    final url = Uri.parse('http://165.227.117.48/register');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }));

    if (!mounted) return;

    if (response.statusCode == 200) {
      // Successful registration. Treat this like a login.

      // parse the session token from the response header
      //final sessionToken = response.body['accesss_token']!.split(';')[0];

      await SessionManager.setSessionToken(
          json.decode(response.body)['access_token'], username);

      if (!mounted) return;

      // go to the main screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed')),
      );
    }
  }
}
