import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        fit: StackFit.expand,
         children: <Widget>[
           new Container(
             decoration: BoxDecoration(color: Colors.lightBlueAccent)
           ),
           new Column(
              mainAxisAlignment: MainAxisAlignment.start,
             children: <Widget>[
               new Expanded(
                 flex: 2,
                 child : new Container(
                    child: new Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: <Widget>[
                         new CircleAvatar(
                            backgroundColor: Colors.lightBlue,
                             radius: 80.0,
                             child : new Image.asset("assets/logo/modoocar_logo.png", width: 300.0,)
                         )
                       ],
                    ),
                 )
               ),
               new Expanded(
                 child : new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(  valueColor: new AlwaysStoppedAnimation<Color>(Colors.amberAccent)),
                      new Padding(
                         padding: EdgeInsets.only(top:20.0),
                      )
                    ],
                 )
               )
             ],
           )

         ],
      ),
    );
  }

  startTime() async{
    var _duration = new Duration( seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage(){
    Navigator.of(context).pushReplacementNamed("/HomeScreen");
  }

  @override
  void initState(){
    super.initState();
    startTime();
  }

}
