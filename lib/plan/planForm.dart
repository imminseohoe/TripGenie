import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ai_tour/service/gemini.dart';
import 'package:ai_tour/plan/tour.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'package:ai_tour/plan/pexels_api.dart';

import '../service/Databse.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TravelDetails(),
    );
  }
}

class TravelDetails extends StatefulWidget {
  const TravelDetails({super.key});

  @override
  _TravelDetailsState createState() => _TravelDetailsState();
}

class _TravelDetailsState extends State<TravelDetails> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _destination = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 1));

  void _submitDetails() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TravelSurvey(
            title: _title,
            destination: _destination,
            startDate: _startDate,
            endDate: _endDate,
          ),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate, ValueChanged<DateTime> onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 세부 사항 입력'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Travel title
                const Text('여행 제목:', style: TextStyle(fontSize: 20)),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: '예시: 여름 휴가',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '여행 제목을 입력해주세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value!;
                  },
                ),

                // Destination
                const Text('목적지:', style: TextStyle(fontSize: 20)),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: '예시: 제주도',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '목적지를 입력해주세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _destination = value!;
                  },
                ),

                // Start date
                const Text('출발 날짜:', style: TextStyle(fontSize: 20)),
                TextButton(
                  onPressed: () => _selectDate(context, _startDate, (date) => setState(() => _startDate = date)),
                  child: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                ),

                // End date
                const Text('도착 날짜:', style: TextStyle(fontSize: 20)),
                TextButton(
                  onPressed: () => _selectDate(context, _endDate, (date) => setState(() => _endDate = date)),
                  child: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                ),

                // Submit button
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitDetails,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // Full width button
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TravelSurvey extends StatefulWidget {
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;

  const TravelSurvey({
    super.key,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
  });

  @override
  _TravelSurveyState createState() => _TravelSurveyState();
}

class _TravelSurveyState extends State<TravelSurvey> {
  final List<String> _selectedStyles = [];
  final List<String> _styles = ['활발', '조용', '유명한', '스포츠', '레저', '힐링'];
  double _currentSliderValue = 1.0;
  String _otherStyle = '';
  String _people = '';
  String _note = '';

  final _formKey = GlobalKey<FormState>();

