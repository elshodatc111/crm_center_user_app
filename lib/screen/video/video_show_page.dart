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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '📚 Kurs Mavzulari',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 5,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text(
                "📛 Ma'lumot yuklashda xatolik!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          final cours = snapshot.data!['cours'];
          final videos = snapshot.data!['video'] as List<dynamic>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "📖 ${cours['cours_name']}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return _buildVideoCard(video, context);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayVideo(
              name: video['cours_name'],
              url: video['video_url'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(3, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Image.network(
                video['thumbnail'] ?? 'https://media.istockphoto.com/id/1248852677/photo/live-video-content-online-streaming-marketing-concept.jpg?s=612x612&w=0&k=20&c=DTPDlOlNWm53aw4uCnWSHwW7x7bg0N_9siW0_rBEcKk=',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Text(
                  video['cours_name'] ?? "Noma'lum mavzu",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
