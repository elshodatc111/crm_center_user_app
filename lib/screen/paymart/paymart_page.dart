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
      if (token == null) {
        debugPrint("Token topilmadi!");
        return [];
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['paymart'] ?? [];
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
          "To'lovlar",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchPayments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("Hech qanday to‘lov topilmadi"));
          }

          final payments = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "💰 ${payment['amount']} so‘m",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const Chip(
                  label: Text(
                    "To‘landi",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  backgroundColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "📅 Sana: ${payment['created_at'].split('T')[0]}",
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Text(
                  "🔹 ${payment['paymart_type']}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
