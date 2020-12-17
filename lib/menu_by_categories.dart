import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'crud.dart';
import 'basket.dart';
import 'menu.dart';
import 'product_info.dart';

import 'package:shared_preferences/shared_preferences.dart';

List<order> products = new List<order>();


class menuByCategories extends StatefulWidget {
  List<order> productsBasket = new List<order>();
  int category_id;
  String category_name;


  menuByCategories({this.productsBasket, this.category_id, this.category_name});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _menuByCategories(
        productsBasket: productsBasket,
        category_id: category_id,
        category_name: category_name);
  }
}

class _menuByCategories extends State<menuByCategories> {
  CrudMethods crudMethods = new CrudMethods();
  Stream blogsStream, blogsStream2;
  List<order> productsBasket = new List<order>();
  int category_id;
  String category_name;

  _menuByCategories(
      {this.productsBasket, this.category_id, this.category_name});

  String basketCount(int id) {
    if (productsBasket != null) {
      int i = productsBasket.indexWhere((element) => element.product_id == id);
      print("index ürün id" + i.toString());
      if (i == -1) {
        return "0";
      } else {
        return productsBasket[i].count.toString();
      }
    } else {
      return "0";
    }
  }

  Widget FoodList(int a) {
    return Container(
        child: blogsStream != null
            ? Column(
                children: <Widget>[
                  StreamBuilder(
                    stream: Firestore.instance
                        .collection("products")
                        .where("categoryid", isEqualTo: a)
                        //.orderBy("sorting")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return new Text("Loading");
                      } else {
                        return ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            shrinkWrap: true,

                            itemBuilder: (context, index) {
                              return Column(children: [FoodModelGrid(
                                name:
                                snapshot.data.documents[index].data['name'],
                                title: snapshot
                                    .data.documents[index].data["title"],
                                price: snapshot
                                    .data.documents[index].data['price'],
                                product_id: snapshot
                                    .data.documents[index].data["product_id"],
                                productCountText: basketCount(snapshot
                                    .data.documents[index].data["product_id"]),
                                image_url: snapshot.data.documents[index]
                                    .data["image_url"], //"0",
                              ),Container(margin: EdgeInsets.only(right: 15,left: 15),child: const Divider(
                                color: Colors.grey,
                                height: 10,
                                thickness: 1,
                                indent: 0,
                                endIndent: 0,
                              ),)],);
                            });
                      }
                    },
                  )
                ],
              )
            : Container());
  }

  Widget CategoryList() {
    return Container(
        child: blogsStream != null
            ? Column(
                children: <Widget>[
                  StreamBuilder(
                    stream: blogsStream2,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return new Text("Loading");
                      } else {
                        return ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            shrinkWrap: true,
                            primary: false,
                            itemBuilder: (context, index) {
                              return CategoryModel(
                                category: snapshot
                                    .data.documents[index].data['category'],
                                foodlist: FoodList(snapshot
                                    .data.documents[index].data['categoryid']),
                              );
                            });
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
            .collection("categories")
            .orderBy("categoryid")
            .snapshots();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(category_name),
      ),
      body: Stack(
        children: <Widget>[
          Container(
//            margin: EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height - 130,
                  child: SingleChildScrollView(
                    child: FoodList(category_id),
                  ),
                ),
                Container(
                  height: 70,
                ),
              ],
            ),
          ),
          Container(
            child: Basket(),
          )
        ],
      ),
//      floatingActionButton: Basket(products),
//      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class FoodModelGrid extends StatefulWidget {
  String title, name, productCountText = "0", image_url;
  int price, product_id;

  FoodModelGrid(
      {@required this.name,
      @required this.title,
      @required this.price,
      @required this.product_id,
      @required this.productCountText,
      @required this.image_url});

  @override
  _FoodModelGridState createState() => _FoodModelGridState(
      name, title, price, product_id, productCountText, image_url);
}

