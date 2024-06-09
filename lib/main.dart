import 'package:Saydaliati/Controller/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:Saydaliati/views/racine_page.dart';

//async indique que la fonction peut exécuter des opérations asynchrones.
void main() async {
  // initialisation Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  //await est utilisé pour attendre que l'opération asynchrone soit complétée avant de continuer.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //runApp C'est la fonction qui lance l'application
  runApp(
    MultiProvider(
      providers: [
        //crée une instance de AuthService qui peut être écoutée
        //et consommée par n'importe quel widget descendant dans l'arbre des widgets.
        Provider(create: (context) => AuthService()),
      ],
      //widget principale de notre application
      child: const MyApp(),
    ),
  );
}

// signifie que MyApp est statique ne change pas
class MyApp extends StatelessWidget {
  // maintenir l'état des widgets et d'optimiser les performances lors de modifications
  const MyApp({Key? key}) : super(key: key);

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {'/': (context) => Racine2()},
      //pour désactive le bandeau de débogage
      debugShowCheckedModeBanner: false,
    );
  }
}

class Racine2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Scaffold widget est prédéfini par Flutter.
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          height: size.height * 1,
          //le widget Stack permet de superposer plusieurs widgets les uns sur les autres.
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
                // GestureDetector utilisé pour ajouter des interactions de toucher à n'importe quel widget
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
