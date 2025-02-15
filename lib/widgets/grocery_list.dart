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
  //var _isLoading = true;
  late Future<List<GroceryItem>> _loadedItems;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    //void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-e37d9-default-rtdb.firebaseio.com', 'shopping-list.json');

    //try- catch -> invalid domain, internet conncetion etc.,
    //remove tyr catch also future use
    // try {
    final response = await http.get(url);
    if (response.statusCode > 400) {
      throw Exception('Failed to fetch grocery items. Please try again later.');
      // setState(() {
      //   _error = 'Failed to fetch data. Please try again later.';
      // });
    }
    // No data check
    if (response.body == 'null') {
      /*
        //don'n need setState because future use
        setState(() {
          _isLoading = false;
        });
        return;
        */
      return []; // return empy list
    }
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
    return _loadedItems;
    /*
      Future use no needed this line
      setState(() {
        _groceryItems = _loadedItems;
        _isLoading = false;
      });
      */
    /*
    //remove tyr catch also future use
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
     */
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
    final newItem = await Navigator.of(context).push<GroceryItem>(
      //final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    // _loadItems(); - avoid unncessery extra http requests

    /*
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    */
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('flutter-prep-e37d9-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // optional : show snackbar or error message
      setState(() {
        //_groceryItems.remove(item);
        //_groceryItems.add(item); //adding it this would diif place so we want correct index thats why we get first item index
        _groceryItems.insert(index,
            item); // previous lesson snackbar undo operation used this type ; this is add item specific index
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /*
    // empty data
   code ship to future builder place
    Widget content = Center(
      child: Text('No items added yet'),
    );

   code ship to future builder place
    if (_isLoading) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    }

    */

    /*
 code ship to future builder place
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
      */
    /*
   code ship to future builder place
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    */

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
      //body: content,
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.data!.isEmpty) {
            return Center(child: Text('No items added yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) => Dismissible(
              onDismissed: (direction) {
                _removeItem(snapshot.data![index]);
              },
              key: ValueKey(snapshot.data![index].id),
              child: ListTile(
                title: Text(snapshot.data![index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: snapshot.data![index].category.color,
                ),
                trailing: Text(
                  snapshot.data![index].quantity.toString(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
