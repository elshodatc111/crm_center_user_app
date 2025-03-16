import 'dart:convert';
import 'package:crm_center_student/screen/const/app_const.dart';
import 'package:crm_center_student/screen/test/test_show.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final String apiUrl = '${AppConstants.apiUrl}/tests';

  Future<List<Map<String, dynamic>>> fetchTests() async {
    try {
      final box = GetStorage();
      String? token = box.read('token');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['testlar']);
      } else {
        debugPrint("API xatosi: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Tarmoq xatosi: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Testlar',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchTests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "❌ Testlar mavjud emas.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          final testlar = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            itemCount: testlar.length,
            itemBuilder: (context, index) {
              final test = testlar[index];
              return _buildTestCard(test);
            },
          );
        },
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test) {
    List<Map<String, dynamic>> testList = List<Map<String, dynamic>>.from(test['testlar']);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestShow(
              group_id: test['group_id'],
              group_name: test['group_name'],
              testlar: testList,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Material(
            color: Colors.white,
            child: InkWell(
              splashColor: Colors.blue.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test['group_name'] ?? "Noma'lum guruh",
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Text('Testlar soni', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                        Text('Urinishlar', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                        Text('To\'g\'ri javoblar', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("${testList.length}"),
                        Text("${test['urinishlar'] ?? 0}"),
                        Text("${test['tugri_javob'] ?? 0}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
