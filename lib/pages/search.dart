import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tiktok/pages/profile.dart';
import 'package:tiktok/variables.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<QuerySnapshot> searchresult;
  searchuser(String typpeduser) {
    var users = usercollection
        .where('username', isGreaterThanOrEqualTo: typpeduser)
        .get();
    setState(() {
      searchresult = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffECE5DA),
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: TextFormField(
            decoration: InputDecoration(
              filled: true,
              hintText: "Search for flik tokers",
              hintStyle: mystyle(18),
            ),
            onFieldSubmitted: searchuser,
          ),
        ),
        body: searchresult == null
            ? Center(
                child: Text(
                  "Search for flik tokers....",
                  style: mystyle(25),
                ),
              )
            : FutureBuilder(
                future: searchresult,
                builder: (BuildContext context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot user = snapshot.data.docs[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProfilePage(user.data()['uid'])));
                          },
                          child: ListTile(
                            leading: Icon(Icons.search),
                            trailing: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  NetworkImage(user.data()['profilepic']),
                            ),
                            title: Text(
                              user.data()['username'],
                              style: mystyle(25),
                            ),
                          ),
                        );
                      });
                },
              ));
  }
}
