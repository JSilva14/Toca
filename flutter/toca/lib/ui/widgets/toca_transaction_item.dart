import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:toca/model/toca_transaction.dart';

class TocaTransactionItem extends StatelessWidget {
  final TocaTransaction transaction;

  TocaTransactionItem({@required this.transaction});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUsername(transaction.userReference.documentID),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          var format = DateFormat('dd/MM/yyyy hh:mm:ss').format(transaction.timestamp);
          String weekDay = transaction.timestamp.weekday == 1
              ? 'Segunda-Feira'
              : transaction.timestamp.weekday == 2
                  ? 'Terça-Feira'
                  : transaction.timestamp.weekday == 3
                      ? 'Quarta-Feira'
                      : transaction.timestamp.weekday == 4
                          ? 'Quinta-Feira'
                          : transaction.timestamp.weekday == 5
                              ? 'Sexta-Feira'
                              : transaction.timestamp.weekday == 6
                                  ? 'Sábado'
                                  : 'Domingo';
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
            child: Container(
              height: 100,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical:10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '$weekDay, '
                          '${format.toString()}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              snapshot.data,
                              textAlign: TextAlign.center,
                            ),
                          )),
                      Expanded(
                        flex: 1,
                        child: Icon(
                          transaction.consumable != null
                              ? Icons.shopping_cart
                              : Icons.account_balance_wallet,
                          color: Colors.green,
                        ),
                      ),
                      transaction.consumable != null
                          ? Expanded(
                              flex: 2,
                              child: Text(
                                transaction.consumable.documentID,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Container(),
                      Expanded(
                          flex: 1,
                          child: Text(
                            '${transaction.amount.toString()} €',
                            textAlign: TextAlign.center,
                          )),
                    ],
                  ),
                ]),
              ),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<String> _getUsername(String email) async {
    DocumentReference userReference =
        Firestore.instance.collection('users').document(email);
    DocumentSnapshot userSnapshot = await userReference.get();

    return userSnapshot.data['name'];
  }
}
