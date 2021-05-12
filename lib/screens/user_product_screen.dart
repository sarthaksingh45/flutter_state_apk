import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/user_product_edit.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('All Products'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductsScreen.routeName);
              }),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListView.builder(
            itemBuilder: (ctx, i) => Column(children: [
              UserProductEdit(productData.items[i].id,
                  productData.items[i].title, productData.items[i].imageUrl),
              Divider(),
            ]),
            itemCount: productData.items.length,
          ),
        ),
      ),
    );
  }
}
