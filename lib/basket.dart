import 'package:flutter/material.dart';
import 'menu.dart';
import 'crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'product_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

final databaseReference = Firestore.instance;

class Basket extends StatefulWidget {
  List<order> products = new List<order>();



  @override
  _BasketState createState() => _BasketState();
}

class _BasketState extends State<Basket> {
  List<order> products = new List<order>();
  String sepet = "",table_=Uri.base.queryParameters['table'];


  int count = 0;
  int countToDisplay = 0;
  bool _visible = false,
      _visibleOrder = false,
      _visibleOrderTaken = false,
      _visibleBasket = true;
  var basketColor = Colors.red;

  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String table = prefs.getString('table');
    return table;
  }

  void foo() async {
    table_ = await getStringValuesSF();
  }

  Widget FoodListBasket() {
    return Container(
        child: Firestore.instance.collection("products").snapshots() != null
            ? Column(
                children: <Widget>[
                  StreamBuilder(
                    stream: Firestore.instance
                        .collection("tables")
                        .document(table_)
                        .collection("basket")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return new Text("Loading");
                      } else {
                        if (snapshot.data.documents.length > 0) {
                          sepet = "";
                          products.clear();
                          int totprice = 0;
                          for (int i = 0;
                              i < snapshot.data.documents.length;
                              i++) {
                            totprice = totprice +
                                snapshot.data.documents[i].data["count"] *
                                    snapshot.data.documents[i].data["price"];
                          }
                          return Column(
                            children: [
                              Container(height:270,child: ListView.builder(
                                  itemCount: snapshot.data.documents.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    var order_product = new order();
                                    order_product.product_id = snapshot.data
                                        .documents[index].data["product_id"];
                                    order_product.product_name = snapshot
                                        .data.documents[index].data['name'];
                                    order_product.product_price = snapshot
                                        .data.documents[index].data['price'];
                                    order_product.count = snapshot
                                        .data.documents[index].data["count"];
                                    products.add(order_product);
                                    return FoodModelBasket(
                                      name: snapshot
                                          .data.documents[index].data['name'],
                                      price: snapshot
                                          .data.documents[index].data['price'],
                                      product_id: snapshot.data.documents[index]
                                          .data["product_id"],
                                      productCountText: snapshot
                                          .data.documents[index].data["count"]
                                          .toString(),
                                      key: UniqueKey(), //"0",
                                    );
                                  }),),
                              Text(
                                "Toplam: " + totprice.toString()+"₺",
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          );
                        } else {
                          sepet = "Sepette ürün yok!";
                          return Container(
                            margin: EdgeInsets.only(top: 15),
                            child: Text(
                              sepet,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                      }
                    },
                  )
                ],
              )
            : Container());
  }

  Widget foodList(List<order> products) {
    if (products.length == 0) {
      return Container(
        margin: EdgeInsets.only(top: 15),
        child: Text(
          "Sepette ürün yok!",
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      print("dsadad");

      return Expanded(
        child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return FoodModelBasket(
                name: products[index].product_name,
                title: products[index].product_title,
                price: products[index].product_price,
                product_id: products[index].product_id,
                productCountText: products[index].count.toString(),
              );
            }),
      );
    }
  }

  void _toggle() {
    setState(() {
      _visible = !_visible;
    });
  }

  bool visiblityOnay(bool x, bool y) {
    if (x == true && y == false) {
      return true;
    } else {
      return false;
    }
  }

  void _togglevisibleOrderTaken() {
    setState(() {
      _visibleOrderTaken = !_visibleOrderTaken;
    });
  }

  void _toggleOrder() {
    setState(() {
      _visibleOrder = !_visibleOrder;
    });
  }

  void _toggleBasketColor() {
    if (basketColor == Colors.red) {
      setState(() {
        basketColor = Colors.green;
      });
    } else {
      setState(() {
        basketColor = Colors.red;
      });
    }
  }

  void _order() {
    var uuid = Uuid().v4().toString();
    List<int> products_order_id = new List<int>();
    for (int i = 0; i < products.length; i++) {
      createRecord(products[i].product_id, products[i].product_name,
          products[i].count, products[i].product_price, uuid);
    }
    print(products_order_id);

    deleteBasket();
  }

  String productsText(List<order> products) {
    String productsString = "";
    for (int i = 0; i < products.length; i++) {
      productsString = productsString +
          products[i].product_name.toString() +
          ":" +
          products[i].count.toString() +
          ",";
    }
    return productsString;
  }

  Widget ProductCheckList(List<order> products) {
    return ListView.builder(
        itemCount: products.length,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 200,
                  child: Text(products[index].product_name.toString()),
                ),
                Text(":"),
                Container(
                  margin: EdgeInsets.only(left: 15),
                  width: 50,
                  child: Text(
                    products[index].count.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          );
        });
  }

  void createRecord(int product_id, String product_name, int count, int price,
      String uuid) async {
    var documentx = await databaseReference
        .collection("tables")
        .document(table_)
        .collection("waiting_orders")
        .document(product_id.toString());

    DocumentSnapshot documentSnapshot = await databaseReference
        .collection("tables")
        .document(table_)
        .collection("waiting_orders")
        .document(product_id.toString())
        .get();
    if (documentSnapshot.exists) {
      documentx.get().then((DocumentSnapshot) => databaseReference
              .collection("tables")
              .document(table_)
              .collection("waiting_orders")
              .document(product_id.toString())
              .setData({
            "name": product_name,
            'count': count + DocumentSnapshot.data['count'],
            "product_id": product_id,
            "price": price
          }));
    } else {
      await databaseReference
          .collection("tables")
          .document(table_)
          .collection("waiting_orders")
          .document(product_id.toString())
          .setData({
        "name": product_name,
        'count': count,
        "product_id": product_id,
        "price": price
      });
    }

    await databaseReference
        .collection("order_waiting_tables")
        .document(table_)
        .setData({"table": table_});
  }

  void deleteBasket() async {


    await databaseReference
        .collection("tables")
        .document(table_)
        .collection("basket")
        .getDocuments().then((value){
      for (DocumentSnapshot ds in value.documents){
        ds.reference.delete();
      }

    });

  }

  _BasketState();

  @override
  Widget build(BuildContext context) {
   // foo();
    if(table_.toString()=="null"){
      table_="0";
    }

    int _countx = 0;

    for (int x = 0; x < products.length; x++) {
      print("Product id: " +
          products[x].product_id.toString() +
          "Count: " +
          products[x].count.toString());
      _countx = _countx + products[x].count;
    }

    return new Positioned(
      child: new Align(
          alignment: FractionalOffset.bottomCenter,
          child: Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: Stack(
                children: <Widget>[
                  Visibility(
                    visible: _visible,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black26,
                    ),
                  ),
                  Visibility(
                    visible: _visibleOrderTaken,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black26,
                    ),
                  ),
                  new Positioned(
                    child: Visibility(
                        visible: _visible,
                        child: new Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: Container(
                              color: Colors.black,
                              height: 400,
                              width: 350,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "SEPETİM",
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          alignment: FractionalOffset.topRight,
                                          child: IconButton(
                                            icon: Icon(Icons.close),
                                            onPressed: () {
                                              _toggle();
                                              _toggleBasketColor();
                                            },
                                          ),

//                            onPressed: (){
//                              Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (context) => Menu(productsBasket: products,)),
//                              );
//                            },
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(child: FoodListBasket()),
                                ],
                              )),
                        )),
                  ),
                  Visibility(
                    visible: _visibleOrder,
                    child: new Positioned(
                        child: new Align(
                      alignment: FractionalOffset.center,
                      child: Container(
                          color: Colors.white,
                          height: 400,
                          width: 350,
                          child: Column(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: Text(
                                      "Ürünler",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    width: 300,
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Container(
                                    height: 166,
                                    width: 350,
                                    child: SingleChildScrollView(
                                      child: ProductCheckList(products),
                                    ),
                                  ),

//                                  Container(
//                                    margin: EdgeInsets.all(20),
//                                    child: Text(
//                                      "Son bir not bırakmak ister misiniz?",
//                                      style: TextStyle(fontSize: 18),
//                                    ),
//                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 50),
                                    width: 250,
                                    child: TextField(
                                      decoration: InputDecoration(
                                          hintText:
                                              "Son bir not bırakmak ister misiniz?"),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      RawMaterialButton(
                                        padding: EdgeInsets.all(10),
                                        fillColor: Colors.black,
                                        child: Text(
                                          "Siparişi Onayla!",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          _order();
                                          _togglevisibleOrderTaken();

                                          products.clear();
                                          setState(() {
                                            _visible = false;
                                            _visibleOrder = false;
                                            _visibleBasket = false;
                                          });
                                        },
                                      ),
//                                      RawMaterialButton(
//                                        fillColor: Colors.white,
//                                        child: Text("Ürün Eklemeye Devam"),
//                                        onPressed: _toggleOrder,
//                                      )
                                    ],
                                  )
                                ],
                              ),
                            ],
                          )),
                    )),
                  ),
                  Visibility(
                    visible: _visibleOrderTaken,
                    child: new Positioned(
                        child: new Align(
                      alignment: FractionalOffset.center,
                      child: Container(
                          color: Colors.white,
                          height: MediaQuery.of(context).size.height / 3,
                          width: 350,
                          child: Column(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Container(
                                    alignment: FractionalOffset.topRight,
                                    child: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        _togglevisibleOrderTaken();
                                        _visibleBasket = true;
                                      },
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.all(20),
                                    child: Text(
                                      "Siparişiniz alındı :)",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                    )),
                  ),
                  Visibility(
                    visible: _visibleBasket,
                    child: new Positioned(
                        child: new Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Container(
                        child: Container(
                            width: 100,
                            child: RawMaterialButton(
                              fillColor: basketColor,
                              onPressed: () {
                                if (_visible == false) {
                                  _toggle();
                                  _toggleBasketColor();
                                } else {
                                  if (sepet != "Sepette ürün yok!" &&
                                      _visible == true) {
                                    _toggleOrder();
                                    _toggleBasketColor();
                                  }
                                }
                                if (_visibleOrder == true &&
                                    sepet == "Sepette ürün yok!") {
                                  _toggleOrder();
                                  _toggleBasketColor();
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Visibility(
                                      visible: !_visible,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.shopping_basket,
                                            color: Colors.white,
                                          ),
                                          StreamBuilder(
                                            stream: Firestore.instance
                                                .collection("tables")
                                                .document(table_)
                                                .collection("basket")
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return new Text("");
                                              } else {
                                                int x = snapshot
                                                    .data.documents.length;
                                                if (x == 0) {
                                                  return Container(
                                                    height: 0,
                                                    width: 0,
                                                  );
                                                } else {
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5, top: 2),
                                                    child: Text(
                                                      "(" + x.toString() + ")",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                          )
                                        ],
                                      )),
                                  Visibility(
                                    visible:
                                        visiblityOnay(_visible, _visibleOrder),
                                    child: Text(
                                      "Devam",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Visibility(
                                    visible: _visibleOrder,
                                    child: Text("Vazgeç",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                            )),
                      ),
                    )),
                  ),
                ],
              ))),
    );
  }
}

