import 'package:flutter/material.dart';
class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Video"),),
      body: Container(
        child: Center(
          child: Text("Video"),
        ),
      ),
    );
  }
}
