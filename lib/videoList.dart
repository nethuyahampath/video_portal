
// import all essential packages 
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_portal/homePage.dart';
import 'package:video_portal/video.dart';
import 'package:video_portal/video_player.dart';


class VideoList extends StatefulWidget {

  @override
  _VideoListState createState() => new _VideoListState();
}

class _VideoListState extends State<VideoList> {

  List<Video> videoList = []; //list of videos
  String videoDetails; //details of the video
  String vname; //video name
  
  @override
  void initState() {
    super.initState();

    //getting all the records from the firebase database
    DatabaseReference videoRef = FirebaseDatabase.instance.reference().child("Videos");
    videoRef.once().then((DataSnapshot snap){
      var KEYS = snap.value.keys;
      var DATA = snap.value;

      videoList.clear();

      for(var individualKey in KEYS){
        Video video = new Video( //create a video of Video type
        //getting all the values from the records
            DATA[individualKey]['name'],
            DATA[individualKey]['url'],
            DATA[individualKey]['videoDate'],
            DATA[individualKey]['size']
        );
        videoList.add(video);
      }

      setState(() {
        print('Length : $videoList.length');
        
      });
    });
  }
 

  //Go to video app page with the video name and the url
  void gotoSecondScreen(String nameUrl){
    Navigator
        .of(context)
        .push(MaterialPageRoute(builder: (context) => VideoApp(), settings: RouteSettings(name: nameUrl)));

  }

  //Download video from the firebase storage
  videoDownload(url)async{
    print('Download URL $url');
    StorageReference storageReference = FirebaseStorage.instance.ref().child("Videos"); 
    url = await storageReference.getDownloadURL(); //getting video url
  }


//Delete video from the firebase storage and the database
  Future deleteVideo(name,url) async {
    
    FirebaseStorage.instance.ref().child(name).delete(); //delete video from the firebase storage

    DatabaseReference databaseReference;
    FirebaseDatabase.instance.reference().child('Videos')
        .orderByChild('name')
        .equalTo(name).once()
        .then((onValue) {
      Map data = onValue.value;
      var key = data.keys; //getting the unique key of the video that you want to delete

      print(key); //printing the key in the debug console
      String newKey = key.toString();
      String n = newKey.replaceAll("(", " "); 
      String newOne = n.replaceAll(")", " "); //replace all brackets with space
      print(newKey); // get the key which hasn't brackets
      print(n);
      print(newOne); 
      String newnew = newOne.trim(); //trim the key to avoid white spaces
      print(newnew);
      // print(data);
      print("videos/$newKey"); 
      databaseReference =
          FirebaseDatabase.instance.reference().child("Videos/$newnew"); //go to the firebase real time database with that key
       databaseReference.remove(); //remove that particular record
      VideoList(); 
    });
  }

  //ui part 
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Video List",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0,color: Colors.pink[100])),
        backgroundColor: Colors.grey[800],
        actions: <Widget>[

          FlatButton.icon(
            label: Text("Home", style: TextStyle(color: Colors.pink[100],fontWeight: FontWeight.bold,fontSize: 15.0),),
            icon: Icon(Icons.home,color: Colors.pink[100],),
            onPressed: (){
              //navigate to the home page
              Navigator.push(
                    context,
               MaterialPageRoute(builder: (context) => HomePage()));
            },
          )
        ],

      ),
      body: Container(
        decoration: new BoxDecoration(
          image:DecorationImage(
            image: AssetImage("images/back.png"), //setting background image
            fit: BoxFit.fitHeight,
          ),
        ),
        //color: Colors.black,
        //if video length is 0 then prompt a circular progress indicator and if not display the list
        child: videoList.length == 0 ? new LinearProgressIndicator() : new ListView.builder(
          itemCount: videoList.length,
          itemBuilder: (_, index){
            //videoUi is created card widget
            return videosUI(videoList[index].name, videoList[index].url,videoList[index].videoDate,videoList[index].size);

          },
        ),
      ),
    );
  }
//returning all the videos and their details as cards
  Widget videosUI(String name, String url,String vDate, String vSize){
    return new Card( 

        elevation: 10.0,
        margin: EdgeInsets.all(15.0),
        color: Colors.transparent,
        

        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.blue[300],)),
          padding: EdgeInsets.all(14.0),
          child: GestureDetector(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      new Text(
                        name, //video name
                        style: TextStyle(color:Colors.pink[100],fontWeight: FontWeight.bold,fontSize: 15.0),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(width: 300.0,),
                     Text(                                              
                       vDate, //created date
                       style: TextStyle(fontSize: 11.0,color: Colors.pink[100],fontWeight: FontWeight.bold)
                       ,)

                    ],
                  ),

                  Divider(color: Colors.blue[300],thickness: 1.0,),
                  SizedBox(height: 10.0,),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container( 
                          //sixe of the video in MB
                         child: Text(vSize,style: TextStyle(fontSize: 13.0,color: Colors.blue[700],fontWeight: FontWeight.bold),)
                        ),
                      ),
                      Container(
                        width: 350.0,
                        child: new Text(                         
                         url, //url of the video
                          style: TextStyle(color:Colors.transparent,fontSize: 8.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      FlatButton.icon(onPressed: (){                    

                        //prompt dialog box by asking whether you need to delete the video or not?
                        showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(
                                backgroundColor: Colors.grey[800],
                                title: Text("Delete!",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                                content: Text("Do you want to Delete "+name+" video?",style: TextStyle(color: Colors.pink[100]),),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("Yes", style: TextStyle(color: Colors.red),),
                                    onPressed: (){
                                      deleteVideo(name,url); //deleting video from the firebase datbase and the storage
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context){
                                            return AlertDialog(
                                              backgroundColor: Colors.grey[800],
                                              title: Text("Deleted!",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                                              content: Text("Video "+name+" is deleted?",style: TextStyle(color: Colors.pink[100]),),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("Ok", style: TextStyle(color: Colors.red),),
                                                  onPressed: (){
                                                    //Once deleting is successfull it is navigate to the video list page
                                                    Navigator.push(
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
                                      //prompting the existing page
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );

                            }
                        );

                      },
                          icon: Icon(Icons.delete,color: Colors.red,), label: Text("Delete",style: TextStyle(color:
                          Colors.red,fontWeight: FontWeight.bold),)),
                    ],
                  ),

                 // SizedBox(height: 10.0,),
                ],

              ),
              //Once you tap on the card it'll redirect to the download and go to player
              onTap: (){
                videoDetails = ("$name#$vDate#$vSize#$url");                
                //videoDownload(url);
                gotoSecondScreen(videoDetails); //go to the video app page with video name,url,date and the size
               


              }
          ),
        )
    );
  }
}
