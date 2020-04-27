//importing all the essential dart packages
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_portal/homePage.dart';
import 'package:video_portal/videoList.dart';


class VideoApp extends StatefulWidget {
  VideoApp() : super();


  final String title = "Video Demo";

  @override
  VideoAppState createState() => VideoAppState();
}

class VideoAppState extends State<VideoApp> { 

  VideoPlayerController _controller; //creating a private variable of video player controller
  Future<void> _initializeVideoPlayerFuture;
  final updateName = new TextEditingController(); //making update controller in order to get the user inputs

  String dUrl; //url of the video

  @override
  void initState() {
  _controller = VideoPlayerController.network(
  "$dUrl"); // getting the video from the given url
  
  _initializeVideoPlayerFuture = _controller.initialize();
  _controller.setLooping(true);
  _controller.setVolume(1.0); //sentting volume to 1
  super.initState();
  }

  //Play video
  void playVideo(){
  _controller = VideoPlayerController.network("$dUrl");
  print("$dUrl");
  _initializeVideoPlayerFuture = _controller.initialize();
  _controller.setLooping(false); // iteration false, means once video is stop it'll not start again
  _controller.setVolume(1.0); //volume is 1


  }

    //update video name
  Future updateVideo(name) async {
    DatabaseReference databaseReference;
    FirebaseDatabase.instance.reference().child('Videos') //getting video collection from the firebase realtime database
        .orderByChild('name') //and access name property of  particular record
        .equalTo(name).once() //check whether record's name is equal with user provided name
        .then((onValue) {// if yes
      Map data = onValue.value;
      var key = data.keys; //get the database generated unique key

      print(key);
      String newKey = key.toString(); //assign that key to a variable
      String n = newKey.replaceAll("(", " "); //replacing all the brackts with space
      String newOne = n.replaceAll(")", " ");
      print(newKey);
      print(n);
      print(newOne);
      String newnew = newOne.trim(); //and trim the key in order to remove whitespaces
      print(newnew); //print the key on the debug console
    
          FirebaseDatabase.instance.reference().child("Videos/$newnew").update({ //go to the firebase database with that key and access the name property of it.
              "name" : updateName.text+(" mp4") //update the name with user provided name and then includemp4 format
          });
          setState(() { //setting state variable
           newnew = updateName.text; 
          });
     // databaseReference.remove();      
    });
  }
  @override
  void dispose() {
  _controller.dispose();
  super.dispose();
  }
  @override
  Widget build(BuildContext context) {
  String videoDetails = ModalRoute.of(context).settings.name; //get that name which is passed from the video list and the split all the details to one by one   
  var newUrl = videoDetails.split("#").removeLast(); //getting url from the video details
  var newName = videoDetails.split("#").removeAt(0); //getting name from the video details
   var newDate = videoDetails.split("#").removeAt(1);//getting date from the video details
  var newSize = videoDetails.split("#").removeAt(2); //getting size of the video from the video details

  setState(() {
  dUrl = newUrl;

  });

  //UI part
  return Scaffold(  
  backgroundColor: Colors.grey[800],
  appBar: AppBar(
  title: Text("JoY  BoX ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0,color: Colors.pink[100]),),
  backgroundColor: Colors.grey[800],
  actions: <Widget>[
    FlatButton.icon(onPressed: (){
  Navigator.push( //navigate to the home page
  context,
  MaterialPageRoute(
  builder: (context) => HomePage()),

  );
  }, icon: Icon(Icons.home,color: Colors.pink[100],), label: Text("Home",style: TextStyle(fontSize: 15.0,color: Colors.pink[100]),)),
  FlatButton.icon(onPressed: (){
  Navigator.push( //navigate to the video list page
  context,
  MaterialPageRoute(
  builder: (context) => VideoList()),

  );
  }, icon: Icon(Icons.featured_play_list,color: Colors.pink[100],), label: Text("View List",style: TextStyle(fontSize: 15.0,color: Colors.pink[100]),))
  ],
    ),
  body: SingleChildScrollView(
   child : Column(
  children: <Widget>[
  FutureBuilder(

  future: _initializeVideoPlayerFuture,
  builder: (context, snapshot) {
  if (snapshot.connectionState == ConnectionState.done) {
  // play video inside this
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Center(
    child: Container(
    height: 300,
    width: 400,

    child: AspectRatio( //the ratio of the width and the height of the video screen
    aspectRatio: _controller.value.aspectRatio,
    child: VideoPlayer(_controller),
          ),
      ),
    ),
  );
  } else {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Center(
    child: CircularProgressIndicator(),
        ),
  );
    }
    },
    ),
  FloatingActionButton(    
  backgroundColor: Colors.black,
    
  onPressed: () {
  playVideo(); //play video
  setState(() {
  if (_controller.value.isPlaying) {
  _controller.pause();  //while playing need to pause
  } else {
  _controller.play(); // if stop then need to play the video
  }
  });
  },
  child:
  Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow ), // if playing shows the pause icone otherwise show the play icon

  ),
  SizedBox(height: 20.0,),
  // Divider(color: Colors.transparent,thickness: 1.5,),
 // SizedBox(height: 20.0,),
        Container(
          
          height: 290.0,
          width: 550.0,
          decoration: BoxDecoration(border: Border.all(color: Colors.yellow[800],)),

          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              //showing all the details of the video
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(" JoY                :" , style: TextStyle(fontSize: 15.0, color: Colors.pink[100],fontWeight: FontWeight.bold),),
                    ),
                    SizedBox(width: 100,),
                    Container(
                      //displaying the name of the video
                      child: Text(newName, style: TextStyle(fontSize: 15.0, color: Colors.blue[800],fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
                Divider(height: 40.0,thickness: 1.0,color: Colors.pink[100],),
                Row(
                  children: <Widget>[
                    Container(
                      child: Text("Created          :" , style: TextStyle(fontSize: 15.0, color: Colors.pink[100],fontWeight: FontWeight.bold),),
                    ),
                    SizedBox(width: 100,),
                    Container(
                      //displaying the date of the video
                      child: Text(newDate , style: TextStyle(fontSize: 15.0, color: Colors.blue[800],fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
                Divider(height: 40.0,thickness: 1.0,color: Colors.pink[100],),
                 Row(
                   children: <Widget>[
                     Container(
                      child: Text("Size                 :" , style: TextStyle(fontSize: 15.0, color: Colors.pink[100],fontWeight: FontWeight.bold),),
                    ),
                    SizedBox(width: 100,),
                     Container(
                       //displaying the size of the video
                      child: Text(newSize , style: TextStyle(fontSize: 15.0, color: Colors.blue[800],fontWeight: FontWeight.bold),),
                ),
                   ],
                 ),
                Divider(height: 40.0,thickness: 1.0,color: Colors.pink[100],),
                 Container(
                   //displaying the url of the video
                  child: Text(newUrl , style: TextStyle(fontSize: 13.0, color: Colors.grey[700]),),
                ),
               // SizedBox(height: 10.0,),
                
              ],
              
            ),
            
          ),
          
        ),
        SizedBox(height: 25.0,),
            FlatButton.icon( 
              shape: Border.all(color: Colors.yellow[800]),    
              color: Colors.grey[650],                            
              icon: Icon(Icons.update,color: Colors.pink[100],size: 35.0,),              
              onPressed: (){ //if you want to update. the dialog will be shown. Asking whether you want to update or not.
             showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(                                
                                backgroundColor: Colors.grey[800],
                                title: Text("Update !",style: TextStyle(color: Colors.green[800],fontWeight: FontWeight.bold),),
                                content: TextField(
                                  controller: updateName, //accessing user provided name 
                                  decoration: InputDecoration(
                                    hintText: newName,
                                    focusColor: Colors.pink
                                  ),
                                  
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("Yes", style: TextStyle(color: Colors.pink[100]),),
                                    onPressed: (){
                                      updateVideo(newName); //updating the video name from the provided name
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context){
                                            return AlertDialog(
                                              backgroundColor: Colors.grey[800],
                                              title: Text("Updated !",style: TextStyle(color: Colors.green[800],fontWeight: FontWeight.bold),),
                                              content: Text("Name is updated successfully!",style: TextStyle(color: Colors.pink[100]),),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("Ok", style: TextStyle(color: Colors.blue[800]),),
                                                  onPressed: (){
                                                    Navigator.push( //Once update is done, navigate to the video list page
                                                        context,
                                                        MaterialPageRoute(builder: (context) => VideoList()));
                                                  },
                                                ),

                                              ],
                                            );

                                          }
                                      );
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("No",style: TextStyle(color: Colors.blue[800]),),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );

                            }
                        );              },
              
              label: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(" Update  J o Y",style: TextStyle(color: Colors.pink[100],fontSize: 15.0),),
              ),
            )
  ],
  ),
  )
  );

  }

}