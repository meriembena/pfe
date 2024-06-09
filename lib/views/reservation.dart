import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Saydaliati/Controller/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

//classe statique ne change pas d'état
class ReservationsPage extends StatelessWidget {
  @override
  // build est responsable de la création et la mis à jour de l'interface utilisateur
  Widget build(BuildContext context) {
    return Scaffold(
      //'ajuster l'interface utilisateur pour qu'elle ne soit pas cachée par les zones moins habituelles de l'écran
      body: SafeArea(
        //permet de placer plusieurs widgets enfants en couches les unes par-dessus les autres
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
//utiliser pour écouter un flux de données de votre base de données et mettre à jour votre UI
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('réservations')
          .where('to', isEqualTo: email.trim())
          //créer un flux de données qui émet des mises à jour en temps réel chaque fois que les données changent
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Erreur de connexion : ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return Center(child: Text("Aucune réservation trouvée."));
        }

        return ListView(
          padding: EdgeInsets.all(16.0),
          // Accède à la liste des documents retournés par le flux Firestore
          //! est utilisé pour indiquer que snapshot.data n'est pas null
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return Card(
              color: Colors.white.withOpacity(0.8),
              elevation: 4.0,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              //utilisé pour rendre interactifs des widgets qui autrement n'auraient pas d'effets de retour lors de la touche
              child: InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ReservationDetailsPage(
                    reservationId: document.id,
                  ),
                )),
                child: ListTile(
                  title: Text(
                    data['title'] ?? 'No Title',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Made by: ${data['made by'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 5, 45, 64),
                    ),
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

class ReservationDetailsPage extends StatefulWidget {
  final String reservationId;
//permet de passer une clé au widget, ce qui est utile pour maintenir l'état dans l'arbre des widgets
//signifie que vous devez fournir une valeur pour reservationId lors de la création d'une instance
  ReservationDetailsPage({Key? key, required this.reservationId})
      : super(key: key);

  @override
//Flutter a besoin de construire le widget ReservationDetailsPage, il appelle
//createState(). Cette méthode retourne une instance de _ReservationDetailsPageState,
//qui contient tout l'état nécessaire
  _ReservationDetailsPageState createState() => _ReservationDetailsPageState();
}

//Contient et gère l'état dynamique du widget,construire l'interface utilisateur en réponse aux interactions de l'utilisateur.
class _ReservationDetailsPageState extends State<ReservationDetailsPage> {
  bool? _isConfirmed;
  String? _confirmationMessage;
// stocker les données détaillées de la réservation sous forme de clés et valeurs
  Map<String, dynamic>? reservationData;
//gérer correctement l'héritage et les surcharges de méthodes
  @override
  //C'est l'endroit où vous pouvez insérer le code d'initialisation qui doit s'exécuter une seule fois
  void initState() {
    super.initState();
    //les formats de date doivent être initialisés pour le français
    initializeDateFormatting('fr_FR', null);
    loadReservationStatus();
  }

  void loadReservationStatus() async {
    //fait référence à l'instance par défaut de Firestore utilisée par votre application
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('réservations')
        .doc(widget.reservationId)
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      //extrait les données du document et les convertit en Map<String, dynamic>
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      DateTime reservationTimestamp = DateTime.now();
      if (data['timestamp'] != null) {
        Timestamp timestamp = data['timestamp'] as Timestamp;
        //date extrait et converti en DateTime
        reservationTimestamp = timestamp.toDate();
      }
      //notifier Flutter que l'état du widget a changé
      setState(() {
        //mis à jour avec les nouvelles données
        reservationData = data;
        //eçoit la valeur du champ confirmed, convertie en booléen
        _isConfirmed = data['confirmed'] as bool?;
        //mis à jour avec le message de confirmation
        _confirmationMessage = data['confirmationMessage'];
        //mis à jour avec la DateTime calculée.
        reservationData!['timestamp'] = reservationTimestamp;
      });
    }
  }

//méthode prend un paramètre booléen qui indique si la réservation est confirmée ou refusée
  void updateReservationStatus(bool isConfirmed) async {
    String confirmationMessage =
        isConfirmed ? 'Réservation confirmée' : 'Réservation refusée';
    try {
//mettre à jour le document spécifique de la réservation avec les nouvelles valeurs
      await FirebaseFirestore.instance
          .collection('réservations')
          .doc(widget.reservationId)
          .update({
        'confirmed': isConfirmed,
        'confirmationMessage': confirmationMessage
      });
//mettre à jour l'état local du widget et déclencher une reconstruction de l'UI
      setState(() {
        _isConfirmed = isConfirmed;
        _confirmationMessage = confirmationMessage;
        if (reservationData != null) {
          reservationData!['confirmationMessage'] = confirmationMessage;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(confirmationMessage),
        backgroundColor: isConfirmed ? Colors.green : Colors.red,
      ));
    } catch (e) {
      print('Erreur lors de la mise à jour de la réservation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reservationData == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Chargement des détails...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }
//Cela permet d'afficher la date dans un format compréhensible et localisé en français.
    DateTime dateTime = reservationData!['timestamp'] as DateTime;
    String formattedDate =
        DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR').format(dateTime);

    return Scaffold(
//ajuster l'interface utilisateur pour qu'elle ne soit pas cachée par les zones moins habituelles de l'écran
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/back.jpg', fit: BoxFit.cover),
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
                            'Détails',
                            style: TextStyle(fontSize: 25, color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Titre: ${reservationData!['title']}',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        SizedBox(height: 10),
                        Text('Effectué par: ${reservationData!['made by']}',
                            style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.black)),
                        SizedBox(height: 10),
                        Text('Date de la réservation: $formattedDate',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        SizedBox(height: 20),
                        if (_confirmationMessage != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isConfirmed == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _isConfirmed == true
                                    ? Colors.green
                                    : Colors.red,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(_confirmationMessage!,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black)),
                            ],
                          ),
                        ],
                        if (_isConfirmed == null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => updateReservationStatus(true),
                                child: Text('Confirmer'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white),
                              ),
                              ElevatedButton(
                                onPressed: () => updateReservationStatus(false),
                                child: Text('Refuser'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
