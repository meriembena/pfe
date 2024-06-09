import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Saydaliati/Controller/auth_service.dart';

// cette classe est dynamique change d'etat
class ChangePasswordScreen extends StatefulWidget {
  @override
  //Flutter a besoin de construire le widget ChangePasswordScreenState, il appelle
//createState(). Cette méthode retourne une instance de _ProfilepageState,
//qui contient tout l'état nécessaire
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

// _ChangePasswordScreenState Contient et gère l'état dynamique du widget,
// construire l'interface utilisateur en réponse aux interactions de l'utilisateur.
class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _newPasswordController = TextEditingController();

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    // Scaffold widget est prédéfini par Flutter.
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_newPasswordController.text.isNotEmpty) {
                  try {
                    //Utilise le package provider pour obtenir une instance de AuthService
                    //et appelle la méthode changePassword avec le nouveau mot de passe.
                    //listen: false indique que ce contexte particulier ne doit
                    //pas écouter les changements de l'état de AuthService.
                    await Provider.of<AuthService>(context, listen: false)
                        .changePassword(_newPasswordController.text);
                    //Si le changement de mot de passe réussit, l'écran actuel est fermé
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Mot de passe changé avec succès !')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Échec du changement de mot de passe: $e')),
                    );
                  }
                }
              },
              child: Text('Changer le mot de passe'),
            ),
          ],
        ),
      ),
    );
  }
}
