import 'package:flutter/material.dart';


class FoodModel extends StatefulWidget {
  String title,name;

  FoodModel(this.title,this.name);

  @override
  _FoodModelState createState() => _FoodModelState(title,name);
}

class _FoodModelState extends State<FoodModel> {
  String title,name;
  _FoodModelState(this.title,this.name);
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(name),
            Container(
              child: Container(
                height: 30,
                child: IconButton(
                    icon: Icon(Icons.add_circle_outline), onPressed: null),
              ),
            ),
            Container(
              width: 50,
              child: new TextField(
                textAlign: TextAlign.center,
                decoration: new InputDecoration(
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.teal)),
                  hintText: '0',
                ),
              ),
            ),
            Container(
              height: 30,
              child: IconButton(
                  icon: Icon(Icons.remove_circle_outline), onPressed: null),
            ),
          ],
        ),
      ],
    );
  }
}
