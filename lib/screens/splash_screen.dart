import 'package:drimaes_coding_challenge/screens/user_list_screen/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String versionNumber = '';
  String versionCode = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    Map<String, dynamic> result = await getVersionInfo();
    versionNumber = result['versionName'].toString();
    versionCode = result['versionCode'].toString();
    setState(() {
      if(versionNumber.isNotEmpty && versionCode.isNotEmpty){
        Future.delayed(
          const Duration(seconds: 3),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserListScreen(),)
          ),
        );
      }
    });
  }

  Future<Map<String, dynamic>> getVersionInfo() async {
    const MethodChannel channel = MethodChannel('demo');
    try {
      final result = await channel.invokeMethod('getVersionInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print('Error retrieving version info: ${e.message}');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Splash Screen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
            Text('Version Number: $versionNumber', style: const TextStyle(fontSize: 14),),
            Text('Version Code: $versionCode', style: const TextStyle(fontSize: 14),),
          ],
        ),
      ),
    );
  }
}

