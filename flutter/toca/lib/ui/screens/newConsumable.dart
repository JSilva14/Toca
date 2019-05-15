import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toca/model/consumable.dart';
import 'package:toca/model/state.dart';
import 'package:toca/state_widget.dart';
import 'package:toca/utils/store.dart';
import 'package:file_picker/file_picker.dart';

class NewConsumable extends StatefulWidget {
  @override
  _NewConsumableState createState() => _NewConsumableState();
}

//TODO: loading on submit
//TODO: scrollview
class _NewConsumableState extends State<NewConsumable> {
  StateModel appState;
  final GlobalKey<FormState> _formKey = new GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey();

  FocusNode _nameFocusNode = FocusNode();
  FocusNode _priceFocusNode = FocusNode();
  FocusNode _stockFocusNode = FocusNode();
  FocusNode _minStockFocusNode = FocusNode();

  String _title = 'Adicionar Novo Consumível';
  int _type, _stock, _minStock, _hint;
  double _price;
  String _name, _filePath;
  Future<String> _filePathFuture;

  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(_title),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              DropdownButtonFormField(
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
                value: _hint,
                onSaved: (val) {
                  _type = val;
                  FocusScope.of(context).requestFocus(_nameFocusNode);
                },
                onChanged: (val) {
                  setState(() {
                    _hint = val;
                  });
                },
              ),
              TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.assignment),
                    hintText: 'Nome',
                  ),
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (val) =>
                      FocusScope.of(context).requestFocus(_priceFocusNode),
                  keyboardType: TextInputType.text,
                  onSaved: (val) {
                    _name = val;
                  }),
              TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.euro_symbol),
                    hintText: 'Preço',
                  ),
                  focusNode: _priceFocusNode,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    try {
                      if (val.isEmpty || double.parse(val) < 0) {
                        return 'Valor inválido';
                      }
                    } catch (e) {
                      return 'Valor inválido';
                    }
                  },
                  onFieldSubmitted: (val) =>
                      FocusScope.of(context).requestFocus(_stockFocusNode),
                  onSaved: (val) {
                    _price = double.parse(val);
                  }),
              TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.shopping_cart),
                    hintText: 'Stock',
                  ),
                  focusNode: _stockFocusNode,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly,
                  ],
                  validator: (val) {
                    try {
                      if (val.isEmpty || double.parse(val) < 0) {
                        return 'Valor inválido';
                      }
                    } catch (e) {
                      return 'Valor inválido';
                    }
                  },
                  onFieldSubmitted: (val) =>
                      FocusScope.of(context).requestFocus(_minStockFocusNode),
                  onSaved: (val) {
                    _stock = int.parse(val);
                  }),
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.add_shopping_cart),
                  hintText: 'Stock Mínimo',
                ),
                focusNode: _minStockFocusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  WhitelistingTextInputFormatter.digitsOnly,
                ],
                validator: (val) {
                  try {
                    if (val.isEmpty || double.parse(val) < 0) {
                      return 'Valor inválido';
                    }
                  } catch (e) {
                    return 'Valor inválido';
                  }
                },
                onSaved: (val) => _minStock = int.parse(val),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 28,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Foto: '),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        _filePathFuture = _selectImage();
                        setState(() {});
                      },
                      child: FutureBuilder<String>(
                          future: _filePathFuture,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              _filePath = snapshot.data;
                              return Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  image: DecorationImage(
                                      image: FileImage(
                                        File(snapshot.data),
                                      ),
                                      fit: BoxFit.scaleDown),
                                ),
                              );
                            } else {
                              return Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                ),
                              );
                            }
                          }),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: appState.isLoading
                    ? SizedBox(
                        width: 50,
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      )
                    : Container(
                        child: RaisedButton(
                        child: const Text('Criar consumível'),
                        onPressed: submit,
                      )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _selectImage() async {
    return FilePicker.getFilePath(type: FileType.IMAGE);
  }

  void submit() async {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      ConsumableType _consumableType;

      if (this._type == 0) {
        _consumableType = ConsumableType.food;
      } else {
        _consumableType = ConsumableType.drink;
      }

      Consumable _newConsumable = Consumable(
          id: this._name,
          type: _consumableType,
          name: this._name,
          price: this._price,
          stock: this._stock,
          minStock: this._minStock);

      setState(() {
        appState.isLoading = true;
      });
      await addNewConsumable(_newConsumable, _filePath).then((result) {
        setState(() {
          appState.isLoading = false;
        });
        _scaffoldState.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text('Consumível adicionado!'),
        ));
      }).catchError((error) {
        print(error.toString());
        setState(() {
          appState.isLoading = false;
        });
        _scaffoldState.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text('Ocorreu um erro!'),
        ));
      });
    }
  }
}
