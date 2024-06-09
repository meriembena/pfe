import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Saydaliati/views/chatbot.dart';

// cette classe est dynamique change d'etat
class ListeScreen extends StatefulWidget {
  final String? selectedGouvernorat;
  final String? selectedDelegation;
  final bool isNight;
// maintenir l'état des widgets et d'optimiser les performances lors de modifications
  const ListeScreen({
    Key? key,
    this.selectedGouvernorat,
    this.selectedDelegation,
    this.isNight = false,
  }) : super(key: key);
  //construire le widget ListeScreenState, il appelle
//createState(). Cette méthode retourne une instance de _ListeScreenState,
//qui contient tout l'état nécessaire
  @override
  State<ListeScreen> createState() => _ListeScreenState();
}

class _ListeScreenState extends State<ListeScreen> {
  //initialise une liste vide "pharmacies"
  late List<Map<String, dynamic>> pharmacies = [];

  @override
  //C'est l'endroit où vous pouvez insérer le code d'initialisation qui doit s'exécuter une seule fois
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    if (widget.selectedGouvernorat != null &&
        widget.selectedDelegation != null) {
      String period = widget.isNight ? 'nuit' : 'jour';
      String path = 'Liste_pharmacie/$period';

      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.doc(path).get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        //Récupère les données spécifiques au gouvernorat sélectionné.
        var gouvernoratData =
            data?[widget.selectedGouvernorat] as Map<String, dynamic>?;
        //Récupère les données spécifiques à la délégation sélectionnée à partir des données du gouvernorat.
        var delegationData = gouvernoratData?[widget.selectedDelegation]
            as Map<String, dynamic>?;
        if (delegationData != null) {
          //parcourir chaque entrer de délégationData
          delegationData.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              // Ajoute les informations de chaque pharmacie dans la liste pharmacies.
              pharmacies.add({
                'nomF': value['nomF'] ?? 'Nom inconnu',
                'adresse': value['adresse'] ?? 'Adresse inconnue',
                'tel': value['tel'] ?? 'Numéro non disponible'
              });
            }
          });
//mettre à jour l'état de l'interface utilisateur
          setState(() {
            pharmacies = pharmacies;
          });
        }
      }
    }
  }

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Scaffold widget est prédéfini par Flutter.
    return Scaffold(
      //le widget Stack permet de superposer plusieurs widgets les uns sur les autres.
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/back.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: screenWidth * 0,
            top: screenHeight * -0.04,
            child: Container(
              width: screenWidth * 1,
              height: screenHeight * 0.17,
              margin: EdgeInsets.symmetric(vertical: 20.0),
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/images/Groupe 27.png',
                      width: screenWidth * 0.14,
                      height: screenHeight * 0.15,
                    ),
                  ),
                  Text(
                    'Liste des pharmacies',
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 94), // For balance in layout
                ],
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: screenHeight * 0.07),
              Expanded(
                child: ListView.builder(
                  itemCount: pharmacies.length,
                  itemBuilder: (context, index) {
                    var pharmacy = pharmacies[index];
                    return Card(
                      color: Colors.white10.withOpacity(0.8),
                      child: ListTile(
                        title: Text(
                          pharmacy['nomF'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(
                              "Adresse: ${pharmacy['adresse']}",
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      width: screenWidth * 0.30,
                                      height: screenHeight * 0.04,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _launchPhoneCall(pharmacy['tel']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          padding: EdgeInsets.all(5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                        ),
                                        child: Text(
                                          pharmacy['tel'],
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      width: screenWidth * 0.30,
                                      height: screenHeight * 0.04,
                                      child: ElevatedButton(
                                        onPressed: () => _openChatbot(
                                            context, pharmacy['nomF']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          padding: EdgeInsets.all(5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(35),
                                          ),
                                        ),
                                        child: Text(
                                          "Chatbot",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openChatbot(BuildContext context, String nomPharmacie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatbotScreen(nomPharmacie),
      ),
    );
  }

  void _launchPhoneCall(String phoneNumber) async {
    if (phoneNumber.isNotEmpty) {
      //Crée une nouvelle chaîne de caractères telScheme pour un appel téléphonique
      String telScheme = 'tel:$phoneNumber';
      //vérifier le dispositif est capable de passer un appel téléphonique avec ce schéma URI
      if (await canLaunch(telScheme)) {
        //passer l'appel
        await launch(telScheme);
      } else {
        throw 'Impossible de lancer l\'appel pour le numéro $phoneNumber';
      }
    }
  }
}
