import 'package:chat1/Controller/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:chat1/views/racine_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {'/': (context) => Racine2()},
      debugShowCheckedModeBanner: false,
    );
  }
}

class Racine2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: size.height * 1,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/back.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: size.width * 0.1,
                top: size.height * 0.1,
                child: Image.asset(
                  'assets/images/Groupe 77.png',
                  width: size.width * 0.8,
                  height: size.height * 0.3,
                ),
              ),
              Positioned(
                left: size.width * 0.05,
                top: size.height * 0.35,
                child: Image.asset(
                  'assets/images/Groupe.png',
                  width: size.width * 0.9,
                  height: size.height * 0.1,
                ),
              ),
              Positioned(
                left: size.width * 0.1,
                top: size.height * 0.50,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Racine()),
                    );
                  },
                  child: Image.asset(
                    'assets/images/Bienvenue.png',
                    width: size.width * 0.8,
                    height: size.height * 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
