import "package:flutter/material.dart";
import 'package:permission_handler/permission_handler.dart';
import "listmaker.dart";
import "dart:io";
// import "package:advance_pdf_viewer/advance_pdf_viewer.dart";

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<FileSystemEntity> _pdfs = [];
  Permission storagePerm = Permission.storage;
  PermissionStatus status = PermissionStatus.undetermined;
  String topdf =
      "/storage/emulated/0/Download/GetSwishing - Tip Card 4 - sew a button.pdf";



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
  }

  void checkStatus(Permission permission) async {
    status = (await permission.status);
    if (status != PermissionStatus.granted) {
      requestPermission(permission);
    } else {
      print(status);
    }
  }

  @override
  Widget build(BuildContext context) {
    getlists();
    return MaterialApp(
        title: "Home",
        home: Scaffold(
            appBar: AppBar(
              title: Text("List of PDFs"),
            ),
            body: Pager(_pdfs)));
  }
}
