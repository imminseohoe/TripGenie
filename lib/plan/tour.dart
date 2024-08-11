import 'package:flutter/material.dart';
import 'package:ai_tour/plan/pexels_api.dart';
import 'package:ai_tour/login/loginPage.dart';

class TourScreen extends StatelessWidget {
  final Map<String, dynamic> tourPlan;
  final String title;

  TourScreen({required this.tourPlan, required this.title});

  @override
  Widget build(BuildContext context) {
    List<Widget> itineraryWidgets = [];

    tourPlan.forEach((day, parts) {
      itineraryWidgets.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          day,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ));
      parts.forEach((part, details) {
        itineraryWidgets.add(FutureBuilder<String>(
          future: PixabayApi.fetchImageUrl(details['Location']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ItineraryCard(
                time: details['Time'],
                activity: details['Activity'],
                price: details['price'],
                location: details['Location'],
                stayingTime: details['StayingTime'],
                imageUrl: snapshot.data!,
              );
            }
          },
        ));
        if (details['MovingTime'] != "0 minutes") {
          itineraryWidgets.add(MovingTimeCard(movingTime: details['MovingTime']));
        }
      });
    });

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => UserMainPage()),
              (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: ListView(
          children: itineraryWidgets,
        ),
      ),
    );
  }
}

class ItineraryCard extends StatelessWidget {
  final String time;
  final String activity;
  final String price;
  final String location;
  final String stayingTime;
  final String imageUrl;

  ItineraryCard({
    required this.time,
    required this.activity,
    required this.price,
    required this.location,
    required this.stayingTime,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Time: $time'),
                  Text('Activity: $activity'),
                  Text('Price: $price'),
                  Text('Staying Time: $stayingTime'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovingTimeCard extends StatelessWidget {
  final String movingTime;

  MovingTimeCard({required this.movingTime});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        children: [
          Icon(Icons.directions_car, color: Colors.grey),
          SizedBox(width: 10),
          Text(
            'Moving Time: $movingTime',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
