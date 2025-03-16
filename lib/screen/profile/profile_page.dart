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
  final String apiUrl = '${AppConstants.apiUrl}/profile';

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
      throw Exception("Profil ma'lumotlarini olishda xatolik!");
    }
  }

  void _logout(BuildContext context) {
    final box = GetStorage();
    box.remove('token');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SplashPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profil",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Xatolik: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Ma'lumotlar topilmadi"));
          }
          final profile = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(profile['user_name']),
                _buildProfileInfo(profile),
                const SizedBox(height: 20),
                _buildLogoutButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String userName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.blue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.blueAccent, size: 40),
          ),
          const SizedBox(height: 10),
          Text(
            userName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(Map<String, dynamic> profile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _profileInfo(Icons.email, "Login", profile['email']),
              _divider(),
              _profileInfo(Icons.phone, "Telefon raqam", profile['phone1']),
              _divider(),
              _profileInfo(Icons.location_on, "Manzil", profile['address']),
              _divider(),
              _profileInfo(Icons.cake, "Tug‘ilgan kun", profile['birthday']),
              _divider(),
              _profileInfo(Icons.account_balance_wallet, "Balans", "${profile["balans"]} so'm"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileInfo(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 28),
        const SizedBox(width: 12),
        Text(
          "$title: ",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Divider(color: Colors.grey, thickness: 0.5, height: 20);
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton(
        onPressed: () => _logout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.exit_to_app, color: Colors.white),
            SizedBox(width: 10),
            Text("Chiqish", style: TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
