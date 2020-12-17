import 'package:flutter/material.dart';
import 'crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'basket.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'product_info.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

List<order> products = new List<order>();
int countToDisplay = 0;

class order {
  String product_name;
  String product_title;
  int product_price;
  int product_id;
  int count;

  order(
      {this.product_id,
      this.product_name,
      this.product_title,
      this.count,
      this.product_price});


}

class Menu extends StatefulWidget {
  List<order> productsBasket = new List<order>();

  Menu({this.productsBasket});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Menu(productsBasket: productsBasket);
  }
}

class _Menu extends State<Menu> {
  CrudMethods crudMethods = new CrudMethods();
  Stream blogsStream, blogsStream2;
  List<order> productsBasket = new List<order>();

  _Menu({this.productsBasket});

  Future<int> counterx(int product_id) async {
    int count;

    var documentx = await databaseReference
        .collection("tables")
        .document("5")
        .collection("waiting_orders")
        .document(product_id.toString());
    return documentx
        .get()
        .then((DocumentSnapshot) => DocumentSnapshot.data['count']);
  }

  Future<int> counter(int product_id) {
    return Firestore.instance
        .collection("tables")
        .document("5")
        .collection("waiting_orders")
        .document(product_id.toString())
        .get()
        .then(
      (value) {
        if (value.data['count'] > 0) {
          print("xxxx" + value.data['count'].toString());
          return value.data['count'];
        } else {
          return 0;
        }
      },
    );
  }

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
//    _SharedPrefFoodModelGet() async {
//      SharedPreferences prefs = await SharedPreferences.getInstance();
//      String getEncodedFoodModel= prefs.getString('encodedFoodModel');
//      return getEncodedFoodModel;
//    }
//
//    int _productCountText(){
//
//
//
//      final List<order> decodedData = order.decodeMusics(_SharedPrefFoodModelGet());
//
//
//
//    }

    return Container(
        child: blogsStream != null
            ? Column(
                children: <Widget>[
                  StreamBuilder(
                    stream: Firestore.instance
                        .collection("products")
                        .where("categoryid", isEqualTo: a)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return new Text("Loading");
                      } else {
                        return ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            shrinkWrap: true,
                            primary: false,
                            itemBuilder: (context, index) {
                              return FoodModel(
                                name:
                                    snapshot.data.documents[index].data['name'],
                                title: snapshot
                                    .data.documents[index].data["title"],
                                price: snapshot
                                    .data.documents[index].data['price'],
                                product_id: snapshot
                                    .data.documents[index].data["product_id"],
                                productCountText: basketCount(snapshot
                                    .data
                                    .documents[index]
                                    .data["product_id"]), //"0",
                              );
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
      body: Stack(
        children: <Widget>[
          Container(
//            margin: EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Container(height: MediaQuery.of(context).size.height-70,
                  child: SingleChildScrollView(
                    child: CategoryList(),
                  ),
                ),
                Container(height: 70,),

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

class FoodModel extends StatefulWidget {
  String title, name, productCountText = "0";
  int price, product_id;

  FoodModel(
      {@required this.name,
      @required this.title,
      @required this.price,
      @required this.product_id,
      @required this.productCountText});

  @override
  _FoodModelState createState() =>
      _FoodModelState(name, title, price, product_id, productCountText);
}

class _FoodModelState extends State<FoodModel> {
  String title, name, productCountText = "0";
  int price, product_id, i = 0;

  var countColor = Colors.black45;

  _FoodModelState(this.name, this.title, this.price, this.product_id,
      this.productCountText);

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
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
                    width: 100,
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
                            for (int x = 0; x < products.length; x++) {
                              var y = products[x];
                              if (y.product_id == product_id) {
                                if (y.count == 0) {
                                } else if (y.count == 1) {
                                  products.removeAt(x);
                                } else {
                                  y.count--;
                                }
                              }
                            }
                          }
                        });
                      }),
                ),
                Container(
                    child: Text(
                  productCountText,
                  style: TextStyle(color: countColor),
                )),
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

                            int product_id_control = 0;
                            for (int x = 0; x < products.length; x++) {
                              var y = products[x];
                              if (y.product_id == product_id) {
                                product_id_control = 1;
                              }
                            }
                            if (product_id_control == 0) {
                              print("yeni ekle");
                              var order_product = new order();

                              setState(() {
                                order_product.product_id = product_id;
                                order_product.product_name = name;
                                order_product.product_title = title;
                                order_product.product_price = price;
                                order_product.count = i;
                                products.add(order_product);
                              });
                            }
                            for (int x = 0; x < products.length; x++) {
                              var y = products[x];
                              if (y.product_id == product_id) {
                                setState(() {
                                  y.count = i;
                                  print("var");
                                });
                              }
                            }
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

//class CategoryModel extends StatelessWidget {
//  String category;
//  Widget foodlist;
//  bool foodListVisibility=false;
//
//  toggleFoodListVisibility(){
//
//    foodListVisibility=!foodListVisibility;
//  }
//
//  CategoryModel({
//    @required this.category,
//    @required this.foodlist,
//  });
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return Column(
//      children: <Widget>[
//        Divider(
//          color: Colors.black26,
//          thickness: 1,
//        ),
//        Container(
//            margin: EdgeInsets.only(left: 10, right: 10),
//            alignment: Alignment.centerLeft,
//            child: SizedBox(
//                width: MediaQuery.of(context).size.width,
//                height: 50,
//                child: Row(
//                  children: [
//                    Flexible(
//                      child: Text(
//                        category,
//                        style: TextStyle(
//                            fontWeight: FontWeight.bold,
//                            fontSize: 18.0,
//                            color: Colors.black87),
//                        overflow: TextOverflow.fade,
//                      ),
//                    ),
//          IconButton(icon: Icon(Icons.arrow_drop_down_circle,),onPressed: toggleFoodListVisibility,),
//
//                  ],
//                ))),
//        Divider(
//          color: Colors.black54,
//          thickness: 2,
//        ),
//        Visibility(child: foodlist,visible: foodListVisibility,)
//
//      ],
//    );
//  }
//}


class CategoryModel extends StatefulWidget {

  String category;
  Widget foodlist;


  CategoryModel({
    @required this.category,
    @required this.foodlist,
  });

  @override
  _CategoryModelState createState() => _CategoryModelState(category:category,foodlist:foodlist);
}

class _CategoryModelState extends State<CategoryModel> {
  String category;
  Widget foodlist;
  bool foodListVisibility=false;
  var arrowicon=Icon(Icons.arrow_drop_down_circle);

  toggleFoodListVisibility(){

    setState(() {
      foodListVisibility=!foodListVisibility;
    });

  }



  _CategoryModelState({
    @required this.category,
    @required this.foodlist,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(
          color: Colors.black26,
          thickness: 1,
        ),
        Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            alignment: Alignment.centerLeft,
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        category,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black87),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    IconButton(icon: Icon(Icons.arrow_drop_down_circle,),onPressed: toggleFoodListVisibility,),

                  ],
                ))),
        Divider(
          color: Colors.black54,
          thickness: 2,
        ),
        Visibility(child: foodlist,visible: foodListVisibility,)

      ],
    );
  }
}

