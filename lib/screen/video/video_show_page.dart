import 'dart:convert';
import 'package:crm_center_student/screen/video/play_video.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:crm_center_student/screen/const/app_const.dart';

class VideoShowPage extends StatelessWidget {
  final int id;
  final String apiUrl;

  VideoShowPage({super.key, required this.id})
      : apiUrl = '${AppConstants.apiUrl}/video/show/$id';

  Future<Map<String, dynamic>?> fetchVideos() async {
    try {
      final box = GetStorage();
      String? token = box.read('token');

      if (token == null || token.isEmpty) {
        debugPrint("Token topilmadi!");
        return null;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;

        if (data.containsKey('cours') && data.containsKey('video')) {
          return data;
        } else {
          debugPrint("Noto‘g‘ri API formati: ${response.body}");
          return null;
        }
      } else {
        debugPrint("API xatosi: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Tarmoq xatosi: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Video darslar',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Ma'lumot yuklashda xatolik!"));
          } else {
            final cours = snapshot.data!['cours'];
            final videos = snapshot.data!['video'] as List<dynamic>;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Kurs nomi: ${cours['cours_name']}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      return Card(
                        color: Colors.white70,
                        child: ListTile(
                          title: Text(video['cours_name']),
                          subtitle: Text("ID: ${video['id']}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_arrow, color: Colors.red),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayVideo(name: video['cours_name'],url: video['video_url'],),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
