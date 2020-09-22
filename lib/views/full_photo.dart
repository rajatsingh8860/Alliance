import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:alliance/views/const.dart';

class FullPhoto extends StatelessWidget {
  String url;
  FullPhoto(this.url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FULL PHOTO',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FullPhotoScreen(url),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  FullPhotoScreen(this.url);
  String url;
  @override
  State<StatefulWidget> createState() {
    return FullPhotoScreenState(url);
  }
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  FullPhotoScreenState(this.url);
  String url;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(imageProvider: NetworkImage(url)),
    );
  }
}
