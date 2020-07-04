import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import "package:flutter/material.dart";
import 'package:permission_handler/permission_handler.dart';
import "dart:io";
import "package:path/path.dart";
import "pdfviewer.dart";

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ScrollController _scrollController = ScrollController();
  List<FileSystemEntity> _pdfs = [];
  List<FileSystemEntity> _dup = [];
  Permission storagePerm = Permission.storage;
  PermissionStatus status = PermissionStatus.undetermined;
  TextEditingController editingController = TextEditingController();
  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    checkStatus(storagePerm);
    myFocusNode = new FocusNode();
  }

  void getlists() {
    _pdfs.clear();
    _dup.clear();
    Directory dir = Directory('/storage/emulated/0/');
    // String pdfdir = dir.toString();
    List<FileSystemEntity> _files;

    _files = dir.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity entity in _files) {
      String path = entity.path;
      if (path.endsWith('.pdf')) {
        _dup.add(entity);
      }
    }
    _dup.sort((a, b) {
      return basename(a.path)
          .replaceAll(".pdf", "")
          .compareTo(basename(b.path).replaceAll(".pdf", ""));
    });

    setState(() {
      _pdfs.addAll(_dup);
    });
  }

  void filterSearchResults(String query) {
    List<FileSystemEntity> dummySearchList = List<FileSystemEntity>();
    dummySearchList.addAll(_dup);
    if (query.isNotEmpty) {
      List<FileSystemEntity> dummyListData = List<FileSystemEntity>();
      dummySearchList.forEach((item) {
        if (basename(item.path)
            .replaceAll(".pdf", "")
            .toLowerCase()
            .contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        _pdfs.clear();
        _pdfs.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _pdfs.clear();
        _pdfs.addAll(_dup);
      });
    }
  }

  Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  void checkStatus(Permission permission) async {
    await requestPermission(permission).then((value) {
      getlists();
    });
  }

  void contextMenu(_context, _index, LongPressStartDetails _val) {
    final RenderBox overlay = Overlay.of(_context).context.findRenderObject();
    showMenu(
        position: RelativeRect.fromRect(
            _val.globalPosition & Size(100, 100), Offset.zero & overlay.size),
        context: _context,
        items: <PopupMenuEntry<String>>[
          PopupMenuItem(
              value: "del",
              child: Container(
                  child: Row(
                      children: <Widget>[Icon(Icons.delete), Text("Delete")]))),
          PopupMenuItem(
            value: "edit",
            child: Container(
                child:
                    Row(children: <Widget>[Icon(Icons.edit), Text("Rename")])),
          )
        ]).then<void>((String sel) {
      File tochange = new File(_pdfs[_index].path);
      if (sel == "del") {
        try {
          tochange.delete();
          getlists();
        } catch (e) {
          print(e);
        }
      } else if (sel == "edit") {
        String _newName;
        showDialog(
            context: _context,
            builder: (_) => new AlertDialog(
                    title: Text("Rename"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32))),
                    content: Row(children: <Widget>[
                      Expanded(
                          child: TextField(
                              autofocus: true,
                              onChanged: (val) {
                                _newName = val;
                              },
                              decoration: InputDecoration(
                                  labelText: "Name",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0))))))
                    ]),
                    actions: <Widget>[
                      FlatButton(
                          textColor: Colors.black,
                          child: Text("Ok"),
                          onPressed: () {
                            Navigator.of(_context).pop();
                            if (_newName != null) {
                              _newName = tochange.path.substring(
                                      0, tochange.path.lastIndexOf("/") + 1) +
                                  _newName +
                                  ".pdf";
                              List<String> _temp = new List<String>();
                              for (FileSystemEntity i in _pdfs) {
                                _temp.add(i.path);
                              }
                              if (_temp.contains(_newName)) {
                                print("already there");
                              } else {
                                print("in here");
                                tochange.rename(_newName);
                                getlists();
                              }
                            } else {
                              print("String Empty");
                            }
                          })
                    ]));
      }
    });
  }

  Future navigateToSubPage(context, pdf) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PDFscreen(pdf)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Home",
        theme: ThemeData(
            primaryColor: Colors.black,
            accentColor: Colors.black,
            appBarTheme: AppBarTheme(color: Colors.white)),
        home: Scaffold(
            appBar: AppBar(
              elevation: 0,
              bottom: PreferredSize(
                  child: Container(
                    color: Colors.black,
                    height: 2.0,
                  ),
                  preferredSize: Size.fromHeight(4.0)),
              title: Text(
                "dndr",
                style: TextStyle(color: Colors.black),
              ),
              actions: <Widget>[
                IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    getlists();
                  },
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  myFocusNode.requestFocus();
                },
                child: Icon(Icons.search)),
            body: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // border: Border(bottom: BorderSide(color: Colors.black, width: 2))
                    ),
                    child: TextField(
                      focusNode: myFocusNode,
                      onChanged: (value) {
                        filterSearchResults(value);
                      },
                      controller: editingController,
                      decoration: InputDecoration(
                          labelText: "Search",
                          hintText: "Type Something",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)))),
                    ),
                  ),
                  Expanded(
                      child: DraggableScrollbar.semicircle(
                    // labelTextBuilder: (double offset) => Text("${offset ~/ 100}"),
                    controller: _scrollController,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _pdfs.length,
                      itemBuilder: (context, index) {
                        return Container(
                            padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                            child: Container(
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.black, width: 1)),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onLongPressStart: (val) =>
                                          contextMenu(context, index, val),
                                      onTapCancel: () {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      },
                                      child: InkResponse(
                                        containedInkWell: true,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        child: ListTile(
                                          title: Text(
                                              basename(_pdfs[index].path)
                                                  .replaceAll(".pdf", "")),
                                          onTap: () {
                                            navigateToSubPage(context,
                                                _pdfs[index].path.toString());
                                          },
                                        ),
                                      ),
                                    )),
                              ),
                            ));
                      },
                    ),
                  )),
                ],
              ),
            )));
  }
}
