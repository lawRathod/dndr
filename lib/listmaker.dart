import "package:flutter/material.dart";
import "package:path/path.dart";
import "pdfviewer.dart";
// import "dart:io";

class Pager extends StatefulWidget {
  final _items;
  Pager(this._items, {Key key}) : super(key: key);

  @override
  _PagerState createState() => _PagerState(_items);
}

class _PagerState extends State<Pager> {
  _PagerState(this._items);
  final _items;

  Future navigateToSubPage(context, pdf) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PDFscreen(pdf)));
  }

  Widget _buildlist() {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return _buildrow(_items[index], context);
      },
    );
  }

  Widget _buildrow(a, context) {
    return ListTile(
      title:
          a is String ? Text(a) : Text(basename(a.path).replaceAll(".pdf", "")),
      onTap: () {
        navigateToSubPage(context, a.path.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildlist();
  }
}
