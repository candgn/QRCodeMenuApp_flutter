import 'package:flutter/material.dart';
import 'crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestoreInstance = Firestore.instance;

class productInfoClass {
  int product_id;
  int product_price;
  String product_name;
  String product_title;
  String product_review;
}

class ProductInfo extends StatefulWidget {
  int product_id;

  ProductInfo(this.product_id);

  @override
  _ProductInfoState createState() => _ProductInfoState(product_id);
}

class _ProductInfoState extends State<ProductInfo> {
  int product_id;

  _ProductInfoState(this.product_id);

  Widget productInfoTexta() {
    var product_info = new productInfoClass();
    product_info.product_id = product_id;

    firestoreInstance
        .collection("products")
        .where("product_id", isEqualTo: product_id)
        .getDocuments()
        .then((value) {
      value.documents.forEach((result) {
        return Container(
          child: Text(result.data["name"]),
        );
//          product_info.product_name=
//          print("içerisi"+product_info.product_name);
      });
    });
  }

  Widget productInfoTexts(int a) {
    return Container(
        child: Column(
      children: <Widget>[
        StreamBuilder(
          stream: Firestore.instance
              .collection("products")
              .where("product_id", isEqualTo: a)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return new Text("Loading");
            } else {
              print("dsafsafsafs" + snapshot.data["name"]);
              return Text("fdsfds");
            }
          },
        )
      ],
    ));
  }

  Widget productInfoText(int a) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection("products")
            .where("product_id", isEqualTo: a)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text("Loading");
          }
          var userDocument = snapshot.data.documents[0];
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 50, right: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        userDocument["name"],
                        overflow: TextOverflow.fade,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Text(
                      userDocument["price"].toString() + "₺",
                      style: TextStyle(fontSize: 24),
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 20, left: 50, right: 50),
                child: Text(
                  userDocument["review"],
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Container(
          height: 300,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 40),
          color: Colors.black87,
          child: Container(
            padding: EdgeInsets.all(10),
            child:
                Image(image: AssetImage("assets/carousel_images/yemek1.jpg")),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height - 300,
          width: MediaQuery.of(context).size.width,
          color: Colors.amber,
          child: Container(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 30),
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width,
                  child: productInfoText(product_id),
                ),
                  //ürün ekle çıkar
//                new Positioned(
//                    child: new Align(
//                        alignment: FractionalOffset.bottomCenter,
//                        child: Container(
//                          padding: EdgeInsets.only(bottom: 40),
//                          child: Row(
//                            mainAxisAlignment: MainAxisAlignment.center,
//                            children: <Widget>[
//                              IconButton(
//                                iconSize: 50.0,
//                                icon: Icon(Icons.add_circle_outline),
//                              ),
//                              Text(
//                                "0",
//                                style: TextStyle(fontSize: 24),
//                              ),
//                              IconButton(
//                                iconSize: 50.0,
//                                icon: Icon(Icons.remove_circle_outline),
//                              ),
//                            ],
//                          ),
//                        ))),
              ],
            ),
          ),
        )
      ],
    ));
  }
}
