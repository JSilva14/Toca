import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toca/model/consumable.dart';

enum TocaTransactionType {
  PURCHASE,
  DEPOSIT,
  MONTHLY_QUOTA,
}

class TocaTransaction {
  final String id;
  final TocaTransactionType type;
  final DocumentReference userReference;
  final DocumentReference consumable;
  final double amount;
  final DateTime timestamp;

  TocaTransaction(
    {@required this.id, 
    @required this.type, 
    @required this.userReference, 
    this.consumable, 
    @required this.amount, 
    @required this.timestamp});


    TocaTransaction.fromMap(Map<String, dynamic> data)
        : this(
            id: data['id'],
            type: TocaTransactionType.values[0],
            userReference: data['userReference'],
            consumable: data['consumable'] == 'null' ? null : data['consumable'],
            amount: data['amount'],
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          );
}



