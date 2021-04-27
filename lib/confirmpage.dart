import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import 'variables.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmPage extends StatefulWidget {
  final File videofile;
  final String videopath_astring;
  final ImageSource imageSource;

  ConfirmPage(this.videofile, this.videopath_astring, this.imageSource);
  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  VideoPlayerController controller;
  bool isuploading = false;
  TextEditingController musicontroller = TextEditingController();
  TextEditingController captioncontroller = TextEditingController();
  FlutterVideoCompress flutterVideoCompress = FlutterVideoCompress();
  @override
  void initState() {
    super.initState();
    setState(() {
      controller = VideoPlayerController.file(widget.videofile);
    });
    controller.initialize();
    controller.play();
    controller.setVolume(1);
    controller.setLooping(true);
    print(widget.videopath_astring);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  compressvideo() async {
    if (widget.imageSource == ImageSource.gallery) {
      return widget.videofile;
    } else {
      final compressedvideo = await flutterVideoCompress.compressVideo(
          widget.videopath_astring,
          quality: VideoQuality.MediumQuality);
      return File(compressedvideo.path);
    }
  }

  getpreviewimage() async {
    final previewimage = await flutterVideoCompress.getThumbnailWithFile(
      widget.videopath_astring,
    );
    return previewimage;
  }

  uploadvideotostorage(String id) async {
    UploadTask storageUploadTask =
        videosfolder.child(id).putFile(await compressvideo());
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadurl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadurl;
  }

  uploadimagetostorage(String id) async {
    UploadTask storageUploadTask =
        imagesfolder.child(id).putFile(await getpreviewimage());
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() {});
    String downloadurl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadurl;
  }

  uploadvideo() async {
    setState(() {
      isuploading = true;
    });
    try {
      var firebaseuseruid = FirebaseAuth.instance.currentUser.uid;
      DocumentSnapshot userdoc =
          await usercollection.doc(firebaseuseruid).get();
      var alldocs = await videoscollection.get();
      int length = alldocs.docs.length;
      String video = await uploadvideotostorage("Video $length");
      String previewimage = await uploadimagetostorage("Video $length");
      videoscollection.doc("Video $length").set({
        'username': userdoc.data()['username'],
        'uid': firebaseuseruid,
        'profilepic': userdoc.data()['profilepic'],
        'id': "Video $length",
        'likes': [],
        'commentcount': 0,
        'sharecount': 0,
        'songname': musicontroller.text,
        'caption': captioncontroller.text,
        'videourl': video,
        'previewimage': previewimage
      });
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isuploading == true
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Uploading......", style: mystyle(25)),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: VideoPlayer(controller),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: TextField(
                            controller: musicontroller,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Song name",
                                labelStyle: mystyle(20),
                                prefixIcon: Icon(Icons.music_note),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          margin: EdgeInsets.only(right: 40),
                          child: TextField(
                            controller: captioncontroller,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Caption",
                                labelStyle: mystyle(20),
                                prefixIcon: Icon(Icons.closed_caption),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        onPressed: () => uploadvideo(),
                        color: Colors.lightBlue,
                        child: Text(
                          "Upload Video",
                          style: mystyle(20, Colors.white),
                        ),
                      ),
                      RaisedButton(
                        onPressed: () => Navigator.pop(context),
                        color: Colors.red,
                        child: Text(
                          "Another Video",
                          style: mystyle(20, Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
