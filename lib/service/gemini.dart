import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Gemini {
  // Access your API key as an environment variable


  // Initialize the GenerativeModel
  final GenerativeModel model;

  Gemini() : model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'API_KEY');

  Future<Map<String, dynamic>> generateTourPlan({
    required String people,
    required String start,
    required String end,
    required String level,
    required String style,
    required String note,
    required String destination,
    required lang,
  }) async {
    // Construct the prompt
    String prompt = """
    You are a professional tour planner. You need to complete customer requirements based on their input.
    The customer uses the following language: $lang. Please respond in $lang.
    Customers want to visit $destination with $people people.
    Customers will stay from $start to $end.
    Customers want a $level budget level.
    Customers want to travel in an $style style.
    Customers want to experience the following: $note.
    Make a plan specifying the time, duration of stays, and travel time between locations by car.
    Provide activity descriptions in a lively, friendly, and detailed manner.
    the curtomer currecy is \$
    Use triple quotes (''') for multi-line strings.
    Provide your response as a JSON object with the following schema: 
    {
      "Day1": {
        "Part1": {"Time": "10Am", "Activity": "...", "price": "", "Location": "...", "StayingTime": "20min", "MovingTime": "30min"},
        "Part2": {"Time": "10:50Am", "Activity": "...", "price": "...", "Location": "...", "StayingTime": "...", "MovingTime": "..."},
        ...
        "LastPart": {"Time": "...", "Activity": "...", "price": "...", "Location": "...", "StayingTime": "...", "MovingTime": "..."}
      },
      "Day2": {
        "Part1": {"Time": "...", "Activity": "...", "price": "...", "Location": "...", "StayingTime": "...", "MovingTime": "..."},
        ...
      }
    }
    """;

    // Get the response from the model
    var response = await model.generateContent([Content.text(prompt)]);


    String cleanedText = response.text?.replaceFirst('json', '').trim() ?? '{}';
    String www = cleanedText.replaceAll('```', '').trim();
    // Ensure the response.text is not null before decoding
    print(response);
    var jsonResponse = jsonDecode(www);

    return jsonResponse;
  }
}