class _FoodModelGridState extends State<FoodModelGrid> {
  String title, name, productCountText = "0", image_url,table_=Uri.base.queryParameters['table'];
  int price, product_id, i = 0;



  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String table = prefs.getString('table');
    return table;
  }

  void foo() async {
    table_ = await getStringValuesSF();
    print("tableeee"+table_);
  }

  var countColor = Colors.black45;

  _FoodModelGridState(this.name, this.title, this.price, this.product_id,
      this.productCountText, this.image_url);

  void color(int i) {
    if (i == 0) {
      setState(() {
        countColor = Colors.black45;
      });
    } else {
      setState(() {
        countColor = Colors.black;
      });
    }
  }

  void addProductToBasket(
      int product_id, String product_name, int count, int price) async {
    var documentx = await databaseReference
        .collection("tables")
        .document(table_)
        .collection("basket")
        .document(product_id.toString());

    DocumentSnapshot documentSnapshot = await databaseReference
        .collection("tables")
        .document(table_)
        .collection("basket")
        .document(product_id.toString())
        .get();

    await databaseReference
        .collection("tables")
        .document(table_)
        .collection("basket")
        .document(product_id.toString())
        .setData({
      "name": product_name,
      'count': count,
      "product_id": product_id,
      "price": price
    });

    if (count == 0) {
      await databaseReference
          .collection("tables")
          .document(table_)
          .collection("basket")
          .document(product_id.toString())
          .delete();
    }

//    if (documentSnapshot.exists) {
//      documentx.get().then((DocumentSnapshot) => databaseReference
//          .collection("tables")
//          .document("5")
//          .collection("basket")
//          .document(product_id.toString())
//          .setData({
//        "name": product_name,
//        'count': count + DocumentSnapshot.data['count'],
//        "product_id": product_id,
//        "price": price
//      }));
//    } else {
//      await databaseReference
//          .collection("tables")
//          .document("5")
//          .collection("basket")
//          .document(product_id.toString())
//          .setData({
//        "name": product_name,
//        'count': count,
//        "product_id": product_id,
//        "price": price
//      });
//    }
  }

  @override

  Widget build(BuildContext context) {
    //
    //
    //
    //
    // foo();
    if(table_.toString()=="null"){
      table_="0";
    }
    print("ressim" + image_url);
    if (image_url == null) {
      image_url =
          "https://firebasestorage.googleapis.com/v0/b/menu-app-9fc0e.appspot.com/o/deneme%2Fcartmen.png?alt=media&token=4ab9876b-0005-4df7-a7d0-2d7f96fe0310";
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 200,
              child: Row(
                children: <Widget>[
                  IconButton(
                    color: Colors.black54,
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductInfo(product_id)),
                      );
                    },
                  ),
                  Container(),
                  SizedBox(
                    width: 150,
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            overflow: TextOverflow.fade,
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              margin: EdgeInsets.only(left: 5),
              child: Text(price.toString() + "₺"),
            ),
            Row(
              children: <Widget>[
                Container(
                  height: 40,
                  child: IconButton(
                      color: Color(0x80FF441B),
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          if (i == 0) {
                          } else {
                            i = int.parse(productCountText);
                            i--;
                            productCountText = i.toString();
                            color(i);
                            addProductToBasket(product_id, name, i, price);
//                            for (int x = 0; x < products.length; x++) {
//                              var y = products[x];
//                              if (y.product_id == product_id) {
//                                if (y.count == 0) {
//                                } else if (y.count == 1) {
//                                  products.removeAt(x);
//                                } else {
//                                  y.count--;
//                                }
//                              }
//                            }
                          }
                        });
                      }),
                ),
                Container(
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection("tables")
                        .document(table_)
                        .collection("basket")
                        .where("product_id", isEqualTo: product_id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      print("dsadsadasdsa"+table_);
                      if (!snapshot.hasData) {
                        productCountText = "0";
                        return Text(
                          productCountText,
                          style: TextStyle(color: countColor),
                        );
                      } else {
                        if (snapshot.data.documents.length == 1) {
                          productCountText = snapshot
                              .data.documents[0].data["count"]
                              .toString();
                          return Text(
                            productCountText,
                            style: TextStyle(color: countColor),
                          );
                        } else {
                          return Text(
                            productCountText,
                            style: TextStyle(color: countColor),
                          );
                        }
                      }
                    },
                  ),
                ),
                Container(
                  child: Container(
                    height: 40,
                    child: IconButton(
                        color: Color(0x802FC62A),
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
//                            i++;
//                            productCountText = i.toString();
                            i = int.parse(productCountText);
                            i++;
                            productCountText = i.toString();
                            color(i);
                            addProductToBasket(product_id, name, i, price);

//                            int product_id_control = 0;
//                            for (int x = 0; x < products.length; x++) {
//                              var y = products[x];
//                              if (y.product_id == product_id) {
//                                product_id_control = 1;
//                              }
//                            }
//                            if (product_id_control == 0) {
//                              print("yeni ekle");
//                              var order_product = new order();
//
//                              setState(() {
//                                order_product.product_id = product_id;
//                                order_product.product_name = name;
//                                order_product.product_title = title;
//                                order_product.product_price = price;
//                                order_product.count = i;
//                                products.add(order_product);
//                                addProductToBasket(product_id, name, i, price);
//                              });
//                            }
//                            for (int x = 0; x < products.length; x++) {
//                              var y = products[x];
//                              if (y.product_id == product_id) {
//                                setState(() {
//                                  y.count = i;
//                                  print("var");
//                                });
//                              }
//                            }
                          });
                        }),
                  ),
                ),
              ],
            ),
          ],
        ),

      ],
    );
  }
}
