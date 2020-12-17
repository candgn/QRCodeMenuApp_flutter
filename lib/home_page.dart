import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'menu.dart';
import 'basket.dart';
import 'orders_page.dart';
import 'crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'categories_page.dart';
import 'comments_suggestions.dart';
import 'dart:html';
import 'package:shared_preferences/shared_preferences.dart';
final databaseReference = Firestore.instance;




class Home extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {


    // TODO: implement createState
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  var callWaitressColor = Colors.black;
  String table_=Uri.base.queryParameters['table'];

  addStringToSF() async {
    String table=Uri.base.queryParameters['table'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("dsadsadsfds" + table.toString());
    if(table.toString()=="null"){
      table="0";
    }
    prefs.setString('table', table);
    table_=table;
  }


  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String table = prefs.getString('table');

    return table;
  }

  void foo() async {
    table_ = await getStringValuesSF();
  }



  List<String> carouselImagePathList = [
    "assets/carousel_images/yemek1.jpg",
    "assets/carousel_images/yemek2.jpg",
    "assets/carousel_images/yemek3.jpg",
    "assets/carousel_images/yemek4.jpg",
  ];



  void callWaitress(bool callWaitressState) async {
    await databaseReference
        .collection("tables")
        .document( await getStringValuesSF())
        .collection("waitress_request")
        .document("state")
        .setData({"state": callWaitressState});
    await databaseReference
        .collection("waitress_request")
        .document(await getStringValuesSF())
        .setData({"state": callWaitressState, "table": await getStringValuesSF()});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
 //   addStringToSF();
//    foo();
    if(table_.toString()=="null"){
      table_="0";
    }

    print("xxxxxxxxxx"+table_.toString());
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Container(width: 50,height: 50,child: Image(
                image: AssetImage("assets/logo/broesel.png"), fit: BoxFit.contain),),
            Container(margin: EdgeInsets.only(left: 15),child: Text("Brösel"),)
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Container(
            child: new Stack(
              //alignment:new Alignment(x, y)
              children: <Widget>[
                new Positioned(
                  child: Column(
                    children: <Widget>[
//                      Container(
//                          margin: EdgeInsets.only(top: 35.0),
//                          child: Row(
//                            children: <Widget>[
//                              Container(
//                                  margin:
//                                      EdgeInsets.only(left: 25.0, right: 25.0),
//                                  width: 50,
//                                  child: Image(
//                                    image:
//                                        AssetImage("assets/logo/broesel.jpg"),
//                                  )),
//                              Text("Brösel Foods"),
//                            ],
//                          )),
//                      const Divider(
//                        color: Colors.grey,
//                        height: 20,
//                        thickness: 1,
//                        indent: 0,
//                        endIndent: 0,
//                      ),
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        child: CarouselSlider(
                          options: CarouselOptions(height: 230.0),
                          items: carouselImagePathList.map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Container(
                                      child: Image(image: AssetImage(i)),
                                    ));
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const Divider(
                        color: Colors.grey,
                        height: 20,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                      Container(
                          child: IntrinsicHeight(
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              width: 150,
                              child: RawMaterialButton(
                                  fillColor: Colors.black,
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(30.0),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Categories()),
                                    );
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        height: 50,
                                        child: Image(
                                          image: AssetImage(
                                              "assets/buttons/menu_white.png"),
                                        ),
                                      ),
                                      Text(
                                        "Menü",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  )),
                            ),
                            VerticalDivider(
                              color: Colors.grey,
                              thickness: 1,
                              indent: 0,
                              endIndent: 0,
                            ),
                            new StreamBuilder(
                                stream: Firestore.instance
                                    .collection("waitress_request")
                                    .document(table_)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return RawMaterialButton(
                                        fillColor: callWaitressColor,
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(30.0),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              height: 50,
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/buttons/waiter_white.png"),
                                              ),
                                            ),
                                            Text("Garson Çağır",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ],
                                        ));
                                  } else {
                                    String waitressStateText;
                                    bool waitresState =
                                        snapshot.data.data["state"];
                                    if (waitresState == true) {
                                      callWaitressColor = Colors.orange;
                                      waitressStateText = " Yolda";
                                    } else {
                                      callWaitressColor = Colors.black;
                                      waitressStateText = " Çağır";
                                    }

                                    return Container(
                                      width: 150,
                                      child: RawMaterialButton(
                                          fillColor: callWaitressColor,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(30.0),
                                          onPressed: () {
                                            if (waitresState == false) {
                                              callWaitress(true);
                                              callWaitressColor = Colors.orange;
                                            } else {
                                              callWaitress(false);
                                              callWaitressColor = Colors.black;
                                            }

                                            setState(() {});
                                          },
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                height: 50,
                                                child: Image(
                                                  image: AssetImage(
                                                      "assets/buttons/waiter_white.png"),
                                                ),
                                              ),
                                              Text("Garson" + waitressStateText,
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          )),
                                    );
                                  }
                                }),
                          ],
                        ),
                      )),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                      Container(
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                width: 150,
                                child: RawMaterialButton(
                                    fillColor: Colors.black,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(30.0),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => OrdersPage()),
                                      );
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          height: 50,
                                          child: Image(
                                            image: AssetImage(
                                                "assets/buttons/order.png"),
                                          ),
                                        ),
                                        Text(
                                          "Siparişlerim",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    )),
                              ),
                              VerticalDivider(
                                color: Colors.grey,
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                              ),
                              Container(
                                width: 150,
                                child: RawMaterialButton(
                                    fillColor: Colors.black,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(30.0),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Comment()),
                                      );
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          height: 50,
                                          child: Image(
                                            image: AssetImage(
                                                "assets/buttons/complaint.png"),
                                          ),
                                        ),
                                        Text("Şikayet/Öneri",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
