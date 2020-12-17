import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_by_categories.dart';
import 'basket.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(240, 240, 240, 1),
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Kategoriler"),
        ),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: StreamBuilder(
                  stream:
                      Firestore.instance.collection("categories").orderBy("sorting").snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return new Text("Loading");
                    } else {
                      return GridView.builder(
                          itemCount: snapshot.data.documents.length,
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio:
                                MediaQuery.of(context).size.width /
                                    (MediaQuery.of(context).size.height *5/6),
                          ),
                          itemBuilder: (context, index) {
                            return categoryModel(
                              category_id: snapshot
                                  .data.documents[index].data['categoryid'],
                              category_name: snapshot
                                  .data.documents[index].data['category'],
                              image_url: snapshot
                                  .data.documents[index].data['image_url'],
                            );
                          });
                    }
                  },
                ),
              ),
            ),
            Container(
              child: Basket(),
            )
          ],
        ));
  }
}

class categoryModel extends StatefulWidget {
  int category_id;
  String category_name, image_url;

  categoryModel({
    @required this.category_id,
    @required this.category_name,
    @required this.image_url,
  });

  @override
  _categoryModelState createState() => _categoryModelState(
      category_id: category_id,
      category_name: category_name,
      image_url: image_url);
}

class _categoryModelState extends State<categoryModel> {
  int category_id;
  String category_name, image_url;

  _categoryModelState({
    @required this.category_id,
    @required this.category_name,
    @required this.image_url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: GestureDetector(
          child: Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      color: Colors.white),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          category_name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black),
                        ),
                      )
                    ],
                  )),
              width: 120,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black,
                image: DecorationImage(
                    image: new NetworkImage(image_url), fit: BoxFit.cover),boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 5.0, // soften the shadow
                  spreadRadius: 1.0, //extend the shadow
                  offset: Offset(
                    1.0, // Move to right 10  horizontally
                    1.0, // Move to bottom 5 Vertically
                  ),
                )
              ],
              ),),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => menuByCategories(
                      category_id: category_id, category_name: category_name)),
            );
          }),
    );
  }
}
