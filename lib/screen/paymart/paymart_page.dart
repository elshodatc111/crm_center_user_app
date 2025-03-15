import 'dart:convert';

import 'package:crm_center_student/screen/const/app_const.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
class PaymartPage extends StatefulWidget {
  const PaymartPage({super.key});

  @override
  State<PaymartPage> createState() => _PaymartPageState();
}

class _PaymartPageState extends State<PaymartPage> {
  final String apiUrl = '${AppConstants.apiUrl}/paymart';

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
        return data['paymart'];
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
          "To'lovlar",
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
            return Center(child: Text("To‘lovlar topilmadi"));
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
}

Widget _buildPaymentCard(Map<String, dynamic> payment) {
  return Card(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("To'lov",
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                "${payment['amount']} so‘m",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("To‘lov vaqti: ${payment['created_at'].split('T')[0]}",
                  style: TextStyle(fontSize: 16)),
              Text("To‘lov turi: ${payment['paymart_type']}",
                  style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    ),
  );
}

