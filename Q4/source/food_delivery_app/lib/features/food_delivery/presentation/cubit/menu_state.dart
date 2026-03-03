import 'package:equatable/equatable.dart';

import '../../domain/entities/menu_item.dart';
import '../../domain/entities/restaurant.dart';

sealed class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {
  const MenuInitial();
}

class MenuLoading extends MenuState {
  const MenuLoading();
}

class MenuLoaded extends MenuState {
  final Restaurant restaurant;
  final List<MenuItem> items;

  const MenuLoaded({required this.restaurant, required this.items});

  @override
  List<Object?> get props => [restaurant, items];
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}
