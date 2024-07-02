import 'package:destination_repository/destination_repository.dart';

class Menu {
  final String id;
  final String destinationId;
  final List<MenuItem> items;

  Menu({
    required this.id,
    required this.destinationId,
    required this.items,
  });

  factory Menu.fromEntity(MenuEntity entity) {
    return Menu(
      id: entity.id,
      destinationId: entity.destinationId,
      items: entity.items.map((item) => MenuItem.fromMap(item)).toList(),
    );
  }
}

class MenuItem {
  final String menuItem;
  final int price;

  MenuItem({
    required this.menuItem,
    required this.price,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      menuItem: map['name'] ?? '',
      price: map['price'] ?? '',
    );
  }
}
