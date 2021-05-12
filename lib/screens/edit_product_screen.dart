import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductsScreen extends StatefulWidget {
  static const routeName = '/Edit-Product-Screen';
  @override
  _EditProductsScreenState createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _urlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(description: '', id: null, imageUrl: '', price: 0, title: '');
  var _loaded = true;
  var _isInit = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_loaded) {
      final loadedId = ModalRoute.of(context).settings.arguments as String;
      if (loadedId != null) {
        _editedProduct =
            Provider.of<Products>(context).findProductById(loadedId);
        _isInit = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          'imageUrl': '',
        };
        _urlController.text = _editedProduct.imageUrl;
      }
    }
    _loaded = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final _isValid = _form.currentState.validate();
    if (!_isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  content: Text('Something went wrong.'),
                  title: Text('An Error Occurred!!'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Okay'))
                  ],
                ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _priceFocusNode.dispose();
    _urlController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Products'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.save), onPressed: _saveForm)
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _form,
                child: ListView(
                  padding: EdgeInsets.all(10),
                  children: <Widget>[
                    TextFormField(
                      initialValue: _isInit['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Provide a value';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.newline,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            description: _editedProduct.description,
                            id: _editedProduct.id,
                            isFavourite: _editedProduct.isFavourite,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            title: value);
                      },
                    ),
                    TextFormField(
                      initialValue: _isInit['price'],
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter a Number';
                        }
                        if (double.tryParse(value) == null &&
                            double.tryParse(value) <= 0) {
                          return 'Please Enter a Valid Number';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            description: _editedProduct.description,
                            id: _editedProduct.id,
                            isFavourite: _editedProduct.isFavourite,
                            imageUrl: _editedProduct.imageUrl,
                            price: double.parse(value),
                            title: _editedProduct.title);
                      },
                    ),
                    TextFormField(
                      initialValue: _isInit['description'],
                      decoration: InputDecoration(labelText: 'Desciption'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter a Description';
                        }
                        return null;
                      },
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editedProduct = Product(
                            description: value,
                            id: _editedProduct.id,
                            isFavourite: _editedProduct.isFavourite,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            title: _editedProduct.title);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 10, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _urlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(_urlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'ImageUrl'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _urlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                  description: _editedProduct.description,
                                  id: _editedProduct.id,
                                  isFavourite: _editedProduct.isFavourite,
                                  imageUrl: value,
                                  price: _editedProduct.price,
                                  title: _editedProduct.title);
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ));
  }
}
