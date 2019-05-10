import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:toca/model/consumable.dart';
import 'package:toca/utils/store.dart';
import 'package:toca/ui/widgets/consumable_card.dart';
import 'package:toca/model/state.dart';
import 'package:toca/state_widget.dart';
import 'package:toca/ui/screens/login.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  StateModel appState;

  DefaultTabController _buildTabView({Widget body}) {
    const double _iconSize = 20.0;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(appState.user.displayName),
          leading: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  child: Image.network(appState.user.photoUrl),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            appState.isLoading ? Container() : _buildWalletRow(),
          ],
          elevation: 2.0,
          bottom: TabBar(
            labelColor: Theme.of(context).indicatorColor,
            tabs: [
              Tab(icon: Icon(Icons.favorite, size: _iconSize)),
              Tab(icon: Icon(Icons.restaurant, size: _iconSize)),
              Tab(icon: Icon(Icons.local_drink, size: _iconSize)),
              Tab(icon: Icon(Icons.settings, size: _iconSize)),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(5.0),
          child: body,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (appState.isLoading) {
      return _buildTabView(
        body: _buildLoadingIndicator(),
      );
    } else if (!appState.isLoading && appState.user == null) {
      return new LoginScreen();
    } else {
      return _buildTabView(
        body: _buildTabsContent(),
      );
    }
  }

  Center _buildLoadingIndicator() {
    return Center(
      child: new CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      ),
    );
  }

  Row _buildWalletRow() {
    DocumentReference userReference =
        Firestore.instance.collection('users').document(appState.user.email);
    Stream<DocumentSnapshot> stream;

    stream = userReference.snapshots();

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Icon(
          Icons.account_balance_wallet,
          size: 25,
        ),
        Padding(
          padding: EdgeInsets.only(left: 14),
        ),
        StreamBuilder(
          stream: stream,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Text(
                '0.0 €',
                style: TextStyle(fontSize: 18),
              );
            } else {
              return Text(
                snapshot.data['balance'] + ' €',
                style: TextStyle(fontSize: 18),
              );
            }
          },
        ),
        Padding(
          padding: EdgeInsets.only(right: 14),
        ),
      ],
    );
  }

  TabBarView _buildTabsContent() {
    Padding _buildConsumables(
        {ConsumableType consumableType, List<String> ids}) {
      CollectionReference collectionReference =
          Firestore.instance.collection('consumables');
      Stream<QuerySnapshot> stream;

      // The argument consumableType is set
      if (consumableType != null) {
        stream = collectionReference
            .where("type", isEqualTo: consumableType.index)
            .snapshots();
      } else {
        // Use snapshots of all consumables if consumableType has not been passed
        stream = collectionReference.snapshots();
      }

      // Define query depeneding on passed args
      return Padding(
        // Padding before and after the list view:
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: new StreamBuilder(
                stream: stream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return _buildLoadingIndicator();
                  return new ListView(
                    children: snapshot.data.documents
                        // Check if the argument ids contains document ID if ids has been passed:
                        .where((d) => ids == null || ids.contains(d.documentID))
                        .map((document) {
                      return new ConsumableCard(
                        consumable: Consumable.fromMap(
                            document.data, document.documentID),
                        inFavorites:
                            appState.favorites.contains(document.documentID),
                        onFavoriteButtonPressed: _handleFavoritesListChanged,
                        onBuyButtonPressed: _handleItemBought,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    _buildSettings() {
      return Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('Histórico da Toca'),
                onPressed: () => print('historico toca'),
              ),
              RaisedButton(
                child: Text('O Meu Histórico'),
                onPressed: () => print('meu historico'),
              ),
              RaisedButton(
                child: Text('Novo consumível'),
                onPressed: () => print('novo consumivel'),
              ),
              _buildAddFunds(),
              RaisedButton(
                onPressed: () {
                  print('Terminar sessao');
                },
                child: Text('Terminar Sessão'),
              ),
            ],
          ));
    }

    return TabBarView(
      children: [
        _buildConsumables(ids: appState.favorites),
        _buildConsumables(consumableType: ConsumableType.food),
        _buildConsumables(consumableType: ConsumableType.drink),
        _buildSettings(),
      ],
    );
  }

  // Inactive widgets are going to call this method to
  // signalize the parent widget HomeScreen to refresh the list view:
  void _handleFavoritesListChanged(String consumableID) {
    updateFavorites(appState.user.email, consumableID).then((result) {
      // Update the state:
      if (result == true) {
        setState(() {
          if (!appState.favorites.contains(consumableID))
            appState.favorites.add(consumableID);
          else
            appState.favorites.remove(consumableID);
        });
      }
    });
  }

  // Inactive widgets are going to call this method to
  // signalize the parent widget HomeScreen to refresh the list view:
  void _handleItemBought(
      String consumableID, double consumablePrice, int stock) async {
    print('Consumable purchased: ' + consumableID);
    print('Price: ' + consumablePrice.toString());

    //success snackbar
    SnackBar snackbarSuccess = SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        content: Text('Compra efetuada com sucesso'));
    SnackBar snackbarBalance = SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        content: Text('Saldo insuficiente'));
    SnackBar snackbarStock = SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        content: Text('Sem stock'));
    SnackBar snackbarError = SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        content: Text('Ocorreu um erro'));

    double currentBalance = await getCurrentBalance(appState.user.email);
    
    if (currentBalance < consumablePrice) {
      scaffoldKey.currentState.showSnackBar(snackbarBalance);
    } else if (stock <= 0) {
      scaffoldKey.currentState.showSnackBar(snackbarStock);
    } else {
      
      setState(() {
        appState.isLoading = true;
      });
      await purchaseItem(appState.user.email, consumableID, consumablePrice)
          .then((result) {
        setState(() {
          appState.isLoading = false;
        });

        if (!result) {
          scaffoldKey.currentState.showSnackBar(snackbarError);
        } else {
          scaffoldKey.currentState.showSnackBar(snackbarSuccess);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the content depending on the state:
    appState = StateWidget.of(context).state;
    return _buildContent();
  }

  Column _buildAddFunds() {
    TextEditingController _textEditingCOntroller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 100,
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: _textEditingCOntroller,
                  keyboardType: TextInputType.number,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RaisedButton(
                    child: Text('Adicionar Saldo'),
                    onPressed: () {
                      if (_textEditingCOntroller.text.length < 1) {
                        scaffoldKey.currentState.showSnackBar(SnackBar(
                          content: Text('Insira uma quantia válida'),
                          backgroundColor: Colors.red,
                        ));
                      } else {
                        addFunds(
                            appState.user.email, _textEditingCOntroller.text);
                      }
                    }),
              )
            ],
          ),
        )
      ],
    );
  }

  void addFunds(String email, String amount) {
    double doubleAmount = double.parse(amount);

    if (doubleAmount <= 0) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Insira uma quantia válida'),
        backgroundColor: Colors.red,
      ));
    } else {
      updateBalance(appState.user.email, doubleAmount);
    }
  }
}
