//importing all the essential packages
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

import 'package:video_portal/videoList.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {


  //define state variables
  File _videoFile;
  Random random = new Random();
  StorageReference _storageReference;
  bool _uploaded = false;
  String _name;
  String _downloadUrl;
  String createdDate;
  String fileSize;

  //Create video 
  Future createVideo()async{
    bool stop = false;
    final String fileName = Random().nextInt(1000).toString()+' mp4'; //generate random video name with mp4 format
    _storageReference = FirebaseStorage.instance.ref().child(fileName);
    File video;

    video = await ImagePicker.pickVideo(source: ImageSource.camera,); //get video from the device camera
    int s = video.lengthSync(); //get the length of the video
    double firstVal = (s/1024);
    double secondVal = (firstVal/1024); // generate video size in MB
    String newMb = secondVal.toStringAsFixed(2)+(' MB');

      setState(() { //set new generated values to the state variables
        _videoFile = video;
        _name = fileName;
        fileSize = newMb;
        print("Created!");
      });
  }

  //upload created video to the firebase storage
  Future uploadVideo() async{
    StorageUploadTask uploadTask = _storageReference.putFile(_videoFile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete; 
    var downloadUrlAddress =  await(await uploadTask.onComplete).ref.getDownloadURL(); //once uploading process is completed get the video's url to a variable
    setState(() { //set state values
      _downloadUrl = downloadUrlAddress.toString();
      print("upload completed $_downloadUrl");
      _uploaded = true;

    });
  }

  //getting creating date
    getDate(){
    String currentDate = DateTime.now().toString();
    String newDate =  currentDate.split(".").removeAt(0); //remove last section which begins with .
    print(newDate);
    setState(() { //set newDate to the createdDate
     createdDate = newDate; 
    });
  }

  //Write that create video data to the firebase real time database
   writeDataToTheDatabase()async{
     final DatabaseReference databaseReference = await  FirebaseDatabase.instance.reference().child("Videos"); //collection name is Videos
    await databaseReference.push().set({ //create the record
       'name': _name,
       'url' : _downloadUrl,
       'videoDate': createdDate,
       'size': fileSize
     });
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Home",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0,color: Colors.pink[100]),),
        backgroundColor: Colors.grey[800],
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.settings),textColor: Colors.pink[100],
            onPressed: (){},
            label: Text("Setting"),

          )
        ],
      ),
      body: Column(

        children: <Widget>[

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(child: Text("J o Y_______", style: TextStyle(color: Colors.blue[800],fontSize: 60.0),)),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(child: Text("       B o X______", style: TextStyle(color: Colors.pink[100],fontSize: 60.0),)),
              ),
              SizedBox(height: 40.0,),
              Divider(color: Colors.pink[100], thickness: 0.6,),
              SizedBox(height: 80.0,),

          Center(
            child: Container(
              height: 50.0,
              width: 200,
              child: OutlineButton(

                borderSide: BorderSide(color: Colors.blue[800],style: BorderStyle.solid,width: 3.0),

                child: Text("Create A JoY!",style: TextStyle(fontSize: 18.0,color: Colors.blue[800]),),
                onPressed: () {
                  //Opening camera and recording the video
                 
                  createVideo(); //Video is recording 
                  
                  //after recorded, navigate to the home page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage()),

                  );

                  // show dialog box by asking, that need to save the video or not
                    showDialog(context: context, builder: (context) {
                      return Dialog(shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)
                      ),
                        child: Container(
                          color: Colors.grey[800],
                          height: 200.0,
                          width: 150,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[

                              Text("Do you want to keep this video?",style: TextStyle(color: Colors.blue[800],
                              fontSize: 20.0,fontWeight: FontWeight.bold),),
                                
                              SizedBox(height: 20,),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: <Widget>[
                                      RaisedButton(
                                        color: Colors.cyan,
                                        child: Text("Yes", style: TextStyle(
                                            color: Colors.white
                                        ),
                                        ),
                                          onPressed: () {
                                           
                                          //SpinKitWave( color: Colors.white, type: SpinKitWaveType.start);
                                          Navigator.of(context).pop();                                         
                                          getDate(); //gretting current date. By calling the method
                                            
                                            
                                            //displaying a toast, while it is uploading to the firebase storage
                                          Toast.show("Your video is uploading... This will take some time...", context, duration: 45, gravity:  Toast.BOTTOM,backgroundColor: Colors.grey[800],textColor: Colors.blueAccent);
                                         
                                         //Once uploading is completed. It'll write data to the firebase real time database
                                          uploadVideo().whenComplete(writeDataToTheDatabase);
                                        },
                                        //),
                                      ),
                                      Container(width: 30,),
                                      RaisedButton(
                                        color: Colors.red,
                                        child: Text("No", style: TextStyle(
                                            color: Colors.white
                                        ),
                                        ),
                                        onPressed: () {
                                          //if user didn't want to save the video. It will navigate to the home page. Without uploading
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => HomePage()),

                                          );
                                        },

                                        // ),
                                      ),
                                    ],
                                  ),
                                ),


                              ],
                            ),
                          ),
                        ),
                      );
                    });
    
                },
              ),
            ),
          ),
              SizedBox(height: 50.0,),
              Center(
                child: Container(
                  height: 50.0,
                  width: 200,
                  child: OutlineButton(

                    borderSide: BorderSide(color: Colors.blue[800],style: BorderStyle.solid,width: 3.0),

                    child: Text("View JoY BoX",style: TextStyle(fontSize: 18.0,color: Colors.blue[800]),),
                    onPressed: (){
                      //Navigate to the video list and show all the created videos
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VideoList()),
                      );
                    },
                  ),
                ),
              ),

              Container(
                height: 200.0,
                width: 600.0,
                decoration: new BoxDecoration(
                  image:DecorationImage(
                    //setting background image
                    image: AssetImage("images/light.png"),
                    fit: BoxFit.fill,
                  ),
                ),

              )

        ],
      ),
    );

  }




}
