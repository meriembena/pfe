import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chat1/views/Profile.dart';
import 'package:chat1/views/discussions.dart';
import 'package:chat1/views/list.dart';

class Localisation extends StatefulWidget {
  final bool isPharmacieDeGardeSelected;
  final bool isPharmacieDeNuitSelected;
  final bool isPharmacieDeJourSelected;

  Localisation({
    required this.isPharmacieDeGardeSelected,
    required this.isPharmacieDeNuitSelected,
    required this.isPharmacieDeJourSelected,
  });

  @override
  _MyApp3State createState() => _MyApp3State();
}

class _MyApp3State extends State<Localisation> {
  String? selectedGouvernorat;
  String? selectedDelegation;
  List<String> gouvernorats = [];
  Map<String, List<String>> delegations = {};

  @override
  void initState() {
    super.initState();
    chargerDonnees();
  }

  Future<void> chargerDonnees() async {
    var collection = FirebaseFirestore.instance.collection('villes');
    var snapshot = await collection.get();

    setState(() {
      gouvernorats = snapshot.docs.map((doc) => doc.id).toList();
      for (var doc in snapshot.docs) {
        delegations[doc.id] = List<String>.from(doc['délégation']);
      }
      selectedGouvernorat = gouvernorats.isNotEmpty ? gouvernorats.first : null;
      selectedDelegation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                      isExpanded: true,
                      value: selectedGouvernorat,
                      onChanged: (newValue) {
                        setState(() {
                          selectedGouvernorat = newValue;
                          selectedDelegation = null;
                        });
                      },
                      items: gouvernorats
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 18.0)),
                        );
                      }).toList(),
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
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible de lancer $url';
    }
  }
}
