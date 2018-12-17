import 'package:fluttertoast/fluttertoast.dart';

void toastController( String text){

    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 3,
        bgcolor: "#000000",
        textcolor: '#ffffff'
    );  

}