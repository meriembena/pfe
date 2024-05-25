// Importez les dépendances nécessaires
const functions = require('firebase-functions');
const admin = require('firebase-admin');
// Initialisation de l'application admin Firebase
admin.initializeApp();

// Fonction déclenchée lors de la création d'une nouvelle réservation
exports.sendReservationNotification = functions.firestore
  .document('reservations/{reservationId}')
  .onCreate(async (snapshot, context) => {
    // Extraire les données de la réservation depuis le snapshot
    const reservationData = snapshot.data();
    const { pharmacyId, medicineName, requestedBy } = reservationData;

    try {
      // Récupérer le snapshot de l'utilisateur ayant fait la réservation
      const userSnapshot = await admin.firestore().collection('Users').doc(requestedBy).get();
      const userData = userSnapshot.data();

      // Vérifier si le token FCM est disponible
      if (userData && userData.fcmToken) {
        const userFCMToken = userData.fcmToken;

        // Construire le payload de la notification
        const payload = {
          notification: {
            title: 'Nouvelle réservation',
            body: `Une réservation pour ${medicineName} a été faite et est en attente de votre confirmation.`,
            icon: 'your_icon', // Assurez-vous que cette icône est disponible dans votre projet
            click_action: "FLUTTER_NOTIFICATION_CLICK" // Pour gérer le clic sur la notification
          },
          data: {
            medicineName,
            pharmacyId
          }
        };

        // Envoyer la notification
        const response = await admin.messaging().sendToDevice(userFCMToken, payload);
        console.log('Notification sent successfully:', response);
      } else {
        console.log('No FCM token available for user:', requestedBy);
      }
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });
