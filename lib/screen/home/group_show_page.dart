import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:crm_center_student/screen/const/app_const.dart';

class GroupShowPage extends StatefulWidget {
  final int id;

  const GroupShowPage({super.key, required this.id});

  @override
  State<GroupShowPage> createState() => _GroupShowPageState();
}

class _GroupShowPageState extends State<GroupShowPage> {
  late String apiUrl;
  bool isLoading = false;
  List<dynamic> groupDay = [];
  String groupName = "";
  String price = '';
  int lessenCount = 0;
  String lessenStart = '';
  String lessenEnd = '';
  String teacher = '';
  String roomName = '';
  String time = '';

  @override
  void initState() {
    super.initState();
    apiUrl = '${AppConstants.apiUrl}/group/${widget.id}';
    fetchGroupData();
  }

  Future<void> fetchGroupData() async {
    setState(() => isLoading = true);
    try {
      final box = GetStorage();
      String? token = box.read('token');

      if (token == null || token.isEmpty) {
        _showError("Token topilmadi");
        setState(() => isLoading = false);
        return;
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
        setState(() {
          groupDay = data['days'] ?? [];
          groupName = data['groups']['group_name'];
          price = data['groups']['price'];
          lessenCount = data['groups']['lessen_count'];
          lessenStart = data['groups']['lessen_start'];
          lessenEnd = data['groups']['lessen_end'];
          teacher = data['groups']['techer'];
          roomName = data['groups']['room_name'];
          time = data['groups']['time'];
        });
      } else {
        _showError("API xatosi: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      _showError("Tarmoq xatosi: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : groupDay.isEmpty
          ? Center(
        child: Text(
          "Guruh haqida ma'lumot topilmadi",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard("Guruh narxi", "$price so'm", Icons.attach_money),
            _buildInfoCard("Darslar soni", "$lessenCount", Icons.menu_book),
            _buildInfoCard("O'qituvchi", teacher, Icons.person),
            _buildInfoCard("Dars xonasi", roomName, Icons.room),
            _buildInfoCard("Dars vaqti", time, Icons.access_time),
            SizedBox(height: 20),
            Text(
              "📅 Guruh dars kunlari",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: groupDay.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text("Dars kuni: ${groupDay[index]['date']}"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
