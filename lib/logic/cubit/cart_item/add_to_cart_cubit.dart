import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/model/select_food.dart';
import '../../../data/model/week_offer.dart';

part 'add_to_cart_state.dart';

class AddToCartCubit extends Cubit<AddToCartState> {
  AddToCartCubit() : super(AddToCartInitial());

  List<SelectFood> cartItems = [];

  void clear() {
    cartItems.clear();
    emit(AddToCartInitial());
  }

  void addItemToCart(WeekOfferInfo item) {
    // Check if the item already exists in the selected items
    final existingItemIndex = cartItems.indexWhere((s) => s.id == item.id);

    if (existingItemIndex != -1) {
      // Update quantity for the existing item
      final existingItem = cartItems[existingItemIndex];
      final newQuantity = int.parse(existingItem.quantity ?? '1') + 1;
      existingItem.quantity = newQuantity.toString();
    } else {
      // Add new item
      final newItem = SelectFood(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: item.qty,
        image: item.image
      );
      cartItems.add(newItem);
    }
    _updateState();
  }

  void removeItemFromCart(WeekOfferInfo item) {
    // Check if the item exists
    final existingItemIndex = cartItems.indexWhere((s) => s.id == item.id);

    if (existingItemIndex != -1) {
      // Decrease the quantity or remove the item if the quantity is 1
      final existingItem = cartItems[existingItemIndex];
      int newQuantity = int.parse(existingItem.quantity ?? '1') - 1;

      if (newQuantity <= 0) {
        cartItems
            .removeAt(existingItemIndex); // Remove item if quantity is 0
      } else {
        existingItem.quantity = newQuantity.toString(); // Update quantity
      }
    }

    _updateState();
  }

  // Updates the state with the current list of items and totals
  void _updateState() {
    double estimatedPrice = 0.0;
    int quantity = 1;

    for (var item in cartItems) {
      double offerPrice = item.price ?? 0.0;
      quantity = int.tryParse(item.quantity ?? '1') ?? 1;
      estimatedPrice += offerPrice * quantity;
    }

    emit(AddToCartTotal(estimatedPrice, cartItems));
  }
}