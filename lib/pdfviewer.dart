import "package:advance_pdf_viewer/advance_pdf_viewer.dart";
import "package:flutter/material.dart";

class PDFscreen extends StatefulWidget {
  PDFscreen(this.pdf,{Key key}) : super(key: key);
  final pdf;
  @override
  _PDFscreenState createState() => _PDFscreenState(pdf);
}

class _PDFscreenState extends State<PDFscreen> {
  _PDFscreenState(this.pdf);
  final pdf;
  bool _isLoading = true;
  PDFDocument document;

  @override
  void initState() { 
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    document = await PDFDocument.fromFile(pdf);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : PDFViewer(
                document: document,
                zoomSteps: 1,
              ),
      ),
    );
  }
}
