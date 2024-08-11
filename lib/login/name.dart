import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_tour/login/loginPage.dart';
import 'package:ai_tour/service/Databse.dart';
import 'package:ai_tour/service/gemini.dart';
import 'package:ai_tour/plan/tour.dart';
import 'package:firebase_database/firebase_database.dart';

class WriteName extends StatefulWidget {
  const WriteName({super.key});

  @override
  _WriteNameState createState() => _WriteNameState();
}

class _WriteNameState extends State<WriteName> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', '한국어'];
  bool _isNextButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    _loadName();
    _loadLanguage();
    _nameController.addListener(_updateNextButtonState);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateNextButtonState);
    _nameController.dispose();
    super.dispose();
  }

  void _updateNextButtonState() {
    setState(() {
      _isNextButtonEnabled = _nameController.text.isNotEmpty;
    });
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('userName') ?? '';
    _nameController.text = savedName;
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('Language') ?? 'English';
    setState(() {
      _selectedLanguage = savedLanguage;
    });
  }

  Future<void> _saveNameAndLanguage(String name, String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('Language', language);

    String? uid = prefs.getString('uid');
    if (uid != null) {
      DatabaseReference ref = FirebaseDatabase.instance.ref().child(uid);
      await ref.set({'name': name, 'lang': language});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Language Selection')),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Write your name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: const InputDecoration(
                    labelText: 'Select Language',
                    border: OutlineInputBorder(),
                  ),
                  items: _languages.map((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isNextButtonEnabled
                      ? () async {
                    var name = _nameController.text;
                    await _saveNameAndLanguage(name, _selectedLanguage);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserMainPage(),
                      ),
                    );
                  }
                      : null,
                  child: const Text('Next'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
