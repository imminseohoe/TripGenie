import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_tour/login/planCard.dart';
import 'package:ai_tour/plan/planForm.dart';
import '../service/Databse.dart';
import 'package:firebase_database/firebase_database.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({Key? key}) : super(key: key);

  @override
  _UserMainPageState createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  final TextEditingController _nameController = TextEditingController();
  List<PlanCard> tripCards = [];
  String _userName = '';
  String _language = '';
  var uid = '';

  @override
  void initState() {
    super.initState();
    _getUserName();
    _getLanguage();
    _fetchTripData();

  }

  Future<void> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? '';
    });
  }

  Future<void> _getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('Language') ?? '';
      uid = prefs.getString('uid')!;
    });
  }
  Future<void> _fetchTripData() async {
    final prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    if (uid == null) {
      print('UID is null');
      return;
    }

    DatabaseSVC databaseService = DatabaseSVC();

    DatabaseEvent event = await databaseService.getTrips(uid);
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> tripsData = snapshot.value as Map<dynamic, dynamic>;
      List<PlanCard> newTripCards = [];

      tripsData.forEach((key, value) {
        try {

          var tourPlan = value['tourPlan'];



          // LinkedMap<Object?, Object?> 타입을 Map<String, dynamic>으로 캐스팅
          Map<String, dynamic> jsonMap = Map<String, dynamic>.from(tourPlan);

          newTripCards.add(PlanCard(
            tripName: value['title'] ?? 'Unnamed Trip',
            startDate: value['startday'] ?? 'No start date',
            endDate: value['endday'] ?? 'No end date',
            imageUrl: value['imageurl'] ?? 'https://picsum.photos/250?image=9',
            tourPlan: jsonMap,
          ));
        } catch (e) {
          print('Error decoding details for trip $key: $e');
        }
      });


      setState(() {
        tripCards = newTripCards;
      });
    }
  }

  void _planNewTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TravelDetails(),
      ),
    );
  }



  Future<void> _changeUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController textEditingController = TextEditingController();
        return AlertDialog(
          title: const Text('이름 변경'),
          content: TextField(
            controller: textEditingController,
            decoration: const InputDecoration(hintText: '새로운 이름을 입력하세요'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () async {
                final newUserName = textEditingController.text.trim();
                final prefs = await SharedPreferences.getInstance();
                String? uid = prefs.getString('uid');
                // firebase 유저네임 변경
                DatabaseSVC databaseService = DatabaseSVC();
                await databaseService.changeUsername(uid,newUserName);
                Navigator.of(context).pop(newUserName);
              },
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      prefs.setString('userName', newName);
      setState(() {
        _userName = newName;
      });
    }
  }

  Future<void> _changeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final newLanguage = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('언어 변경'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () async {
                  Navigator.of(context).pop('English');
                  final prefs = await SharedPreferences.getInstance();
                  String? uid = prefs.getString('uid');
                  DatabaseSVC databaseService = DatabaseSVC();
                  await databaseService.changeLanguage(uid,'English');
                  print(_language);
                  },

              ),
              ListTile(
                title: const Text('한국어'),
                onTap: () async { Navigator.of(context).pop('한국어');
                final prefs = await SharedPreferences.getInstance();
                String? uid = prefs.getString('uid');
                DatabaseSVC databaseService = DatabaseSVC();
                await databaseService.changeLanguage(uid,'한국어');
                },
              ),
              // Add more languages here
            ],
          ),
        );
      },
    );

    if (newLanguage != null && newLanguage.isNotEmpty) {
      prefs.setString('Language', newLanguage);
      setState(() {
        _language = newLanguage;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$_userName's Travel Planner"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(


                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    onChangeUserName: _changeUserName,
                    onChangeLanguage: _changeLanguage,
                    currentLanguage: _language,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: tripCards.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: tripCards[index]),
              );
            },
          ),

        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _planNewTrip,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Plan a New Tour'),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final VoidCallback onChangeUserName;
  final VoidCallback onChangeLanguage;
  final String currentLanguage;

  const SettingsPage({super.key,
    required this.onChangeUserName,
    required this.onChangeLanguage,
    required this.currentLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('이름 변경'),
            onTap: onChangeUserName,
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('언어 변경'),
            subtitle: Text(currentLanguage),
            onTap: onChangeLanguage,
          ),
        ],
      ),
    );
  }
}
