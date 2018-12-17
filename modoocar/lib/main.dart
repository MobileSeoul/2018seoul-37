import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/src/services/clipboard.dart';

import 'package:modoocar/Model/Resource.dart';
import 'package:modoocar/Model/PlaceModel.dart';
import 'package:modoocar/Model/ZoomModel.dart';

import 'package:modoocar/Common/PlaceList.dart';
import 'package:modoocar/Common/common.dart';
import 'package:modoocar/views/toast.dart';

void main() => runApp(new MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "",
      theme: new ThemeData(
        primarySwatch: Colors.lightBlue, //#FFC107
      ),
      home: new MyHomePage(),
      // routes: < String, WidgetBuilder> {
      //   '/HomeScreen' : (BuildContext context) => new MyHomePage()
      // }
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{

  VoidCallback _showPersBottomSheetCallBack;
  ModooCarResource fix;
  List<PlaceModel> initPlace ;
  List<Marker> allMarkers = [];
  AnimationController _aniController;
  EntAssetsImages corp = new EntAssetsImages();
  FilterImage filter = new FilterImage();
  SearchBar searchBar;
  MapController _mapController;

  // List<String> corpMarkers = [corp.greencarAssetsImage, corp.socarAssetsImage ]; 

  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final String seoulApiKey = "7266724e4a636d7336357854476f67";
  double centerLat = 37.5610336;
  double centerLng = 126.9795367;
  double currentZoomLevel;
  double lastZoomLevel;
  Timer timer = null;
  String filName = "all";
  

  void _animatedMapMove (LatLng destLocation, double destZoom , MapController _mapController) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = new Tween<double>(begin: _mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = new Tween<double>(begin: _mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = new Tween<double>(begin: _mapController.zoom, end: destZoom);

    // Create a new animation controller that has a duration and a TickerProvider.
    AnimationController controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =  CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      // Note that the mapController.move doesn't seem to like the zoom animation. This may be a bug in flutter_map.
      _mapController.move(LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)), _zoomTween.evaluate(animation));
      //print("Location (${_latTween.evaluate(animation)} , ${_lngTween.evaluate(animation)}) @ zoom ${_zoomTween.evaluate(animation)}");
    });

    animation.addStatusListener((status) {
      print("$status");
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }


  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      title: new Container(
        width: 130.0,
        child:new Image.asset('assets/logo/application_logo.png', fit: BoxFit.contain, alignment: Alignment.centerLeft, ),
      ) ,
      actions: [searchBar.getSearchAction(context)],
      flexibleSpace: new Container(
         decoration: new BoxDecoration(
            gradient: LinearGradient(
              colors:[
                Colors.green,
                Colors.lightBlue
              ]
            )
         ),
      ),
    );
  }  
  
  Future mapApi_google_search(String addr) async { 

    String searchTextUri = makePlaceUri(addr);
    http.Response response = await http.get(
      Uri.encodeFull(searchTextUri),
      headers:{
        "Accept" : "application/json"
      }
    );

    var detailAddress = json.decode(response.body);

    centerLat = detailAddress["results"][0]["geometry"]["location"]["lat"];
    centerLng = detailAddress["results"][0]["geometry"]["location"]["lng"];
    _animatedMapMove(new LatLng(centerLat, centerLng), currentZoomLevel, _mapController);

  }

  TextFieldSubmitCallback searchTextField( String addr ){
    // centerLat, centerLng,
    mapApi_google_search(addr);

  }


  _MyHomePageState() {
    searchBar = new SearchBar(
      inBar: false,
      setState: setState,
      onSubmitted: searchTextField,
      buildDefaultAppBar: buildAppBar,
    );
  }

  @override
  void initState() {

    super.initState();
    
    fix = new ModooCarResource();
    _mapController = new MapController();
    
    initModoocarState().whenComplete(_searchAround);

    _showPersBottomSheetCallBack = _showBottomSheet;
    _aniController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

  }

  initModoocarState() async{
      initPlace = await getPlaceList();
      setState(() {
              _animatedMapMove(new LatLng(centerLat, centerLng), currentZoomLevel, _mapController);
            });
  }

  void _showBottomSheet() {
    
    setState(() {
      _showPersBottomSheetCallBack = null;
    });

    _scaffoldKey.currentState
        .showBottomSheet((context) {
          return new Container(
            height: 300.0,
            color: Colors.greenAccent,
            child: new Center(
              child: new Text("Hi BottomSheet"),
            ),
          );
        })
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              _showPersBottomSheetCallBack = _showBottomSheet;
            });
          }
        });
  }

  // Bottom Sheet Method
  Future getPointData(String apiAddr , PlaceModel target) async{

    http.Response response = await http.get(
      Uri.encodeFull(apiAddr),
      headers:{
        "Accept" : "application/json"
      }
    );

    var document = xml.parse(response.body);
    // spotName 
    var dispAddr = document.findAllElements("SPONAM").first.text;
    // 예약 가능한 카운트
    var ableCount = document.findAllElements("reservAbleCnt").first.text;
    // 브랜드 컬러 
    var brandColor = markerColor(target.entrps);

     showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
            child: 
              new Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  new Container(
                    color: brandColor,
                    child: new Card(
                      color: brandColor,
                      elevation: 0.0,
                      child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new ListTile(
                            leading: new Image.asset(brandLogoPath(target.entrps), fit: BoxFit.contain, width: 68.0,),
                            title: new Text(dispAddr + " 지점" , style: TextStyle( color: Colors.white , fontWeight: FontWeight.w600),),
                            // subtitle: new Text("예약 가능 " + ableCount + " 대" , style: TextStyle( color: Colors.white),),
                          ),
                          new ButtonTheme.bar( // make buttons use the appropriate styles for cards
                            child: new ButtonBar(
                              children: <Widget>[
                                new Text("예약가능 " + ableCount + " 대 " , style: TextStyle( color: Colors.white), textAlign: TextAlign.left,),
                                new Text("\u00A0\u00A0"),
                                new OutlineButton(
                                  borderSide: BorderSide( color: Colors.white, width: 1.0),
                                  child: new Text("GO" , style: TextStyle( color: Colors.white),),
                                  onPressed: () { 
                                    Clipboard.setData(new ClipboardData(text:target.positnNm));
                                    _launchURL(target.entrps , target.positnNm); 
                                    },
                                   
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                   
                    padding: EdgeInsets.all(10.0),
                    width: MediaQuery.of(context).size.width,
                  ),
                ]
              )
          );
        });

  }
  // app
  _launchURL(String brand, String address ) async {

    String url = (brand == "그린카") ? "http://app.greencar.co.kr/MobileApp/view/view_banner_gateway.php?flag=banner" : "socar://reserve";

    toastController("주소가 복사되었습니다.");

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      toastController("앱을 설치해주세요.");
      throw 'Could not launch $url';
    }

  }
     
  void _searchAround() async{

    List<Marker> addMarker = new List<Marker>();
    allMarkers.clear();
    allMarkers = new List<Marker>();

      
      for (var plc in initPlace) {

        var distance = await Geolocator().distanceBetween(centerLat, centerLng, plc.la, plc.lo);

        if ( plc.entrps == filName) {

          if ( distance < zoomMeter[currentZoomLevel.toInt()]){

            addMarker.add(new Marker(
                width:  fix.markerWidth * (currentZoomLevel / 13) ,
                height: fix.markerHeight * (currentZoomLevel / 13),
                point: new LatLng(plc.la, plc.lo),
                builder: (ctx) =>
                  new Container(
                    child: new IconButton(
                      icon: new Image.asset(markerIconPath(plc.entrps)),
                      color: markerColor(plc.entrps),
                      iconSize:fix.markerIconSize ,
                      onPressed: () {
                        _showModalSheet(plc);
                      },
                    )
                  )
              ));
            }

          } else if ( filName == "all") {

            if ( distance < zoomMeter[currentZoomLevel.toInt()]){

            addMarker.add(new Marker(
                width:  fix.markerWidth * (currentZoomLevel / 13) ,
                height: fix.markerHeight * (currentZoomLevel / 13),
                point: new LatLng(plc.la, plc.lo),
                builder: (ctx) =>
                  new Container(
                    child: new IconButton(
                      icon: new Image.asset(markerIconPath(plc.entrps)),
                      color: markerColor(plc.entrps),
                      iconSize:fix.markerIconSize ,
                      onPressed: () {
                        _showModalSheet(plc);
                      },
                    )
                  )
              ));
            }

          }
      }

      lastZoomLevel = currentZoomLevel;

      setState(() {
            allMarkers = addMarker;
      });

  }

  void _showModalSheet( PlaceModel point) {

    String apiURL = makeUri(seoulApiKey, point.positnId, point.entrps);
    getPointData(apiURL,point);

  }

  @override
  Widget build(BuildContext context) {

    List<String> coprs = [ filter.all,filter.greencar, filter.socar];
    Color foregroundColor = Theme.of(context).accentColor;
    Color backgroundColor = Theme.of(context).cardColor;

    return new Scaffold(
        key: _scaffoldKey,
        appBar: searchBar.build(context),
        body: new Container(
          child: new Center(
            // Use future builder and DefaultAssetBundle to load the local JSON file
            child: new FlutterMap(
                    options: new MapOptions(
                      center: new LatLng(centerLat, centerLng),
                      zoom: fix.defaultZoom,
                      maxZoom: fix.maxZoom,
                      onPositionChanged: (point){
                        currentZoomLevel = point.zoom ;
                        centerLat = point.center.latitude;
                        centerLng = point.center.longitude;
                        if ( timer == null){
                          timer = new Timer(const Duration( seconds: 1), _searchAround);
                        } else {
                          timer.cancel();
                          timer = new Timer(const Duration( milliseconds: 500), _searchAround);
                        }
                      },
                    ),
                    layers: [
                      new TileLayerOptions(
                        urlTemplate: "http://mt1.google.com/vt/street=y&hl=kr&x={x}&y={y}&z={z}",
                      ),
                      new MarkerLayerOptions(markers:allMarkers),
                    ],
                    mapController: _mapController,
                ),
            ),
          ),
          floatingActionButton: new Column(
             mainAxisSize: MainAxisSize.min,
             children: new List.generate(coprs.length, (int index) {
                    Widget child = new Container(
                      height: 70.0,
                      width: 56.0,
                      alignment: FractionalOffset.topCenter,
                      child: new ScaleTransition(
                        scale: new CurvedAnimation(
                          parent: _aniController,
                          curve: new Interval(
                            0.0,
                            1.0 - index / coprs.length / 2.0,
                            curve: Curves.fastOutSlowIn
                          ),
                        ),
                        child: new FloatingActionButton(
                          key: ValueKey(index.toString()),
                          heroTag: null,
                          backgroundColor: backgroundColor,
                          mini: true,
                          child: new Image.asset(coprs[index]),
                          onPressed: () {
                            filName = filterName[index];
                            _searchAround();
                          },
                        ),
                      ),
                    );
                    return child;
                  }).toList()..add(
                  new FloatingActionButton(
                    heroTag: null,
                    child: new AnimatedBuilder(
                      animation: _aniController,
                      builder: (BuildContext context, Widget child) {
                        return new Transform(
                          transform: new Matrix4.rotationZ(_aniController.value * 0.5 * math.pi),
                          alignment: FractionalOffset.center,
                          child: new Icon(_aniController.isDismissed ? Icons.filter_list : Icons.close, color: Colors.white,),
                        );
                      },
                    ),
                    onPressed: () {
                      if (_aniController.isDismissed) {
                        _aniController.forward();
                      } else {
                        _aniController.reverse();
                      }
                    },
                  )
                 ),
          )
                 );
        
      }
    }