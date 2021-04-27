import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiktok/variables.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  ProfilePage(this.uid);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username;
  String onlineuser;
  String profilepic;
  Future myvideos;
  int likes = 0;
  int followers;
  TextEditingController usernamecontroller = TextEditingController();
  int following;
  bool isFollowing;
  bool dataisthere = false;

  @override
  void initState() {
    super.initState();
    getalldata();
  }

  getalldata() async {
    // get videos as future
    myvideos = videoscollection.where('uid', isEqualTo: widget.uid).get();

    // get onlineuser
    onlineuser = FirebaseAuth.instance.currentUser.uid;

    // get userdata
    DocumentSnapshot userdoc = await usercollection.doc(widget.uid).get();
    username = userdoc.data()['username'];
    profilepic = userdoc.data()['profilepic'];

    // get likes;
    var documents =
        await videoscollection.where('uid', isEqualTo: widget.uid).get();
    for (var item in documents.docs) {
      likes = item.data()['likes'].length + likes;
    }

    // get followers and follwings
    var followersdocuments =
        await usercollection.doc(widget.uid).collection('followers').get();

    var followingdocuments =
        await usercollection.doc(widget.uid).collection('following').get();
    followers = followersdocuments.docs.length;
    following = followingdocuments.docs.length;

    // check if already follwing
    usercollection
        .doc(widget.uid)
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((document) {
      if (!document.exists) {
        setState(() {
          isFollowing = false;
        });
      } else {
        setState(() {
          isFollowing = true;
        });
      }
    });
    setState(() {
      dataisthere = true;
    });
    print(isFollowing);
  }

  followuser() async {
    var document = await usercollection
        .doc(widget.uid)
        .collection('followers')
        .doc(onlineuser)
        .get();
    if (!document.exists) {
      usercollection
          .doc(widget.uid)
          .collection('followers')
          .doc(onlineuser)
          .set({});
      usercollection
          .doc(onlineuser)
          .collection('following')
          .doc(widget.uid)
          .set({});
      setState(() {
        isFollowing = true;
        followers++;
      });
    } else {
      print("deleting");
      usercollection
          .doc(widget.uid)
          .collection('followers')
          .doc(onlineuser)
          .delete();
      usercollection
          .doc(onlineuser)
          .collection('followers')
          .doc(widget.uid)
          .delete();

      setState(() {
        isFollowing = false;
        followers--;
      });
    }
  }

  editprofile() {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Edit profile", style: mystyle(20)),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      controller: usernamecontroller,
                      decoration: InputDecoration(
                        hintText: "Give new username",
                        hintStyle: mystyle(17),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      usercollection
                          .doc(FirebaseAuth.instance.currentUser.uid)
                          .update({'username': usernamecontroller.text});
                      setState(() {
                        username = usernamecontroller.text;
                      });
                      usernamecontroller.clear();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: 50,
                      color: Colors.pink,
                      child: Center(
                        child: Text(
                          "Update now",
                          style: mystyle(17, Colors.white, FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: dataisthere == false
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Container(
                margin: EdgeInsets.only(top: 20),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => FirebaseAuth.instance.signOut(),
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(profilepic),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      username,
                      style: mystyle(25, Colors.black, FontWeight.w500),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          following.toString(),
                          style: mystyle(23, Colors.black, FontWeight.w500),
                        ),
                        Text(
                          followers.toString(),
                          style: mystyle(23, Colors.black, FontWeight.w500),
                        ),
                        Text(
                          likes.toString(),
                          style: mystyle(23, Colors.black, FontWeight.w500),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Following",
                          style: mystyle(17, Colors.grey, FontWeight.w700),
                        ),
                        Text(
                          "Fans",
                          style: mystyle(17, Colors.grey, FontWeight.w700),
                        ),
                        Text(
                          "Hearts",
                          style: mystyle(17, Colors.grey, FontWeight.w700),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    onlineuser == widget.uid
                        ? InkWell(
                            onTap: () => editprofile(),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height: 40,
                              color: Colors.pink,
                              child: Center(
                                child: Text(
                                  "Edit profile",
                                  style: mystyle(
                                      20, Colors.white, FontWeight.w600),
                                ),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () => followuser(),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height: 40,
                              color: Colors.pink,
                              child: Center(
                                child: Text(
                                  isFollowing == false ? "Follow" : "Unfollow",
                                  style: mystyle(
                                      20, Colors.white, FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 20),
                    Text(
                      "My Videos",
                      style: mystyle(20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FutureBuilder(
                      future: myvideos,
                      builder: (BuildContext context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data.docs.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 5),
                            itemBuilder: (BuildContext context, int index) {
                              DocumentSnapshot video =
                                  snapshot.data.docs[index];
                              return Container(
                                child: Image(
                                  image: NetworkImage(
                                    video.data()['previewimage'],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              );
                            });
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
