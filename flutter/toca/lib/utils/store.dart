import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> initializeUser(String email) async {
  DocumentReference userReference =
      Firestore.instance.collection('users').document(email);

  return Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(userReference);
    if (!postSnapshot.exists) {
      String initialBalance = "0.0";
      await tx.set(userReference, {'balance': initialBalance, 'favorites': []});
    }
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}

Future<double> getCurrentBalance(String email) async {
  DocumentSnapshot querySnapshot =
      await Firestore.instance.collection('users').document(email).get();
  if (querySnapshot.exists && querySnapshot.data.containsKey('balance')) {
    // Create a new List<String> from List<dynamic>
    return double.parse(querySnapshot.data['balance']);
  }
  return 0.0;
}

Future<bool> purchaseItem(
    String email, String consumableId, double consumablePrice) {
  DocumentReference consumableReference =
      Firestore.instance.collection('consumables').document(consumableId);

  return Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(consumableReference);

    if (postSnapshot.exists) {
      await tx.update(consumableReference,
          <String, dynamic>{'stock': FieldValue.increment(-1)});
      await updateBalance(email, -consumablePrice);
    }
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}

Future<bool> updateFavorites(String email, String consumableId) {
  DocumentReference favoritesReference =
      Firestore.instance.collection('users').document(email);

  return Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(favoritesReference);
    if (postSnapshot.exists) {
      // Extend 'favorites' if the list does not contain the recipe ID:
      if (!postSnapshot.data['favorites'].contains(consumableId)) {
        await tx.update(favoritesReference, <String, dynamic>{
          'favorites': FieldValue.arrayUnion([consumableId])
        });
        // Delete the recipe ID from 'favorites':
      } else {
        await tx.update(favoritesReference, <String, dynamic>{
          'favorites': FieldValue.arrayRemove([consumableId])
        });
      }
    }
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}

Future<bool> updateBalance(String email, double amount) {
  DocumentReference userReference =
      Firestore.instance.collection('users').document(email);

  return Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(userReference);
    if (postSnapshot.exists) {
      double currentBalance = await getCurrentBalance(email);
      String updatedBalance = (currentBalance + amount).toStringAsFixed(2);

      await tx
          .update(userReference, <String, dynamic>{'balance': updatedBalance});
    }
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}
