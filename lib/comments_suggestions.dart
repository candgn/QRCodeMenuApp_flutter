import 'package:flutter/material.dart';

class Comment extends StatefulWidget {
  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Şikayet/Öneri"),
      ),
      backgroundColor: Color.fromRGBO(240, 240, 240, 1),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                  "Tüm şikayet ve önerilerinizi aşağıdaki alanı doldurarak bize yollayabilirsiniz :)"),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 50,
              child: TextField(),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: RawMaterialButton(
                  child: Text(
                    "Gönder",
                    style: TextStyle(color: Colors.white),
                  ),
                  fillColor: Colors.black,
                  onPressed: null),
            )
          ],
        ),
      ),
    );
  }
}
