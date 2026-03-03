import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final String restaurantId;
  final String category;

  const MenuItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.restaurantId,
    required this.category,
  });

  MenuItem copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? price,
    String? description,
    String? restaurantId,
    String? category,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      description: description ?? this.description,
      restaurantId: restaurantId ?? this.restaurantId,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl, price, description, restaurantId, category];
}
