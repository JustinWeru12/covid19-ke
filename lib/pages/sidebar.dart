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
        profilPicture = dataMap['picture'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                child: profilPicture != null
                    ? Center(
                        child: new CircleAvatar(
                          backgroundImage: new NetworkImage(profilPicture),
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
                    image: AssetImage("assets/images/landscape.png"),
                    // new NetworkImage(
                    //     "https://firebasestorage.googleapis.com/v0/b/covid19-ke-80e90.appspot.com/o/landscape.png?alt=media&token=893eebff-69da-4be5-8bd4-4f5eb048415e"),
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
            leading: Icon(Icons.map, color: kPrimaryColor),
            title: Text('Map', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.pushReplacementNamed(context, '/map'),
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
            leading: Icon(Icons.help, color: kPrimaryColor),
            title: Text('Get in Touch',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.pushReplacementNamed(context, '/help'),
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
          Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 200.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/virus.png"),
                      ),
                    ),
                  )),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.rotate(
                    angle: 60.0,
                    child: Container(
                      height: 130.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/virus.png"),
                        ),
                      ),
                    ),
                  )),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.rotate(
                    angle: 30.0,
                    child: Container(
                      height: 260.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/virus.png"),
                        ),
                      ),
                    ),
                  )),
            ],
          )
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
