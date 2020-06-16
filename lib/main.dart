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
  Permission storagePerm = Permission.storage;
  PermissionStatus status = PermissionStatus.undetermined;

  @override
  void initState() {
    checkStatus(storagePerm);
    super.initState();
  }

  void requestPermission(Permission permission) async {
    await permission.request();
  }

  void getlists() {
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
    _pdfs = new List.from(_pdfs.reversed);
  }

  void checkStatus(Permission permission) async {
    status = (await permission.status);
    if (status != PermissionStatus.granted) {
      requestPermission(permission);
    } else {
      print(status);
    }
  }

  Future navigateToSubPage(context, pdf) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PDFscreen(pdf)));
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
    getlists();
    return MaterialApp(
        title: "Home",
        home: Scaffold(
            appBar: AppBar(
              title: Text("dndr"),
              backgroundColor: Colors.black,
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {},
                child: Icon(Icons.settings)),
            body: DraggableScrollbar.semicircle(
              // labelTextBuilder: (double offset) => Text("${offset ~/ 100}"),
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _pdfs.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                    child: InkWell(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black, width: 1)),
                          child: _buildrow(_pdfs[index], context),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )));
  }
}
