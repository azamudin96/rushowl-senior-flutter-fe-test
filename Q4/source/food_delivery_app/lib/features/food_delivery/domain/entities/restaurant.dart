import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final String cuisineType;
  final int deliveryTimeMinutes;
  final double deliveryFee;

  const Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.cuisineType,
    required this.deliveryTimeMinutes,
    required this.deliveryFee,
  });

  Restaurant copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? rating,
    String? cuisineType,
    int? deliveryTimeMinutes,
    double? deliveryFee,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      cuisineType: cuisineType ?? this.cuisineType,
      deliveryTimeMinutes: deliveryTimeMinutes ?? this.deliveryTimeMinutes,
      deliveryFee: deliveryFee ?? this.deliveryFee,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        rating,
        cuisineType,
        deliveryTimeMinutes,
        deliveryFee,
      ];
}
