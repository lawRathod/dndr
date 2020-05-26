import "package:flutter/material.dart";
import 'package:permission_handler/permission_handler.dart';
import "listmaker.dart";

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<String> listitems = new List();

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

  void checkStatus(Permission permission) async{
    status = (await permission.status);
    if(status != PermissionStatus.granted){
      requestPermission(permission);
    } else{
      print(status);
    }
  } 

  @override
  Widget build(BuildContext context) {
    listitems.add("water");
    listitems.add("in the peakock");
    listitems.add("i got bae");
    return MaterialApp(
        title: "Home",
        home: Scaffold(
            appBar: AppBar(
              title: Text("List of PDFs"),
            ),
            body: Pager(listitems)
            )
            );
  }
}
