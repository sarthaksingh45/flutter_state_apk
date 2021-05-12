import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem(
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.datetime,
  );
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  final String token;
  final String userId;

  Orders(this.token, this.userId, this._orders);

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://myappdev-becaa-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final response = await http.get(url);
    //print(response.body);
    final List<OrderItem> loadedProducts = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    // if (extractedData == null) {
    //   return;
    // }
    extractedData.forEach((key, value) {
      loadedProducts.add(
        OrderItem(
            key,
            value['total'],
            (value['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                      id: item['id'],
                      title: item['title'],
                      price: item['amount'],
                      quantity: item['quantity']),
                )
                .toList(),
            DateTime.parse(value['DateTime'])),
      );
    });
    _orders = loadedProducts.reversed.toList();
    notifyListeners();
  }

  Future<void> addItem(List<CartItem> cartItem, double amount) async {
    final url = Uri.parse(
        'https://myappdev-becaa-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'total': amount,
          'DateTime': timeStamp.toIso8601String(),
          'products': cartItem
              .map((ct) => {
                    'id': ct.id,
                    'title': ct.title,
                    'amount': ct.price,
                    'quantity': ct.quantity,
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        OrderItem(json.decode(response.body)['name'], amount, cartItem,
            DateTime.now()));
    notifyListeners();
  }
}
