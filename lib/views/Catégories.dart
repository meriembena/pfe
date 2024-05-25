import 'package:chat1/views/Profile.dart';
import 'package:chat1/views/discussions.dart';
import 'package:flutter/material.dart';
import 'package:chat1/views/Localisation.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  bool isPharmacieDeGardeSelected = false;
  bool isPharmacieDeNuitSelected = false;
  bool isPharmacieDeJourSelected = false;

  bool _isButtonVisible() {
    return isPharmacieDeGardeSelected ||
        isPharmacieDeNuitSelected ||
        isPharmacieDeJourSelected;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double cmToPx =
        MediaQuery.of(context).devicePixelRatio * 0.393701; // 1 cm en pixels

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth,
                height: screenHeight, // Utiliser toute la hauteur de l'écran
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/back.jpg',
                        fit: BoxFit.cover, // 'image couvre toute la surface
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
                                'assets/images/profil.png', // Remplacez par le chemin de votre première image
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
                                'assets/images/icons8-sms-50.png', // Remplacez par le chemin de votre deuxième image
                                width: screenWidth * 0.2,
                                height: screenHeight * 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0, // Position X relative
                      top: screenHeight * 0.002, // Position Y relative
                      child: Image.asset(
                        'assets/images/icons8-bulle-de-conversation-avec-points-96.png',
                        width: screenWidth, // Largeur égale à l'écran
                        height: cmToPx, // Hauteur de 1 cm
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
                                width: screenWidth * 0.4, // Largeur relative
                                height: screenHeight * 0.06, // Hauteur relative
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
                              activeColor: Colors
                                  .white, // Couleur de la case à cocher lorsqu'elle est active
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
                                  height:
                                      screenHeight * 0.083, // Largeur du bouton
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Localisation(
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
