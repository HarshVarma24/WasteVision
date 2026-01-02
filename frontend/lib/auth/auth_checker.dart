import 'package:flutter/material.dart';
import '../screens/login_screen.dart'; 
import '../services/api_services.dart'; 

class CheckAuth extends StatefulWidget{
  const CheckAuth({Key? key}) : super(key: key);

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}
class _CheckAuthState extends State<CheckAuth>{
  
  @override
  void initState(){
    super.initState();
    checkLoginStatus();
  }
  Future<void> checkLoginStatus() async {
    try{
      await ApiServices.verifylogin();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
   @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}