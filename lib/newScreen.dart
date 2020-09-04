import 'dart:io';
import 'package:image_picker/image_picker.dart';
import "package:flutter/material.dart";
import "package:firebase_ml_vision/firebase_ml_vision.dart";
import 'package:firebase_database/firebase_database.dart';
import 'Posts.dart';

class NewScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
  return NewScreenPage();
  }
}

  class NewScreenPage extends State<NewScreen>{
    final formKey = GlobalKey<FormState> ();

    String phoneNumberCalling;

    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("Details");
    List <Posts> postsList = [];

    var textRecognizedByAI = " ";
    File sampleImage;
    final picker = ImagePicker();

    Future getImage() async {
      final tempImage = await picker.getImage(source: ImageSource.camera);

      setState(() {
        sampleImage =File(tempImage.path);
      });

    }

  Future readText( ) async{

    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(sampleImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await recognizeText.processImage(ourImage);

    for(TextBlock block in visionText.blocks){
      for(TextLine line in block.lines){
        for(TextElement word in line.elements){

        setState(() {
          textRecognizedByAI = textRecognizedByAI  + word.text + " ";
        });
        }
        textRecognizedByAI = textRecognizedByAI + "\n";
      }
    }
    recognizeText.close();
  }

  @override
  Widget build(BuildContext context) {

  return Scaffold(
    key: formKey,

    appBar: AppBar(
      title: Text("Using the AI model"),
      centerTitle: true,
    ),

    body:  ListView(
        padding: EdgeInsets.all(20.0),
        children: <Widget>[

         ButtonTheme(
           
           height: 50.0,
          padding: EdgeInsets.all(15.0),
           
          child: RaisedButton(
            elevation: 10.0,
            child: Column(

              children: <Widget>[

                Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                ),
                Text("Take a Photo",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20.0
                ),),
              ],
            ),

            color: Colors.black,

            onPressed: (){
              getImage();
            },
          ),
         ),

          sampleImage == null? Text(
              " ",
                  )
              :
          enableUpload(),

        ],
      ),
  ) ;
  }

  Widget enableUpload(){
    return Form(
        child: ListView(
          shrinkWrap: true,
      padding: EdgeInsets.all(15.0),

      children: <Widget>[

        Image.file(sampleImage , height: 330.0,width: 660.0),

        Padding(
          padding: EdgeInsets.all(20.0),

          child: ButtonTheme(
            height: 50.0,

            child: RaisedButton(
              elevation: 10.0,

              child: Column(
                children: <Widget>[

                  Icon( Icons.directions_car, color:Colors.white),

                  Text(
                    "Car Number",
                    style: TextStyle(
                        color:Colors.white
                    ),
                  )
                ],
              ),

              onPressed: (){
                readText();
              },

            ),
          ),
        ),

        SizedBox(height: 20.0,),
        textRecognizedByAI==" "?
            Text(
                " ",

              style: TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.bold
              ),
            )
            :
            Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    textRecognizedByAI.toString(),
                  ),
                ),
        
        Padding(
          padding: EdgeInsets.all(15.0),
          
          child: RaisedButton(
            child: Text(
              "Get the details"
            ),
            onPressed: (){
              String carNumberInput = textRecognizedByAI.toString();
              dbRef.orderByChild("carNo").equalTo(carNumberInput).once().then(
                  (DataSnapshot snap){

                    var KEYS = snap.value.keys;
                    var DATA = snap.value;

                    postsList.clear();

                    //This Project is basically a prototype of VeeCar app built for iOS users.

                    for(var individualKey in KEYS){
                      Posts posts = Posts(
                        DATA[individualKey]["carNo"],
                        DATA[individualKey]["flatNo"],
                        DATA[individualKey]["ownerName"],
                        DATA[individualKey]["phoneNo"],
                      );
                      postsList.add(posts);
                    }
                    setState((){
                      this.postsList = postsList;
                    });

                  }
              );
            },

          ),
        ),
        Container(


          child: postsList.length==0? Text(" ") : ListView.builder(
              shrinkWrap: true,

              itemCount: postsList.length,

              itemBuilder:(context,int index){
                return postsUI(postsList[index].carNo, postsList[index].ownerName, postsList[index].flatNo, postsList[index].phoneNo);
              }
          ),

        ),

      ],
        )
    );

  }

    Widget postsUI ( String carNo, String ownerName, int flatNo,  int phoneNo){
      phoneNumberCalling = phoneNo.toString();

      return Card(
        elevation: 20.0,

        margin: EdgeInsets.only(left: 25.0 , right:25.0, top:15.0, bottom:15.0),

        child: Container(
          padding: EdgeInsets.all(20.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:<Widget> [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[

                  Text(
                    carNo,
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    ownerName,
                    style: Theme.of(context).textTheme.subtitle1,

                    textAlign: TextAlign.center,
                  ),

                ],

              ),

              SizedBox(height: 15.0,),
              Text(
                "Flat Number:  ${flatNo.toString()}"  ,
                style: Theme.of(context).textTheme.subtitle2,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 15.0,),
              Text(
                "Contact Number:  ${phoneNo.toString()}"  ,
                style: Theme.of(context).textTheme.subtitle2,
                textAlign: TextAlign.center,
              ),


            ],
          ),
        ),


      );

    }


  }