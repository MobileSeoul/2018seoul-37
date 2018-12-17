import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:modoocar/Model/PlaceModel.dart';

 
Future<String> loadPlaceAsset() async {
    return await rootBundle.loadString('assets/data/sharecar_point.json');
}

Future<List<PlaceModel>> getPlaceList() async {

  List<PlaceModel> list = new List<PlaceModel>();
  
  String jsonData = await loadPlaceAsset();
  var points = json.decode(jsonData);

  for (var point in points) {
    list.add(new PlaceModel(point["la"], point["lo"], point["entrps"], point["adres"] , point["positn_cd"], point["positn_nm"]));
  }

  return list;
}

