import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewConsumable extends StatefulWidget {
  @override
  _NewConsumableState createState() => _NewConsumableState();
}

class _NewConsumableState extends State<NewConsumable> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String _title = 'Adicionar Novo Consumível';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(_title),
      ),
      body: new SafeArea(
          top: false,
          bottom: false,
          child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  new DropdownButtonFormField(
                    items: <DropdownMenuItem>[
                      DropdownMenuItem(
                        child: Text('Comida'),
                        value: 0,
                      ),
                      DropdownMenuItem(
                        child: Text('Bebida'),
                        value: 1,
                      ),
                    ],
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.class_),
                      hintText: 'Tipo',
                    ),
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.assignment),
                      hintText: 'Nome',
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.euro_symbol),
                      hintText: 'Preço',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.shopping_cart),
                      hintText: 'Stock',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.add_shopping_cart),
                      hintText: 'Stock Mínimo',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                  ),
                  new Container(
                      padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                      child: new RaisedButton(
                        child: const Text('Submit'),
                        onPressed: null,
                      )),
                ],
              ))),
    );
  }
}
