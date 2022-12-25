/*import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';




class ItemList  with ChangeNotifier, DiagnosticableTreeMixin {
  List<String> _itemsliked = ["test","rest"];

  void addItem(String itemData) {
    _itemsliked.add(itemData);
    notifyListeners();
  }
   void DeleteItem(String itemData) {
    _itemsliked.remove(itemData);
    notifyListeners();
  }
  List<String> get itemliked => _itemsliked;
  }*/