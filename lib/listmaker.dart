import "package:flutter/material.dart";

class Pager extends StatefulWidget {
  final _items;
  Pager(this._items, {Key key}) : super(key: key);

  @override
  _PagerState createState() => _PagerState(_items);
}

class _PagerState extends State<Pager> {
  _PagerState(this._items);
  final _items;
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
