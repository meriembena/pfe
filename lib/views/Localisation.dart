import 'package:Saydaliati/views/discussions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Saydaliati/views/Profile.dart';
import 'package:Saydaliati/views/list.dart';

// cette classe est dynamique change d'etat
class localisation extends StatefulWidget {
//déclarent trois booléennes (final, signifiant qu'elles ne peuvent pas être modifiées une fois que le widget est créé)
  final bool isPharmacieDeGardeSelected;
  final bool isPharmacieDeNuitSelected;
  final bool isPharmacieDeJourSelected;

  localisation({
    required this.isPharmacieDeGardeSelected,
    required this.isPharmacieDeNuitSelected,
    required this.isPharmacieDeJourSelected,
  });

  @override
  //Flutter a besoin de construire le widget localisation, il appelle
//createState(). Cette méthode retourne une instance de _localisation,
//qui contient tout l'état nécessaire
  _localisationState createState() => _localisationState();
}

//Contient et gère l'état dynamique du widget,construire l'interface utilisateur en réponse aux interactions de l'utilisateur.
class _localisationState extends State<localisation> {
//variables d'instance qui stockent les valeurs sélectionnées pour le gouvernorat et la délégation
  String? selectedGouvernorat;
  String? selectedDelegation;
//Cette liste est utilisée pour stocker les gouvernorats disponible
  List<String> gouvernorats = [];
//un dictionnaire où chaque clé est un gouvernorat et chaque valeur est une liste de délégations
  Map<String, List<String>> delegations = {};

  @override
////C'est l'endroit où vous pouvez insérer le code d'initialisation qui doit s'exécuter une seule fois
  void initState() {
    super.initState();
    chargerDonnees();
  }

  Future<void> chargerDonnees() async {
    //accède à la collection nommée villes dans Firestore
    var collection = FirebaseFirestore.instance.collection('villes');
    // récupérer tous les documents de cette collection
    var snapshot = await collection.get();
//setState: fonction pour notifier Flutter que l'état du widget doit être mis à jour
    setState(() {
//convertit chaque document dans la collection en son identifiant
// et crée une liste de ces identifiants
      gouvernorats = snapshot.docs.map((doc) => doc.id).toList();
//parcourt chaque document pour extraire les délégations associées à chaque gouvernorat
      for (var doc in snapshot.docs) {
        //crée une liste de chaînes à partir de l'entrée délégation dans le document
        delegations[doc.id] = List<String>.from(doc['délégation']);
      }
// initialise selectedGouvernorat avec le premier gouvernorat de la liste
      selectedGouvernorat = gouvernorats.isNotEmpty ? gouvernorats.first : null;
//réinitialise selectedDelegation à null chaque fois que les données sont chargées,
//ce qui implique que l'utilisateur doit refaire une sélection de délégation après
//le rechargement des données
      selectedDelegation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
// Scaffold widget est prédéfini par Flutter.
    return Scaffold(
      //garantir que le contenu de l'application est toujours visible et accessible.
      body: SafeArea(
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
              left: screenWidth * 0,
              top: screenHeight * -0.04,
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.1,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                padding: EdgeInsets.all(16.0),
                child: Row(
//aligner widgets de manière à ce que l'espace horizontal entre eux soit égalisé
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()),
                        );
                      },
                      child: Image.asset(
                        'assets/images/profil.png',
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => discussions()),
                        );
                      },
                      child: Image.asset(
                        'assets/images/icons8-sms-50.png',
                        width: screenWidth * 0.2,
                        height: screenHeight * 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.06,
              top: screenHeight * 0.12,
              child: Container(
                width: screenWidth * 0.88,
                height: screenHeight * 0.60,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    DropdownButton<String>(
                      // le DropdownButton occupe toute la largeur possible
                      isExpanded: true,
                      //une variable d'état qui stocke la valeur du gouvernorat actuellement sélectionné
                      value: selectedGouvernorat,
//fonction est appelée chaque fois que l'utilisateur sélectionne une nouvelle valeur dans le menu déroulant
                      onChanged: (newValue) {
                        //mettre à jour l'état de l'application
                        setState(() {
                          selectedGouvernorat = newValue;
                          selectedDelegation = null;
                        });
                      },
//Convertit chaque valeur dans la liste gouvernorats en un DropdownMenuItem
                      items: gouvernorats
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
//Chaque DropdownMenuItem est configuré avec une value qui est le nom du gouvernorat
                          value: value,
//un child qui est un widget Text affichant le nom du gouvernorat
                          child: Text(value, style: TextStyle(fontSize: 18.0)),
                        );
                      }).toList(), // convertit l'itérable résultant en une liste
                    ),
                    SizedBox(height: 20),
                    if (selectedGouvernorat != null)
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedDelegation,
                        onChanged: (newValue) {
                          setState(() {
                            selectedDelegation = newValue;
                          });
                        },
                        items: delegations[selectedGouvernorat]!
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child:
                                Text(value, style: TextStyle(fontSize: 18.0)),
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 45),
                    Center(
                      child: ElevatedButton(
                        onPressed: _openGoogleMaps,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                        child: Text('Ouvrir la localisation',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16.0)),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListeScreen(
                                selectedGouvernorat: selectedGouvernorat,
                                selectedDelegation: selectedDelegation,
                                isNight: widget.isPharmacieDeNuitSelected,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.only(
                              left: 20, right: 20, top: 10, bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                        child: Text('Accéder à la liste',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _openGoogleMaps() async {
    String type = widget.isPharmacieDeGardeSelected
        ? 'pharmacie de garde'
        : 'pharmacie de nuit';
    String query = '$type +${selectedGouvernorat}+${selectedDelegation}';
    query = query.replaceAll(' ', '+');
    //l'URL finale qui sera utilisée pour lancer Google Maps
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    //la méthode vérifie si l'URL peut être ouverte à l'aide de canLaunch(url)
    if (await canLaunch(url)) {
      //Si l'URL peut être lancée, elle est ouverte à l'aide de launch(url)
      await launch(url);
    } else {
      throw 'Impossible de lancer $url';
    }
  }
}
