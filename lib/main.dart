import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/services.dart';
import "package:flutter/material.dart";
import 'package:permission_handler/permission_handler.dart';
import "dart:io";
import "package:path/path.dart";
import "pdfviewer.dart";
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ListStorage _listStorage = new ListStorage();
  List<String> listFromFile = new List<String>();
  final ScrollController _scrollController = ScrollController();
  List<String> _pdfs = new List<String>();
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

  List<String> getpdfs(){
    Directory dir = Directory('/storage/emulated/0/');
    List<FileSystemEntity> _files;
    List<String> _dup = new List<String>();
    _files = dir.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity entity in _files) {
      String path = entity.path;
      if (path.endsWith('.pdf')) {
        _dup.add(entity.path);
      }
    }
    _dup.sort((a, b) {
      return basename(a)
          .replaceAll(".pdf", "")
          .compareTo(basename(b).replaceAll(".pdf", ""));
    });

    return _dup;

  }

  void getlists() {
    List<String> temp = getpdfs();
    _listStorage.read().then<void>((val){
      String listString = val;
      if(listString.isEmpty){
        listFromFile.addAll(temp);
        _listStorage.write(listFromFile);
        setState((){
          _pdfs.addAll(temp);
        });
      } else {
        listFromFile = listString.split("%*%*%");
        if(temp.length > listFromFile.length){
          for(String p in temp){
            if(!listFromFile.contains(p)){
              listFromFile.insert(0, p);
            }
          }
        }
        _listStorage.write(listFromFile);
        setState((){
          _pdfs.clear();
          _pdfs.addAll(listFromFile);
        });

      }});
  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(listFromFile);
    if (query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {
        if (basename(item)
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
        _pdfs.addAll(listFromFile);
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        position: RelativeRect.fromRect(
            _val.globalPosition & Size(100, 100), Offset.zero & overlay.size),
        context: _context,
        items: <PopupMenuEntry<String>>[
          PopupMenuItem(
              value: "del",
              child: Container(
                  child: Row(children: <Widget>[
                    Icon(Icons.delete, color: Colors.red),
                    Text("  Delete", style: TextStyle(color: Colors.red))
                  ]))),
          PopupMenuItem(
              value: "edit",
              child: Container(
                  child: Row(children: <Widget>[
                    Icon(Icons.edit, color: Colors.grey.shade700),
                    Text("  Rename", style: TextStyle(color: Colors.grey.shade700)),
                  ])),
          )
        ]).then<void>((String sel) {
          File tochange = new File(_pdfs[_index]);
          if (sel == "del") {
            try {
              tochange.delete();
              listFromFile.removeAt(_index);
              _listStorage.write(listFromFile);
              setState((){
                _pdfs.clear();
                _pdfs.addAll(listFromFile);
              });
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
                              for (String i in _pdfs) {
                                _temp.add(i);
                              }
                              if (_temp.contains(_newName)) {
                              } else {
                                tochange.rename(_newName);
                                listFromFile[_index] = _newName;
                                _listStorage.write(listFromFile);
                                setState((){
                                  _pdfs.clear();
                                  _pdfs.addAll(listFromFile);
                                });
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
        title: "Home",
        theme: ThemeData(
            primaryColor: Colors.grey.shade700,
            accentColor: Colors.grey.shade700,
            appBarTheme: AppBarTheme(color: Colors.white)),
        home: Scaffold(
            appBar: AppBar(
                brightness: Brightness.light,
                elevation: 0,
                bottom: PreferredSize(
                    child: Container(
                        color: Colors.grey,
                        height: 1.0,
                    ),
                    preferredSize: Size.fromHeight(4.0)),
                title: Text(
                    "dndr",
                    style: TextStyle(color: Colors.grey.shade700),
                ),
                actions: <Widget>[
                  IconButton(
                      color: Colors.grey.shade800,
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
                                                                    color: Colors.grey, width: 1)),
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
                                                                               title: Text(basename(_pdfs[index])
                                                                                   .replaceAll(".pdf", "")),
                                                                               onTap: () {
                                                                                 if (index != 0) {
                                                                                   String temp = _pdfs[index];
                                                                                   listFromFile.removeAt(listFromFile.indexOf(temp));
                                                                                   listFromFile.insert(0, temp);
                                                                                   _listStorage.write(listFromFile);
                                                                                   
                                                                                 }
                                                                                 setState((){
                                                                                     _pdfs.clear();
                                                                                     _pdfs.addAll(listFromFile);
                                                                                   });
                                                                                 navigateToSubPage(context,
                                                                                     _pdfs[0].toString());
                                                                                 
                                                                                 FocusScope.of(context).requestFocus(new FocusNode());
                                                                                 editingController.clear();
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

class ListStorage {
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/list').create(recursive: true);
  }

  Future<String> read() async {
    try {
      final file = await _localFile;
      String list = await file.readAsString();
      return list;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> write(List<String> x) async {
    String p = x.join("%*%*%");
    try {
      final file = await _localFile;

      await file.writeAsString('$p');
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
