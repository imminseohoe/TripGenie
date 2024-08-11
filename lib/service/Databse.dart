import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

/*
ai_tour
-uid
--username
--lang
--trips
---1
------ name,startday,invite, detail:{..}
---2
------ name,startday,invite, detail:{..}
 */
class DatabaseSVC {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Future<void> saveUserToDatabase(uid) async {
    await _database.child('$uid').set({
      'name':'string'
    });
  }
  Future<void> changeUsername(uid,name) async {
    await _database.child('$uid').update({
      'name':'$name'
    });
  }
  Future<void> changeLanguage(uid,lang) async {
    await _database.child('$uid').update({
      'lang':'$lang'
    });
  }
  Future<DatabaseEvent> getTrips(String uid) async {
    DatabaseReference tripsRef = _database.child(uid).child('trips');
    return await tripsRef.once();
  }

  Future<Map<String, dynamic>> getTripsDetails(String uid, String keys) async {
    DatabaseReference tripsRef = _database.child(uid).child('trips').child(keys).child('tourPlan');
    DataSnapshot snapshot = (await tripsRef.once()).snapshot;

    if (snapshot.value != null) {
      if (snapshot.value is String) {
        return jsonDecode(snapshot.value as String) as Map<String, dynamic>;
      } else if (snapshot.value is Map) {
        return snapshot.value as Map<String, dynamic>;
      } else {
        throw Exception("Invalid data format");
      }
    } else {
      throw Exception("No data found");
    }
  }
  Future<void> AddDB(uid,name,startday,endday,imageurl,details) async {
    DatabaseReference tripsRef = _database.child(uid).child('trips');

    // Get the current trips

    await tripsRef.push().set({
      "title": "$name",
      "startday": '$startday',
      'endday' : '$endday',
      "tourPlan": details,
      "imageurl": '$imageurl'
    });
  }

  Future<void> FirstName(uid,name,lang) async {


    await _database.child('$uid').set({
      "name": "$name",
      "lang": '$lang'

    });
  }
  void ReadDB(){
    DatabaseReference starCountRef =
    FirebaseDatabase.instance.ref('posts');
    starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      print(data);
    });
  }


}


