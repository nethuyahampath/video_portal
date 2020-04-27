//importing essential packages
import 'package:flutter/material.dart';
import 'package:video_portal/homePage.dart';


  void main() => runApp(MyApp());

  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return new MaterialApp(
        title: "Video Portal",
        home : VideoPortal()
      );
    }
  }

  class VideoPortal extends StatefulWidget {
    @override
    _VideoPortalState createState() => new _VideoPortalState();
  }

  class _VideoPortalState extends State<VideoPortal> {


    //UI screen
    @override
    Widget build(BuildContext context) {
      return new Scaffold(

        body: GestureDetector(
        child:Stack(
                children: <Widget>[
                Container(
                    decoration: new BoxDecoration(
            image:DecorationImage(
              image: AssetImage("images/gb.png"), //setted background image
              fit: BoxFit.fitHeight,
          ),
        ),
        ),        
        Padding(
          padding: const EdgeInsets.fromLTRB(350.0,922.0,0.0,10.0),
          child: Container(child: Text("Tap to continue > > >",style: TextStyle(fontSize: 20.0,color: Colors.brown[700]),),),
        )
                ]
      ),onTap:() async{
          //await new Future.delayed(const Duration(seconds: 1));
          //navigate to the home page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },

        ),

      );


    }


  }

