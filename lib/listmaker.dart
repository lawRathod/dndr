import "package:flutter/material.dart";

class Pager extends StatefulWidget {
  final _items;
  Pager(this._items, {Key key}) : super(key: key);

  @override
  _PagerState createState() => _PagerState();
}

class _PagerState extends State<Pager> {
  
  Widget _buildlist(){
    return ListView.builder(
      itemCount: widget._items.length,
      itemBuilder: (context, index) {
        return _buildrow(widget._items[index]);
      },
    );
  }
  Widget _buildrow(String a){
    return ListTile(
      title: Text(
        a,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return _buildlist();
  }
}