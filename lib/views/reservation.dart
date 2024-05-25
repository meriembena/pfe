import 'package:chat1/Controller/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/back.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.asset(
                          'assets/images/Groupe 27.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Réservations',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildReservationsList(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList(BuildContext context) {
    final auth = AuthService();
    String? email = auth.currentUserEmail();

    if (email == null) {
      return Center(
          child: Text("Aucun email trouvé pour l'utilisateur actuel"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('réservations')
          .where('to', isEqualTo: email.trim())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return Center(child: Text("Aucune réservation trouvée."));
        }

        return ListView(
          padding: EdgeInsets.all(16.0),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return Card(
              color: Colors.white.withOpacity(0.8),
              elevation: 4.0,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ReservationDetailsPage(reservationData: data),
                )),
                child: ListTile(
                  title: Text(
                    data['notification']['title'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Text(
                    'Made by: ${data['notification']['made by']}',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Color.fromARGB(255, 5, 45, 64)),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNotification(document.id, context),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _deleteNotification(String docId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('réservations')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Réservation supprimée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression de la réservation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class ReservationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> reservationData;

  ReservationDetailsPage({Key? key, required this.reservationData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Réservation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: MediaQuery.of(context)
            .size
            .width, // Prend la largeur totale de l'écran
        height: MediaQuery.of(context)
            .size
            .height, // Prend la hauteur totale de l'écran
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: AppBar().preferredSize.height +
                      MediaQuery.of(context).padding.top),
              Text(
                'Titre: ${reservationData['notification']['title']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(150, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Fait par: ${reservationData['notification']['made by']}',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(150, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              // Ajoutez plus de champs selon vos données...
            ],
          ),
        ),
      ),
    );
  }
}
