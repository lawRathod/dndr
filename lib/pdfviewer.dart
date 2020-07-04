import "package:flutter/material.dart";
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
// import 'dart:io';


class PDFscreen extends StatefulWidget {
  PDFscreen(this.pdf,{Key key}) : super(key: key);
  final pdf;
  @override
  _PDFscreenState createState() => _PDFscreenState(pdf);
}

class _PDFscreenState extends State<PDFscreen> {
  _PDFscreenState(this.pdf);
  final pdf;
  

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PDFViewerScaffold(
        path: pdf),
    );
  }
}
