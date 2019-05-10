import 'package:flutter/material.dart';

import 'package:toca/model/consumable.dart';

class ConsumableCard extends StatelessWidget {
  final Consumable consumable;
  final bool inFavorites;
  final Function onFavoriteButtonPressed;
  final Function onBuyButtonPressed;

  ConsumableCard(
      {@required this.consumable,
      @required this.inFavorites,
      @required this.onFavoriteButtonPressed,
      @required this.onBuyButtonPressed});

  @override
  Widget build(BuildContext context) {
    RawMaterialButton _buildFavoriteButton() {
      return RawMaterialButton(
        constraints: const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
        onPressed: () => onFavoriteButtonPressed(consumable.id),
        child: Icon(
          // Conditional expression:
          // show "favorite" icon or "favorite border" icon depending on widget.inFavorites:
          inFavorites == true ? Icons.favorite : Icons.favorite_border,
          color: Theme.of(context).iconTheme.color, // New code
        ),
        elevation: 2.0,
        fillColor: Theme.of(context).buttonColor, // New code
        shape: CircleBorder(),
      );
    }

    RawMaterialButton _buildBuyButton() {
      return RawMaterialButton(
        constraints: const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
        onPressed: () => onBuyButtonPressed(consumable.id, consumable.price, consumable.stock),
        child: Icon(
          Icons.shopping_cart,
          color: Colors.black, // New code
        ),
        elevation: 2.0,
        fillColor: Theme.of(context).buttonColor, // New code
        shape: CircleBorder(),
      );
    }

    Row _buildPriceRow() {
      return Row(
        children: <Widget>[
          Icon(
            Icons.euro_symbol,
            size: 20.0,
            color: Colors.black,
          ),
          SizedBox(width: 5.0),
          Text(
            consumable.price.toString(),
          ),
        ],
      );
    }

    Padding _buildTitleSection() {
      return Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          // Default value for crossAxisAlignment is CrossAxisAlignment.center.
          // We want to align title and description of Consumables left:
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  consumable.name,
                ),
                Text('Stock: '+consumable.stock.toString()),
              ],
            ),
            // Empty space:
            SizedBox(height: 10.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceRow(),
                _buildBuyButton(),
              ],
            ),
            Row(
              children: <Widget>[],
            )
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: () => print("Tapped!"),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // We overlap the image and the button by
              // creating a Stack object:
              Stack(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 16.0 / 9.0,
                    child: Image.network(
                      consumable.imageURL,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    child: _buildFavoriteButton(),
                    top: 2.0,
                    right: 2.0,
                  ),
                ],
              ),
              _buildTitleSection(),
            ],
          ),
        ),
      ),
    );
  }
}
