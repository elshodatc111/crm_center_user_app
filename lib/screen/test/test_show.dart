import 'dart:convert';

import 'package:crm_center_student/screen/const/app_const.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class TestShow extends StatefulWidget {
  final int group_id;
  final String group_name;
  final List<Map<String, dynamic>> testlar;

  const TestShow({super.key, required this.group_id, required this.group_name, required this.testlar});

  @override
  State<TestShow> createState() => _TestShowState();
}

class _TestShowState extends State<TestShow> {
  int currentTestIndex = 0;
  Map<int, bool> answerResults = {};
  int? selectedAnswer;
  int correctAnswers = 0;

  void checkAnswer() {
    if (selectedAnswer == null) return;

    var test = widget.testlar[currentTestIndex];
    var answers = test["javob"] as List<dynamic>;

    bool isCorrect = answers[selectedAnswer!]["status"] == true;

    setState(() {
      answerResults[currentTestIndex] = isCorrect;
      if (isCorrect) correctAnswers++;
    });

    Future.delayed(Duration(seconds: 1), () {
      if (currentTestIndex < widget.testlar.length - 1) {
        setState(() {
          currentTestIndex++;
          selectedAnswer = null;
        });
      } else {
        _showResult();
      }
    });
  }

  void _sendPost(int group_id, int true_answer) async {
    final box = GetStorage();
    final String token = box.read('token');
    const String baseUrl = AppConstants.apiUrl + "/tests/check";

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({ // JSON formatida kodlash kerak!
        "group_id": group_id,
        "count_true": true_answer,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
    } else {
      print("Xatolik: ${response.statusCode}, ${response.body}");
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Natija", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        content: Text(
          "Siz ${widget.testlar.length} ta testdan $correctAnswers tasiga to‘g‘ri javob berdingiz!",
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print("Count: ${widget.testlar.length}");
              print("Count: ${correctAnswers}");
              _sendPost(widget.group_id, correctAnswers);
              Navigator.pop(context, true);
              Navigator.pop(context, true);
            },
            child: Text("OK", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentTestIndex >= widget.testlar.length) return SizedBox();
    var test = widget.testlar[currentTestIndex];
    var answers = test["javob"] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Guruh: ${widget.group_name}",
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 5,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentTestIndex + 1) / widget.testlar.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity, // Savol butun kenglikni egallaydi
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blueAccent.shade100,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                "Savol ${currentTestIndex + 1}/${widget.testlar.length}:\n${test["test"]}",
                textAlign: TextAlign.center, // Matn markazga joylashtiriladi
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView(
                children: List.generate(answers.length, (answerIndex) {
                  var answer = answers[answerIndex];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAnswer = answerIndex;
                      });
                      checkAnswer();
                    },
                    child: Container(
                      width: double.infinity, // Javoblar ham butun kenglikni egallaydi
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: selectedAnswer == answerIndex ? Colors.blueAccent : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        answer["test"],
                        textAlign: TextAlign.center, // Matn markazga joylashtiriladi
                        style: TextStyle(
                          fontSize: 18,
                          color: selectedAnswer == answerIndex ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (answerResults.containsKey(currentTestIndex))
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: answerResults[currentTestIndex]! ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    answerResults[currentTestIndex]! ? "✅ To'g'ri javob!" : "❌ Noto'g'ri javob!",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