class FoodModelBasket extends StatefulWidget {
  String title, name, productCountText = "0";
  int price, product_id;

  FoodModelBasket(
      {@required this.name,
      @required this.title,
      @required this.price,
      @required this.product_id,
      @required this.productCountText,
      Key key})
      : super(key: key);

  @override
  _FoodModelBasketState createState() =>
      _FoodModelBasketState(name, title, price, product_id, productCountText);
}

class _FoodModelBasketState extends State<FoodModelBasket> {
  String title, name, productCountText = "0",table_=Uri.base.queryParameters['table'];
  int price, product_id, i = 0;



  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String table = prefs.getString('table');
    return table;
  }

  void foo() async {
    table_ = await getStringValuesSF();
  }

  var countColor = Colors.white;

  _FoodModelBasketState(this.name, this.title, this.price, this.product_id,
      this.productCountText);

  void color(int i) {
    if (i == 0) {
      setState(() {
        countColor = Colors.white54;
      });
    } else {
      setState(() {
        countColor = Colors.white;
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
//          .document(table_)
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
//          .document(table_)
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
  //  foo();
    if(table_.toString()=="null"){
      table_="0";
    }

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
                    color: Colors.white54,
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductInfo(product_id)),
                      );
                    },
                  ),
//                  Container(
//                    child: Text(
//                    name,
//                    overflow: TextOverflow.fade,
//                    style: TextStyle(color: Colors.white),),
//
//                  ),
                  SizedBox(
                      width: 150,
                      height: 50,
                      child: Row(
                        children: [
                          Flexible(
                              child: Text(
                            name,
                            overflow: TextOverflow.fade,
                            style: TextStyle(color: Colors.white),
                          ))
                        ],
                      ))
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
                          i = int.parse(productCountText);
                          if (i == 0) {
                          } else if (i == 1) {
                            i--;
                            productCountText = i.toString();
                            color(i);
                            addProductToBasket(product_id, name, i, price);
                          } else {
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
//
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
        Divider(
          color: Colors.white30,
          thickness: 1,
        ),
      ],
    );
  }
}
