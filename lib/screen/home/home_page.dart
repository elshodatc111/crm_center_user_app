import 'dart:convert';

import 'package:crm_center_student/screen/const/app_const.dart';
import 'package:crm_center_student/screen/home/group_show_page.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiUrl = '${AppConstants.apiUrl}/groups';

  Future<List<dynamic>> fetchPayments() async {
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
        return data['groups'];
      } else {
        print("API xatosi: \${response.statusCode} - \${response.body}");
        return [];
      }
    } catch (e) {
      print("Tarmoq xatosi: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Guruhlar",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchPayments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("FutureBuilder xatosi: \${snapshot.error}");
            return Center(child: Text("Xatolik: \${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Guruhlar topilmadi"));
          }

          final payments = snapshot.data!;
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return _buildPaymentCard(payment);
            },
          );
        },
      ),
    );
  }


  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupShowPage(id: payment['id']),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/new.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                "Guruh: " + payment['group_name'],
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Boshlanish vaqti", style: TextStyle(fontSize: 16)),
                  Text("Tugash vaqti", style: TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${payment['lessen_start'].split('T')[0]}",
                      style: TextStyle(fontSize: 16)),
                  Text("${payment['lessen_start'].split('T')[0]}",
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }}
