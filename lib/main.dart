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

  @override
  void initState() {
    super.initState();
    checkStatus(storagePerm);
  }

  void requestPermission(Permission permission) async {
    await permission.request();
  }

  void getlists() {
    _pdfs.clear();
    Directory dir = Directory('/storage/emulated/0/');
    // String pdfdir = dir.toString();
    List<FileSystemEntity> _files;

    _files = dir.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity entity in _files) {
      String path = entity.path;
      if (path.endsWith('.pdf')) {
        _pdfs.add(entity);
      }
    }
    _pdfs.sort((a, b) {
      return basename(a.path)
          .replaceAll(".pdf", "")
          .compareTo(basename(b.path).replaceAll(".pdf", ""));
    });

    _dup = new List.from(_pdfs);
  }

  void filterSearchResults(String query) {
    List<FileSystemEntity> dummySearchList = List<FileSystemEntity>();
    dummySearchList.addAll(_dup);
    if (query.isNotEmpty) {
      List<FileSystemEntity> dummyListData = List<FileSystemEntity>();
      dummySearchList.forEach((item) {
        if (basename(item.path).replaceAll(".pdf", "").contains(query)) {
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

  void checkStatus(Permission permission) async {
    status = await permission.status;
    if (status != PermissionStatus.granted) {
      requestPermission(permission);
    } else {
      print(status);
    }

    getlists();
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

        ),
        
        home: Scaffold(
            appBar: AppBar(
              title: Text("dndr"),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    getlists();
                  },
                )
              ],
              backgroundColor: Colors.black,
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {},
                child: Icon(Icons.search)),
            body: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
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
                              child: InkWell(
                                borderRadius: BorderRadius.all(Radius.circular(100)),
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.black, width: 1)),
                                    child: ListTile(
                                      title: Text(basename(_pdfs[index].path)
                                          .replaceAll(".pdf", "")),
                                      onTap: () {
                                        navigateToSubPage(context,
                                            _pdfs[index].path.toString());
                                      },
                                    ),
                                  ),
                                ),
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
