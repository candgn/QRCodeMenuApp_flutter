import 'package:flutter/material.dart';
import 'crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'basket.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'product_info.dart';
import 'dart:convert';

class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.black, accentColor: Colors.red),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text("Bekleyenler"),
                ),
                Tab(
                  child: Text("Adisyon"),
                )
              ],
            ),
            title: Text("Siparişlerim"),
          ),
          body: TabBarView(
            children: [
              WaitingOrders(),
              DeliveredOrders(),
            ],
          ),
        ),
      ),
    );
  }
}

class WaitingOrders extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WaitingOrders();
  }
}

class _WaitingOrders extends State<WaitingOrders> {
  CrudMethods crudMethods = new CrudMethods();
  Stream blogsStream, blogsStream2;

  Widget CategoryList() {
    return Container(
        child: blogsStream2 != null
            ? Column(
                children: <Widget>[
                  StreamBuilder(
                    stream: blogsStream2,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return new Text("Loading");
                      } else {
                        if (snapshot.data.documents.length == 0) {
                          return Text("Bekleyen siparişiniz bulunmamakta!");
                        } else {
                          return ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              shrinkWrap: true,
                              primary: false,
                              itemBuilder: (context, index) {
                                return WaitingOrderModel(
                                    product_name: snapshot
                                        .data.documents[index].data["name"],
                                    count: snapshot
                                        .data.documents[index].data["count"]);
                              });
                        }
                      }
                    },
                  )
                ],
              )
            : Container());
  }

  @override
  void initState() {
    crudMethods.getData().then((result) {
      setState(() {
        blogsStream = Firestore.instance.collection("products").snapshots();
        blogsStream2 = Firestore.instance
            .collection("tables")
            .document(Uri.base.queryParameters['table'])
            .collection("waiting_orders")
            .snapshots();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 20, top: 15),
            child: SingleChildScrollView(
              child: CategoryList(),
            ),
          ),
        ],
      ),
//      floatingActionButton: Basket(products),
//      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class WaitingOrderModel extends StatelessWidget {
  String product_name;
  int count;

  WaitingOrderModel({
    @required this.product_name,
    @required this.count,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            alignment: Alignment.centerLeft,
            child: SizedBox(width: 350,child:Row(children: [ Flexible(
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 250,
                      child: Text(
                        product_name,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Text(":"),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      width: 50,
                      child: Text(count.toString(),
                          style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    )
                  ],
                ))],),)),
        Divider(
          color: Colors.black54,
          thickness: 1,
        ),
      ],
    );
  }
}

class DeliveredOrders extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DeliveredOrders();
  }
}

class _DeliveredOrders extends State<DeliveredOrders> {
  CrudMethods crudMethods = new CrudMethods();
  Stream blogsStream, blogsStream2;
  List<int> totalpriceList = new List<int>();

  Widget DeliveredOrdersList() {
    return Container(
        child: blogsStream2 != null
            ? Column(
                children: <Widget>[
                  StreamBuilder(
                    stream: blogsStream2,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return new Text("Yükleniyor...");
                      } else {
                        return Column(
                          children: <Widget>[
                            ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                shrinkWrap: true,
                                primary: false,
                                itemBuilder: (context, index) {
                                  return DeliveredOrdersModel(
                                    product_name: snapshot
                                        .data.documents[index].data["name"],
                                    count: snapshot
                                        .data.documents[index].data["count"],
                                    price: snapshot
                                        .data.documents[index].data["price"],
                                  );
                                }),
                            Divider(thickness: 1,color: Colors.black,),
                            new StreamBuilder(
                                stream: Firestore.instance
                                    .collection("tables")
                                    .document(Uri.base.queryParameters['table'])
                                    .collection("delivered_orders")
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return new Text("Loading...");
                                  } else {
                                    int totprice = 0;
                                    for (int i = 0;
                                        i < snapshot.data.documents.length;
                                        i++) {
                                      totprice = totprice +
                                          snapshot.data.documents[i]
                                                  .data["count"] *
                                              snapshot.data.documents[i]
                                                  .data["price"];
                                    }
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          width: 200,
                                          child: Text("Hesap ",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
                                        ),
                                        Text(":"),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(totprice.toString()+"₺",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    );
                                  }
                                })
                          ],
                        );
                      }
                    },
                  )
                ],
              )
            : Container());
  }

  @override
  void initState() {
    crudMethods.getData().then((result) {
      setState(() {
        blogsStream = Firestore.instance.collection("products").snapshots();
        blogsStream2 = Firestore.instance
            .collection("tables")
            .document(Uri.base.queryParameters['table'])
            .collection("delivered_orders")
            .snapshots();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 20, top: 15),
              child: Column(
                children: <Widget>[
                  SingleChildScrollView(
                    child: DeliveredOrdersList(),
                  ),
                  Divider(),
                  Row(
                    children: <Widget>[Text("")],
                  )
                ],
              )),
        ],
      ),
//      floatingActionButton: Basket(products),
//      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class DeliveredOrdersModel extends StatelessWidget {
  String product_name;
  int count;
  int price;

  DeliveredOrdersModel({
    @required this.product_name,
    @required this.count,
    @required this.price,
  });

  int calculatePrice(int x, int y) {
    return x * y;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            alignment: Alignment.centerLeft,
            child: SizedBox(width: 400,child:Row(children: [ Flexible(
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 200,
                      child: Text(
                        product_name,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Text(":"),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      width: 150,
                      child: Text(
                          count.toString() +
                              " * " +
                              price.toString() +
                              "₺" +
                              " = " +
                              calculatePrice(count, price).toString() +
                              "₺",
                          style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    )
                  ],
                ))],),)),
        Divider(
          color: Colors.black45,
          thickness: 1,
        ),
      ],
    );
  }
}
