import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tiktok/pages/comments.dart';
import 'package:tiktok/variables.dart';
import 'package:tiktok/widgets/circleanimation.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  Stream mystream;
  String uid;

  initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser.uid;
    mystream = videoscollection.snapshots();
  }

  buildprofile(String url) {
    return Container(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            left: 5,
            child: Container(
              width: 50,
              height: 50,
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image(
                  image: NetworkImage(url),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 20,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  color: Colors.pink, borderRadius: BorderRadius.circular(15)),
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
          )
        ],
      ),
    );
  }

  buildrotatingprofile(String url) {
    return Container(
      width: 60,
      height: 60,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(11),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient:
                  LinearGradient(colors: [Colors.grey[800], Colors.grey[700]]),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
      ),
    );
  }

  likevideo(String id) async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    DocumentSnapshot doc = await videoscollection.doc(id).get();
    if (doc.data()['likes'].contains(uid)) {
      videoscollection.doc(id).update({
        'likes': FieldValue.arrayRemove([uid])
      });
    } else {
      videoscollection.doc(id).update({
        'likes': FieldValue.arrayUnion([uid])
      });
    }
  }

  sharevideo(String video, String id) async {
    var request = await HttpClient().getUrl(Uri.parse(video));
    var response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    await Share.file('FlikTok', 'Video.mp4', bytes, 'video/mp4');
    DocumentSnapshot doc = await videoscollection.doc(id).get();
    videoscollection
        .doc(id)
        .update({'sharecount': doc.data()['sharecount'] + 1});
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: StreamBuilder(
          stream: mystream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return PageView.builder(
                itemCount: snapshot.data.docs.length,
                controller: PageController(initialPage: 0, viewportFraction: 1),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  DocumentSnapshot videos = snapshot.data.docs[index];

                  return Stack(
                    children: [
                      VideoPlayerItem(videos.data()['videourl']),
                      Column(
                        children: [
                          // top section
                          Container(
                            height: 100,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Following",
                                  style: mystyle(
                                      17, Colors.white, FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "For you",
                                  style: mystyle(
                                      17, Colors.white, FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          // middle section
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // down captions, author , song name
                                Expanded(
                                    child: Container(
                                  height: 70,
                                  padding: EdgeInsets.only(left: 20),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(videos.data()['username'],
                                          style: mystyle(15, Colors.white,
                                              FontWeight.bold)),
                                      Text(
                                        videos.data()['caption'],
                                        style: mystyle(
                                            15, Colors.white, FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.music_note,
                                            size: 15,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            videos.data()['songname'],
                                            style: mystyle(15, Colors.white,
                                                FontWeight.bold),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )),
                                // right section
                                Container(
                                  width: 100,
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          12),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildprofile(videos.data()['profilepic']),
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () =>
                                                likevideo(videos.data()['id']),
                                            child: Icon(Icons.favorite,
                                                size: 55,
                                                color: videos
                                                        .data()['likes']
                                                        .contains(uid)
                                                    ? Colors.red
                                                    : Colors.white),
                                          ),
                                          SizedBox(
                                            height: 7,
                                          ),
                                          Text(
                                            videos
                                                .data()['likes']
                                                .length
                                                .toString(),
                                            style: mystyle(20, Colors.white),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CommentsPage(videos
                                                            .data()['id']))),
                                            child: Icon(Icons.comment,
                                                size: 55, color: Colors.white),
                                          ),
                                          SizedBox(
                                            height: 7,
                                          ),
                                          Text(
                                            videos
                                                .data()['commentcount']
                                                .toString(),
                                            style: mystyle(20, Colors.white),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () => sharevideo(
                                                videos.data()['videourl'],
                                                videos.data()['id']),
                                            child: Icon(Icons.reply,
                                                size: 55, color: Colors.white),
                                          ),
                                          SizedBox(
                                            height: 7,
                                          ),
                                          Text(
                                            videos
                                                .data()['sharecount']
                                                .toString(),
                                            style: mystyle(20, Colors.white),
                                          )
                                        ],
                                      ),
                                      CircleAnimation(buildrotatingprofile(
                                          videos.data()['profilepic']))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  );
                });
          }),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String videourl;
  VideoPlayerItem(this.videourl);
  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videourl)
      ..initialize().then((value) {
        videoPlayerController.play();
        videoPlayerController.setVolume(1);
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: VideoPlayer(videoPlayerController),
    );
  }
}
