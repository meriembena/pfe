import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chat1/views/chatbot.dart';

class ListeScreen extends StatefulWidget {
  final String? selectedGouvernorat;
  final String? selectedDelegation;
  final bool isNight;

  const ListeScreen({
    Key? key,
    this.selectedGouvernorat,
    this.selectedDelegation,
    this.isNight = false,
  }) : super(key: key);

  @override
  State<ListeScreen> createState() => _ListeScreenState();
}

class _ListeScreenState extends State<ListeScreen> {
  late List<Map<String, dynamic>> pharmacies = [];

  @override
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
        var gouvernoratData =
            data?[widget.selectedGouvernorat] as Map<String, dynamic>?;
        var delegationData = gouvernoratData?[widget.selectedDelegation]
            as Map<String, dynamic>?;
        if (delegationData != null) {
          delegationData.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              pharmacies.add({
                'nomF': value['nomF'] ?? 'Nom inconnu',
                'adresse': value['adresse'] ?? 'Adresse inconnue',
                'tel': value['tel'] ?? 'Numéro non disponible'
              });
            }
          });

          setState(() {
            pharmacies = pharmacies;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
      String telScheme = 'tel:$phoneNumber';
      if (await canLaunch(telScheme)) {
        await launch(telScheme);
      } else {
        throw 'Impossible de lancer l\'appel pour le numéro $phoneNumber';
      }
    }
  }
}
