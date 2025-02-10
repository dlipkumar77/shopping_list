import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import '/models/grocery_item.dart';
import '/widgets/new_item.dart';
//import '/data/dummy_items.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  //final List<GroceryItem> _groceryItems = [];
  List<GroceryItem> _groceryItems = [];
  // overide the _groceryItems so remove final

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-e37d9-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);
    //final Map<String, Map<String, dynamic>> listData =  //  Unhandled Exception: type '_Map<String, dynamic>' so
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> _loadedItems = [];
    for (final item in listData.entries) {
      final categoryFind = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      _loadedItems.add(
        GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: categoryFind),
      );
    }
    setState(() {
      _groceryItems = _loadedItems;
    });

    /*
    key : nested map  // Map<String,Map> // "-OIjh1vdo9nK0F_t9iif":{"category":"Dairy","name":"milk","quantity":12}
    inner map dynamic values //  Map<String,dynamic> // {"category":"Dairy","name":"milk","quantity":12}
    Map<String,Map<String,dynamic>>
    {
    "-OIjh1vdo9nK0F_t9iif":{"category":"Dairy","name":"milk","quantity":12},
    "-OIjk0e9Zn51KROOXi3I":{"category":"Fruit","name":"apples","quantity":15}
    }
    print(response.body);
    */
  }

  void _addItem() async {
    await Navigator.of(context).push<GroceryItem>(
      //final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItem(),
      ),
    );
    _loadItems();

    /*
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    */
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text('No items added yet'),
    );

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
