import 'package:Saydaliati/views/Profile.dart';
import 'package:flutter/material.dart';
import 'package:Saydaliati/views/Localisation.dart';
import 'package:Saydaliati/views/discussions.dart';

// cette classe est dynamique change d'etat
class categories extends StatefulWidget {
  @override
  _categoriesState createState() => _categoriesState();
}

// _categoriesState Contient et gère l'état dynamique du widget,
//y compris la logique pour construire l'interface utilisateur en réponse aux interactions de l'utilisateur.
class _categoriesState extends State<categories> {
  bool isPharmacieDeGardeSelected = false;
  bool isPharmacieDeNuitSelected = false;
  bool isPharmacieDeJourSelected = false;

  bool _isButtonVisible() {
    return isPharmacieDeGardeSelected ||
        isPharmacieDeNuitSelected ||
        isPharmacieDeJourSelected;
  }

  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Scaffold widget est prédéfini par Flutter.
    return Scaffold(
      //garantir que le contenu de l'application est toujours visible et accessible.
      body: SafeArea(
        //permet de faire défiler un seul widget enfant qui pourrait dépasser les dimensions de l'écran
        child: SingleChildScrollView(
          child: Column(
            //détermine comment les enfants d'un Row ou d'une Column sont alignés le long de l'axe principal
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth,
                height: screenHeight,
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
                        width: screenWidth * 1,
                        height: screenHeight * 0.1,
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(),
                                  ),
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
                                    builder: (context) => discussions(),
                                  ),
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
                        height: screenHeight * 0.7,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 60),
                            Center(
                              child: Image.asset(
                                'assets/images/Categories.png',
                                width: screenWidth * 0.4,
                                height: screenHeight * 0.06,
                              ),
                            ),
                            SizedBox(height: 40),
                            CheckboxListTile(
                              title: Text("Pharmacie de garde"),
                              value: isPharmacieDeGardeSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  isPharmacieDeGardeSelected = value ?? false;
                                  if (value == true) {
                                    isPharmacieDeJourSelected = false;
                                    isPharmacieDeNuitSelected = false;
                                  }
                                });
                              },
                              activeColor: Colors.white,
                              checkColor:
                                  Colors.black, // Couleur de la coche (tick)
                            ),
                            CheckboxListTile(
                              title: Text("Pharmacie de jour"),
                              value: isPharmacieDeJourSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  isPharmacieDeJourSelected = value ?? false;
                                  if (value == true) {
                                    isPharmacieDeGardeSelected = false;
                                    isPharmacieDeNuitSelected = false;
                                  }
                                });
                              },
                              activeColor: Colors
                                  .white, // Couleur de la case à cocher lorsqu'elle est active
                              checkColor:
                                  Colors.black, // Couleur de la coche (tick)
                            ),
                            CheckboxListTile(
                              title: Text("Pharmacie de nuit"),
                              value: isPharmacieDeNuitSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  isPharmacieDeNuitSelected = value ?? false;
                                  if (value == true) {
                                    isPharmacieDeGardeSelected = false;
                                    isPharmacieDeJourSelected = false;
                                  }
                                });
                              },
                              activeColor: Colors
                                  .white, // Couleur de la case à cocher lorsqu'elle est active
                              checkColor:
                                  Colors.black, // Couleur de la coche (tick)
                            ),
                            SizedBox(height: 30),
                            if (_isButtonVisible())
                              Center(
                                child: Container(
                                  width: screenWidth * 0.8,
                                  height: screenHeight * 0.083,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => localisation(
                                            isPharmacieDeGardeSelected:
                                                isPharmacieDeGardeSelected,
                                            isPharmacieDeNuitSelected:
                                                isPharmacieDeNuitSelected,
                                            isPharmacieDeJourSelected:
                                                isPharmacieDeJourSelected,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: EdgeInsets.all(15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                    ),
                                    child: Text(
                                      'Préciser votre localisation',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
