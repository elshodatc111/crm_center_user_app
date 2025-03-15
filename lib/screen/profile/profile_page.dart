import 'dart:convert';

import 'package:crm_center_student/screen/const/app_const.dart';
import 'package:crm_center_student/screen/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String apiUrl = AppConstants.apiUrl + '/profile';

  Future<Map<String, dynamic>> fetchProfile() async {
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
      return json.decode(response.body);
    } else {
      throw Exception('Profil ma\'lumotlarini olishda xatolik!');
    }
  }

  void _logout(BuildContext context) {
    final box = GetStorage();
    box.remove('token'); // Tokenni o‘chirish
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SplashPage()),
          (route) => false, // Barcha sahifalarni yopish
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profil",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Xatolik: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("Ma'lumotlar topilmadi"));
          }
          final profile = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person,color: Colors.white,size: 36.0,),
                ),
                SizedBox(height: 10),
                Text(profile['user_name'],style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _profileInfo("📧 Login: ", profile['email']),
                        _profileInfo("📞 Telefon raqam: ", profile['phone1']),
                        _profileInfo("📍 Manzil:", profile['address']),
                        _profileInfo("🎂 Tug'ilgan kun:", profile['birthday']),
                        _profileInfo("🎂 Balans:", profile["balans"].toString()+" so'm"),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("Chiqish", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),

                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Expanded(child: Text(value, style: TextStyle(fontSize: 18))),
        ],
      ),
    );
  }
}