  void _submitSurvey() {
    if (_formKey.currentState!.validate()) {
      if (_selectedStyles.isEmpty) {
        _selectedStyles.add('아무거나');
      }
      _formKey.currentState!.save();
      // Handle survey submission
      print('선택한 여행 스타일: ${_selectedStyles.join(', ')}, 기타: $_otherStyle');
      print('같이 가는 인원: $_people');
      print('기타 내용: $_note ');

      // (Optional) Implement logic to send survey data to server or store locally
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Travel destination and dates
                Text('목적지: ${widget.destination}', style: const TextStyle(fontSize: 20)),
                Text('출발 날짜: ${DateFormat('yyyy-MM-dd').format(widget.startDate)}', style: const TextStyle(fontSize: 20)),
                Text('도착 날짜: ${DateFormat('yyyy-MM-dd').format(widget.endDate)}', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 20),

                // Travel style selection (CheckboxListTile)
                const Text('여행 스타일:', style: TextStyle(fontSize: 20)),
                Column(
                  children: _styles.map((style) => CheckboxListTile(
                    title: Text(style),
                    value: _selectedStyles.contains(style),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          _selectedStyles.add(style);
                        } else {
                          _selectedStyles.remove(style);
                        }
                      });
                    },
                  )).toList(),
                ),

                // '기타' travel style input
                const Text('기타 여행 스타일 (선택사항):', style: TextStyle(fontSize: 20)),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: '예시: 해변 휴가, 쇼핑 여행',
                  ),
                  onSaved: (value) {
                    _otherStyle = value!;
                  },
                ),
                const SizedBox(height: 20),

                // Slider UI for travel budget level
                const Text('여행 경비 수준:', style: TextStyle(fontSize: 20)),
                Slider(
                  value: _currentSliderValue,
                  min: 0,
                  max: 2,
                  divisions: 2,
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;

                    });
                  },
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cheap',style: TextStyle(fontSize: 20)),
                    Text('Mid',style: TextStyle(fontSize: 20)),
                    Text('High',style: TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '선택한 경비 수준: ${_currentSliderValue == 0 ? 'Cheap' : _currentSliderValue == 1 ? 'Mid' : 'High'}',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),


                // Number of people
                const Text('같이 가는 인원:', style: TextStyle(fontSize: 20)),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '예시: 2명',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '같이 가는 인원을 입력해주세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _people = value!;
                  },
                ),

                // Additional notes
                const Text('기타 내용:', style: TextStyle(fontSize: 20)),
                TextFormField(
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: '여행 관련 추가 정보 작성',
                  ),
                  onSaved: (value) {
                    _note = value!;
                  },
                ),

                // Submit button
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:() async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(
                          people: (_people),
                          start: widget.startDate,
                          end: widget.endDate,
                          level: _currentSliderValue == 0 ? 'Cheap' : _currentSliderValue == 1 ? 'Mid' : 'High',
                          styles: _selectedStyles,
                          note: _note,
                          title : widget.title,
                          destination : widget.destination,

                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // Full width button
                  ),
                  child: const Text('Plan a New Tour'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class GameScreen extends StatefulWidget {
  final String people;
  final DateTime start;
  final DateTime end;
  final String level;
  final List<String> styles;
  final String note;
  final String destination;
  final String title;

  const GameScreen({super.key, required this.people, required this.start, required this.end, required this.level, required this.styles, required this.note,required this.destination, required this.title});
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double ballX = 0;
  double ballY = 0;
  double ballSpeedX = 2;
  double ballSpeedY = -2;
  double paddleX = 0;
  double paddleWidth = 0.2;
  double paddleHeight = 0.03;
  double collisionMargin = 0.05;
  int score = 0;
  bool gameOver = false;
  bool _tourPlanReady = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: 1),
    )..addListener(_update);
    _startNewGame();
    _generateTourPlan( people: widget.people, start: widget.start, end: widget.end, level: widget.level , styles: widget.styles, note: widget.note, title:widget.title, destination: widget.destination);
  }

  void _startNewGame() {
    setState(() {
      ballX = 0;
      ballY = 0.5;
      ballSpeedX = 2 * (Random().nextBool() ? 1 : -1);
      ballSpeedY = -2;
      paddleX = 0;
      score = 0;
      gameOver = false;
    });
    _controller.repeat();
  }

  void _update() {
    if (gameOver) return;

    double newBallX = ballX + ballSpeedX * 0.01;
    double newBallY = ballY + ballSpeedY * 0.01;

    if (_checkCollision(ballX, ballY, newBallX, newBallY)) {
      double t = _calculateCollisionTime(ballX, ballY, newBallX, newBallY);

      ballX = ballX + ballSpeedX * 0.01 * t;
      ballY = ballY + ballSpeedY * 0.01 * t;

      ballSpeedY = -ballSpeedY;
      double hitPosition = (ballX - paddleX) / (paddleWidth / 2);
      ballSpeedX = 2 * hitPosition;
      score++;
      _increaseSpeed();

      ballX += ballSpeedX * 0.01 * (1 - t);
      ballY += ballSpeedY * 0.01 * (1 - t);
    } else {
      ballX = newBallX;
      ballY = newBallY;
    }

    if (ballX <= -1 || ballX >= 1) {
      ballSpeedX = -ballSpeedX;
    }

    if (ballY <= -1) {
      ballSpeedY = -ballSpeedY;
    }

    if (ballY > 1) {
      gameOver = true;
      _controller.stop();
    }

    setState(() {});
  }

  bool _checkCollision(double oldX, double oldY, double newX, double newY) {
    double paddleTop = 0.9 - paddleHeight - collisionMargin;
    double paddleBottom = 0.9 + collisionMargin;
    double paddleLeft = paddleX - paddleWidth / 2;
    double paddleRight = paddleX + paddleWidth / 2;

    return _lineRectIntersection(oldX, oldY, newX, newY, paddleLeft, paddleTop, paddleRight, paddleBottom);
  }

  bool _lineRectIntersection(double x1, double y1, double x2, double y2, double left, double top, double right, double bottom) {
    double dx = x2 - x1;
    double dy = y2 - y1;

    double t0 = 0;
    double t1 = 1;

    if (dx != 0) {
      double tx1 = (left - x1) / dx;
      double tx2 = (right - x1) / dx;
      t0 = max(t0, min(tx1, tx2));
      t1 = min(t1, max(tx1, tx2));
    } else if (x1 < left || x1 > right) {
      return false;
    }

    if (dy != 0) {
      double ty1 = (top - y1) / dy;
      double ty2 = (bottom - y1) / dy;
      t0 = max(t0, min(ty1, ty2));
      t1 = min(t1, max(ty1, ty2));
    } else if (y1 < top || y1 > bottom) {
      return false;
    }

    return t0 <= t1 && t1 >= 0;
  }

  double _calculateCollisionTime(double oldX, double oldY, double newX, double newY) {
    double paddleTop = 0.9 - paddleHeight - collisionMargin;
    return (paddleTop - oldY) / (newY - oldY);
  }

  void _increaseSpeed() {
    ballSpeedX *= 1.02;
    ballSpeedY *= 1.02;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      paddleX += details.delta.dx / (MediaQuery.of(context).size.width / 2);
      paddleX = paddleX.clamp(-1 + paddleWidth / 2, 1 - paddleWidth / 2);
    });
  }
  Future<void> _generateTourPlan({
    required String people,
    required DateTime start,
    required DateTime end,
    required String level,
    required List<String> styles,
    required String note,
    required String title,
    required String destination,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    String? lang = prefs.getString('Language');
    Gemini gemini = Gemini();


    var tourPlan = await gemini.generateTourPlan(
      people: people,
      start: DateFormat('yyyy-MM-dd').format(start),
      end: DateFormat('yyyy-MM-dd').format(end),
      level: level,
      style: styles.join(', '),
      note: note,
      destination: destination,
      lang: lang
    );

    setState(() {
      _tourPlanReady = true;
    });

    String imageurl = await PixabayApi.fetchImageUrl(destination);
    //나중에 수정
    DatabaseSVC databaseService = DatabaseSVC();
    await databaseService.AddDB(uid,title,DateFormat('yyyy-MM-dd').format(start),DateFormat('yyyy-MM-dd').format(end),imageurl,tourPlan);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TourScreen(tourPlan: tourPlan, title: title),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: _onPanUpdate,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: Text(
                  'Score: $score',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              Positioned(
                left: (ballX + 1) / 2 * MediaQuery.of(context).size.width,
                top: (ballY + 1) / 2 * MediaQuery.of(context).size.height,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: (paddleX - paddleWidth / 2 + 1) / 2 * MediaQuery.of(context).size.width,
                bottom: 20,
                child: Container(
                  width: paddleWidth * MediaQuery.of(context).size.width,
                  height: paddleHeight * MediaQuery.of(context).size.height,
                  color: Colors.blue,
                ),
              ),
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '   The AI is making a plan, \nplease wait a few seconds...',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    if (gameOver)
                      Column(
                        children: [
                          Text(
                            'Game Over',
                            style: TextStyle(color: Colors.white, fontSize: 36),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _startNewGame,
                            child: Text('Play Again'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}