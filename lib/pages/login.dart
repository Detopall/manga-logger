import 'package:flutter/material.dart';
import 'package:manga_logger/models/database_helper.dart';
import 'package:manga_logger/models/user.dart';
import 'package:manga_logger/pages/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<User> _users = [];
  bool _loading = true;
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      List<User> users = await _dbHelper.getUsers();
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _login(User user) async {
    try {
      if (!mounted) return;

      await _dbHelper.setLastLoggedInUser(user.userId);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(user: user),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to log in. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _createNewProfile() async {
    String username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      try {
        User user;
        try {
          user = await _dbHelper.getUserByUsername(username);
        } catch (e) {
          await _dbHelper.insertUser(username);
          user = await _dbHelper.getUserByUsername(username);
        }

        if (!mounted) return;

        await _dbHelper.setLastLoggedInUser(user.userId);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(user: user),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Failed to create a new profile. Please try again.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
        home: Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Manga Logger',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'PermanentMarker',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 35,
                  child: Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PermanentMarker',
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color.fromRGBO(124, 30, 232, 0.5),
            centerTitle: true,
            elevation: 0.0,
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isDarkMode = !isDarkMode;
                  });
                },
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: ListView(
                          children: [
                            ..._users.map((user) => Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(10.0),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            user.username,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'PermanentMarker',
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                            icon: const Icon(Icons.delete),
                                            color: Colors.red,
                                            onPressed: () => _removeUser(user),
                                            padding: const EdgeInsets.all(10.0),
                                            iconSize: 30.0),
                                      ],
                                    ),
                                    onTap: () => _login(user),
                                    leading: const Icon(Icons.person),
                                    tileColor: Colors.grey[200],
                                    textColor: Colors.black,
                                    iconColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: _newUsername(),
                            ),
                            const SizedBox(height: 20),
                            _newProfileBtn(),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ));
  }

  void _removeUser(User user) async {
    // Show confirmation dialog
    if (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Are you sure you want to delete \n',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              TextSpan(
                text: user.username,
                style: const TextStyle(
                  fontFamily: 'PermanentMarker',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const TextSpan(
                text: '?',
                style: TextStyle(fontFamily: 'PermanentMarker', fontSize: 16),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    )) {
      await _dbHelper.deleteUser(user.userId);
      setState(() {
        _users.remove(user);
      });
    }
  }

  TextField _newUsername() {
    return TextField(
      controller: _usernameController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person),
        hintText: 'New Username',
        hintStyle:
            TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
      ),
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      cursorColor: isDarkMode ? Colors.white : Colors.black,
    );
  }

  ElevatedButton _newProfileBtn() {
    return ElevatedButton(
      onPressed: _createNewProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(124, 30, 232, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(
        'Create New Profile',
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'PermanentMarker',
          fontSize: 16,
        ),
      ),
    );
  }
}
