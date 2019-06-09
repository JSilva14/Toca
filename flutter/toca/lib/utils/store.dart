import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toca/model/consumable.dart';
import 'package:toca/model/toca_transaction.dart';
import 'package:uuid/uuid.dart';

Future<bool> initializeUser(String email, String displayName) async {
  DocumentReference userReference =
      Firestore.instance.collection('users').document(email);

  return Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(userReference);
    if (!postSnapshot.exists) {
      String initialBalance = "0.0";
      await tx.set(userReference,
          {'name': displayName, 'balance': initialBalance, 'favorites': []});
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
  DocumentReference userReference =
      Firestore.instance.collection('users').document(email);

  return Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(consumableReference);
    Uuid uuid = Uuid();
    TocaTransaction tocaTransaction = TocaTransaction(
        id: uuid.v4(),
        type: TocaTransactionType.PURCHASE,
        userReference: userReference,
        consumable: consumableReference,
        amount: consumablePrice,
        timestamp: DateTime.now());

    if (postSnapshot.exists) {
      await tx.update(consumableReference,
          <String, dynamic>{'stock': FieldValue.increment(-1)});
      await updateBalance(email, -consumablePrice);
      await registerTransaction(tocaTransaction);
    }
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}

Future<bool> updateTocaBalance(double amount) {
    DocumentReference userReference =
      Firestore.instance.collection('users').document('Toca');

  return Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(userReference);
    if (postSnapshot.exists) {
      double currentBalance = await getCurrentBalance('Toca');
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
      if (amount > 0) {
        Uuid uuid = Uuid();

        TocaTransaction tocaTransaction = TocaTransaction(
            id: uuid.v4(),
            type: TocaTransactionType.DEPOSIT,
            userReference: userReference,
            amount: amount,
            timestamp: DateTime.now());

        await updateTocaBalance(amount);
        await registerTransaction(tocaTransaction);
      }
    }
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}

Future<bool> addNewConsumable(Consumable consumable, String imagePath) {
  DocumentReference consumableReference =
      Firestore.instance.collection('consumables').document(consumable.id);

  return Firestore.instance.runTransaction((Transaction tx) async {
    //DocumentSnapshot postSnapshot = await tx.get(consumableReference);

    int _type = 0;
    if (consumable.type == ConsumableType.drink) {
      _type = 1;
    }

    await tx.set(consumableReference, <String, dynamic>{
      'availability': true,
      'id': consumable.id,
      'type': _type,
      'name': consumable.name,
      'price': consumable.price,
      'stock': consumable.stock,
      'minStock': consumable.minStock,
      'imageUrl': consumable.imageURL
    }).then((result) {
      uploadConsumableImage(imagePath, consumable.id);
    });
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}

Future<bool> uploadConsumableImage(String imagePath, String imageName) async {
  StorageReference storageRef = FirebaseStorage.instance.ref().child(imageName);

  final StorageUploadTask uploadTask = storageRef.putFile(
    File(imagePath),
  );

  final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
  await downloadUrl.ref.getDownloadURL().then((url) async {
    print('URL Is $url');
    await _updateConsumableImage(url, imageName);
  });

  return true;
}

Future<bool> _updateConsumableImage(String url, String consumableId) {
  DocumentReference consumableReference =
      Firestore.instance.collection('consumables').document(consumableId);

  return Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(consumableReference);

    if (!postSnapshot.exists) {}
    await tx.update(consumableReference, <String, dynamic>{'imageUrl': url});
  }).then((result) {
    return true;
  }).catchError((error, stacktrace) {
    print('Error updating image: $error');
    print(stacktrace);
    return false;
  });
}

Future<bool> registerTransaction(TocaTransaction transaction) {
  DocumentReference transactionReference =
      Firestore.instance.collection('transactions').document(transaction.id);

  return Firestore.instance.runTransaction((Transaction tx) async {
    //transactions without consumable
    if (transaction.consumable == null) {
      await tx.set(transactionReference, <String, dynamic>{
        'id': transaction.id,
        'type': transaction.type.toString(),
        'userReference': transaction.userReference,
        'consumable': 'null',
        'amount': transaction.amount,
        'timestamp': transaction.timestamp
      });
    } else {
      //transactions with consumable
      await tx.set(transactionReference, <String, dynamic>{
        'id': transaction.id,
        'type': transaction.type.toString(),
        'userReference': transaction.userReference,
        'consumable': transaction.consumable,
        'amount': transaction.amount,
        'timestamp': transaction.timestamp
      });
    }
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');
    return false;
  });
}
