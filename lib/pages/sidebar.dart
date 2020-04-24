// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid19/pages/info_screen.dart';
import 'package:covid19/services/authentication.dart';
import 'package:covid19/services/crud.dart';
import 'package:covid19/style/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SideBar extends StatefulWidget {
  SideBar({Key key, this.userId, this.logoutCallback}) : super(key: key);

  final BaseAuth auth = new Auth();

  final String userId;
  final VoidCallback logoutCallback;
  void _signOut() async {
    try {
      await auth.signOut();
      logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String userId;
  CrudMethods crudObj = new CrudMethods();
  String userMail;
  String _fullNames;
  String _lastNames;
  String profilPicture;
  String image;
  @override
  void initState() {
    super.initState();
    crudObj.getDataFromUserFromDocument().then((value) {
      Map<String, dynamic> dataMap = value.data;
      setState(() {
        userId = dataMap['userId'];
        userMail = dataMap['email'];
        _fullNames = dataMap['fullNames'];
        _lastNames = dataMap['last_name'];
        profilPicture = dataMap['picture'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var userData =
        Firestore.instance.collection('user').document(userId).snapshots();
    return Drawer(
      child: ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
                  accountEmail: new Text(
                    userMail ?? '',
                    style: TextStyle(fontSize: 15.0),
                  ),
                  accountName: Row(
                    children: <Widget>[
                      new Text(
                        _fullNames ?? '',
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ],
                  ),
                  currentAccountPicture: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kPrimaryColor,
                        width: 4,
                      ),
                    ),
                    child: new GestureDetector(
                      child: image != null
                          ? Center(
                              child: new CircleAvatar(
                                backgroundImage: new NetworkImage(image),
                                maxRadius: 70.0,
                                minRadius: 60.0,
                              ),
                            )
                          : CircleAvatar(
                              child: Image.asset('assets/images/profile.png'),
                              minRadius: 60,
                              maxRadius: 93,
                            ),
                      onTap: () => print("This is your current account."),
                    ),
                  ),
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                          image: new NetworkImage(
                              "https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg"),
                          fit: BoxFit.fill)),
                ),
          ListTile(
            leading: Icon(Icons.home, color: kPrimaryColor),
            title: Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.pushReplacementNamed(context, '/'),
            },
          ),
          divider(),
          ListTile(
            leading: Icon(Icons.notifications, color: kPrimaryColor),
            title: Text('About Covid-19',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return InfoScreen();
                  },
                ),
              ),
            },
          ),
          divider(),
          ListTile(
            leading: Icon(Icons.person, color: kPrimaryColor),
            title: Text('My Account',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.pushReplacementNamed(context, '/profile'),
            },
          ),
          divider(),
          ListTile(
            leading: Icon(Icons.verified_user, color: kPrimaryColor),
            title: Text('My Interview List',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.pushReplacementNamed(context, '/interview'),
            },
          ),
          divider(),
          ListTile(
            leading: Icon(Icons.local_mall, color: kPrimaryColor),
            title: Text('Employees I\'ve Hired',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.pushReplacementNamed(context, '/hired'),
            },
          ),
          divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: kPrimaryColor),
            title:
                Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () async {
              Navigator.of(context).pop();
              widget._signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
    );
  }

  Widget divider() {
    return Divider(
      color: kPrimaryColor.withOpacity(0.5),
      height: 10,
      indent: 50,
      endIndent: 20,
    );
  }
}
