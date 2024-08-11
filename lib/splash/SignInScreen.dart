import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ai_tour/login/name.dart';
import 'package:ai_tour/service/Databse.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final TextEditingController _nameController = TextEditingController();
  String uid = '';
  bool _isNextButtonEnabled = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _loadName();
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

  Future<void> _saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('Language', 'English');
  }

  Future<void> _saveUid(String? uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid ?? '');
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('AI Travel Planner')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Welcome to AI Travel Planner!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Our app helps you create customized travel itineraries based on your preferences. Sign in with Google to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final UserCredential? userCredential = await signInWithGoogle();
                    if (userCredential != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WriteName(),
                        ),
                      );
                      var UID = userCredential.user?.uid;
                      DatabaseSVC databaseService = DatabaseSVC();
                      await databaseService.saveUserToDatabase(UID);
                      _saveUid(UID);
                    }
                  } catch (e) {
                    print('Error signing in with Google: $e');
                  }
                },
                icon: Image.asset('assets/images/google_logo.png', height: 24.0),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
