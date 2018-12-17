import 'package:flutter/material.dart';

import 'package:modoocar/Model/Resource.dart';

String makeUri ( String apiKey , String positionID, String entrps){
  String uri = "http://openapi.seoul.go.kr:8088/"+ apiKey+"/xml/NanumcarCarList/1/5/"+positionID+"/"+ ((entrps == "그린카") ? "gr" : "so");
  return uri;
}

String markerIconPath( String ent){
  EntAssetsImages corp = new EntAssetsImages();
  return (ent == "그린카") ? corp.greencarMarker : corp.socarMarker;
}

String brandLogoPath( String ent){

  EntAssetsImages corp = new EntAssetsImages();
  return (ent == "그린카") ? corp.greencarLogo : corp.socarLogo;

}

Color markerColor( String ent){
  return (ent == "그린카") ? const Color(0xFF00af56) : const Color(0xFF00d2ff);
}

String makePlaceUri ( String addr ){
  String uri = "https://maps.googleapis.com/maps/api/geocode/json?address="+ addr +"&key=AIzaSyB9v1Y5sXuHXBkGSg4rpbrmRdHxflnQ_HA";
  return uri;
}




