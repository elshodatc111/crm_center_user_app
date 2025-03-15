import 'package:crm_center_student/screen/login/login_page.dart';
import 'package:crm_center_student/screen/main_page.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      String? token = box.read('token'); // Tokenni tekshiramiz
      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Scaffold(
        //backgroundColor: Color(0xffF91101),
        body: Container(
          color: Color(0xffF91101),
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
      ),
    );
  }
}
