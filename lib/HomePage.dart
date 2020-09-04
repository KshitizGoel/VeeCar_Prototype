import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import "Posts.dart";
import "package:url_launcher/url_launcher.dart";
import 'newScreen.dart';


class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return HomePageState();
  }
}

class HomePageState extends State<HomePage>{
  String phoneNumberCalling ;

  DatabaseReference ref = FirebaseDatabase.instance.reference().child("Details") ;
  List <Posts> postsList = [];
  TextEditingController carNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Prototype VeeCar app"),
        centerTitle: true,
      ),

      body: Form(

        child: ListView(

          padding: EdgeInsets.all(30.0),
          
          children: <Widget>[

            Padding(
              padding: EdgeInsets.all(15.0),
              child: ButtonTheme(

                height: 50.0,

                child: RaisedButton(

                  child: Column(

                    children: <Widget>[

                      Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                      ),
                      Text(
                        "Take a photo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ]

                  ),

                  onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                    builder:(context) =>NewScreen(),

                    ),);
                  },

                ),

              ),
            ),

            Padding(
              padding: EdgeInsets.all(15.0),
            child: TextFormField(
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: "Enter the car number",
              ),
              controller: carNumberController,
            ),
            ),

            Padding(
            
              padding: EdgeInsets.all(20.0),
              
            child: ButtonTheme(

              height: 50.0,

           child: RaisedButton(
              color: Colors.deepOrange,

              elevation: 10.0,

              child: Column(

                children: <Widget>[

                  Icon(
                    Icons.search,
                    color: Colors.white,
                  ),

                  Text(
                    "Search ",

                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0
                    ),
                  )
                ],

              ),


              onPressed: (){
                String carNumberInput = carNumberController.text.toString().replaceAll(" ", "");


                ref.orderByChild("carNo").equalTo(carNumberInput).once().then(
                    (DataSnapshot snap){
                          var KEYS = snap.value.keys;
                          var DATA = snap.value;

                          postsList.clear();

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

                          });
                    }
                ),
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

            Padding(

              padding: EdgeInsets.all(20.0),

              child: ButtonTheme(

                height: 50.0,

                child: RaisedButton(
                    color: Colors.deepOrange,

                    elevation: 10.0,

                    child:Column(

                      children:<Widget> [
                        Icon(
                          Icons.call,
                          color: Colors.white,
                        ),



                        Text(
                          "Call",

                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        ),

                      ],
                    ),
                    onPressed: (){
                      call1();
                    }
                ),
              ),
            ),
            Padding(

              padding: EdgeInsets.all(20.0),

              child: ButtonTheme(

                height: 50.0,


                child: RaisedButton(
                    color: Colors.deepOrange,

                    elevation: 10.0,

                    child:Column(

                      children:<Widget> [

                        Icon(
                          Icons.textsms,
                          color: Colors.white,
                        ),
                       Text(
                          "SMS",

                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                      ],
                ),
                    onPressed: (){
                      sms1();
                    }
                )
              ),
            ),

          ],
        ),
      ),
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

  call1(){
    String phoneNo = "tel:" + phoneNumberCalling;
    launch(phoneNo);
  }

  sms1(){
    String sms = "sms: $phoneNumberCalling";
    launch(sms);
  }

}