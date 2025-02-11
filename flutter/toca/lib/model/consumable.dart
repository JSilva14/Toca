enum ConsumableType {
  food,
  drink,
}

class Consumable {
  final String id;
    final ConsumableType type;
    final String name;
    final int stock;
    final int minStock;
    final double price;
    final String imageURL;
  
     Consumable({
      this.stock,
      this.minStock,
      this.price, 
      this.id,
      this.type,
      this.name,
      this.imageURL = 'http://www.hmcoloringpages.com/wp-content/uploads/hot-coffee-silhouette.gif',
    });
  
     Consumable.fromMap(Map<String, dynamic> data, String id)
        : this(
            id: id,
            type: ConsumableType.values[data['type']],
            name: data['name'],
            stock: data['stock'],
            minStock: data['minStock'],
            price: data['price'],
            imageURL: data['imageUrl'],
          );
}
