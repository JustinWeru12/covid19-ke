import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid19/pages/sidebar.dart';
import 'package:covid19/services/authentication.dart';
import 'package:covid19/services/crud.dart';
import 'package:covid19/style/theme.dart';
import 'package:covid19/widgets/counter.dart';
import 'package:covid19/widgets/my_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final logoutCallback;
  final String userId;

  void _signOut() async {
    try {
      await auth.signOut();
      logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = ScrollController();
  CrudMethods crudObj = new CrudMethods();
  double offset = 0;
  String listVal = 'Kenya';
  int dead, infected, recovered, aColor;
  final _formKey = GlobalKey<FormState>();
  var date, colorDate;

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    crudObj.getDataFromUserFromDocument().then((value) {
      Map<String, dynamic> dataMap = value.data;
      setState(() {
        aColor = dataMap['aColor'];
        colorDate = dataMap['date'];
      });
    });
    crudObj.getData().then((value) {
      Map<String, dynamic> dataMap = value.data;
      setState(() {
       var dates = dataMap['upDate'].toDate();
       date =new DateFormat.yMMMd().format(dates);
        print(new DateFormat.yMMMd().format(dates));
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    updateColor();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  void updateColor() {
    if (DateTime.now().millisecondsSinceEpoch - colorDate > 1814400000) {
      if (aColor == 4294920264) {
        crudObj.createOrUpdateUserData({'aColor': 4294936392,'date':DateTime.now().millisecondsSinceEpoch});
      } else if (aColor == 4294936392) {
        crudObj.createOrUpdateUserData({'aColor': 4281778476, 'date':DateTime.now().millisecondsSinceEpoch});
      }
    }
  }

  String validateDeaths(String value) {
    if (int.tryParse(value) < dead)
      return 'The number can only remain the same or increase\nplease verify the value';
    else
      return null;
  }

  String validateInfected(String value) {
    if (int.tryParse(value) < infected)
      return 'The number can only remain the same or increase\nplease verify the value';
    else
      return null;
  }

  String validateRecovered(String value) {
    if (int.tryParse(value) < recovered)
      return 'The number can only remain the same or increase\nplease verify the value';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(
        logoutCallback: widget._signOut,
      ),
      appBar: new AppBar(
        title: Text(
          'Home',
          style: kAppBarstyle,
        ),
        centerTitle: true,
        iconTheme: new IconThemeData(color: Colors.green),
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF3383CD),
              Color(0xFF11249F),
            ],
          )),
        ),
      ),
      body: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: <Widget>[
            MyHeader(
              image: "assets/icons/Drcorona.svg",
              textTop: "All you need is",
              textBottom: "to stay at home.",
              offset: offset,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Color(0xFFE5E5E5),
                ),
              ),
              child: Row(
                children: <Widget>[
                  SvgPicture.asset("assets/icons/maps-and-flags.svg"),
                  SizedBox(width: 20),
                  Expanded(
                    child: DropdownButton(
                      isExpanded: true,
                      underline: SizedBox(),
                      icon: SvgPicture.asset("assets/icons/dropdown.svg"),
                      value: listVal,
                      items: ['Kenya', 'Africa', 'United States', 'Italy']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // setState(() {
                        //   listVal = value;
                        // });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Public Safety Level\n",
                              style: kTitleTextstyle,
                            ),
                            TextSpan(
                              text: " ",
                              style: TextStyle(
                                color: kTextLightColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Text(
                        "See details",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  myColor(),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Case Update\n",
                              style: kTitleTextstyle,
                            ),
                            TextSpan(
                              text: "Latest update: " + date.toString(),
                              style: TextStyle(
                                color: kTextLightColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Text(
                        "See details",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  cases(),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Spread of Virus",
                        style: kTitleTextstyle,
                      ),
                      Text(
                        "See details",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(20),
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 30,
                          color: kShadowColor,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/images/global.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                  // Container(
                  //     height: 10, width: 50, color: Color(aColor ?? 4281778476))
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        children: <Widget>[
          SizedBox(
            width: 50.0,
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              backgroundColor: kDeathColor,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white.withOpacity(0.85),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "These values will be updated as the current number of Covid-19 cases in the country as of this moment.\n\n If you are sure these are true Proceed,\n else please Cancel",
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            Form(
                                key: _formKey,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          initialValue: infected.toString(),
                                          validator: validateInfected,
                                          decoration: InputDecoration(
                                              labelText: 'Infected:'),
                                          onSaved: (value) =>
                                              infected = int.tryParse(value),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          validator: validateDeaths,
                                          initialValue: dead.toString(),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              labelText: 'Deaths:'),
                                          onSaved: (value) =>
                                              dead = int.tryParse(value),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          initialValue: recovered.toString(),
                                          validator: validateRecovered,
                                          decoration: InputDecoration(
                                              labelText: 'Recovered:'),
                                          onSaved: (value) =>
                                              recovered = int.tryParse(value),
                                        ),
                                      ),
                                    ])),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RaisedButton(
                                    color: kDeathColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    child: Text(
                                      "Proceed",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        _formKey.currentState.save();
                                        crudObj.updateData({
                                          'infected': infected,
                                          'dead': dead,
                                          'recovered': recovered,
                                          'upDate': DateTime.now()
                                        });
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RaisedButton(
                                    color: kRecovercolor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    });
              },
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget cases() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('cases')
          .document('hNZISn2aVmS6Ow5Ipye3')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var userData = snapshot.data;
        dead = userData['dead'];
        infected = userData['infected'];
        recovered = userData['recovered'];
       var dates = userData['upDate'].toDate();
        date =new DateFormat.yMMMd().format(dates);
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 30,
                color: kShadowColor,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Counter(
                color: kInfectedColor,
                number: userData['infected'],
                title: "Infected",
              ),
              Counter(
                color: kDeathColor,
                number: userData['dead'],
                title: "Deaths",
              ),
              Counter(
                color: kRecovercolor,
                number: userData['recovered'],
                title: "Recovered",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget myColor() {
    return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: aColor == null ? kBackgroundColor : Color(aColor),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 30,
              color: kShadowColor,
            ),
          ],
        ),
        child: Column(children: <Widget>[
          aColor == 4281778476
              ? Text(
                  "Your color is green.This means that you have not been in areas with reported Covid-19 cases for the past 14-21 days.\nPlease remain vigilant and follow proper prevention measures.",
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                )
              : Container(),
          aColor == 4294920264
              ? Text(
                  "Your color is red.This means that you have been in an area with a reported Covid-19 case(s) within the past 14 days.\nPlease remain in isolation for the next 21 days and reach to emergency personel for rapid testing.",
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                )
              : Container(),
          aColor == 4294936392
              ? Text(
                  "Your color is orange.This means that you have isolated for past 14 days and tested negative for Covid_19.\nPlease distance yourself for an extended 7 days and do not travel or visit public places.",
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                )
              : Container(),
          aColor == null
              ? SizedBox(
                  height: 10, width: 10, child: CircularProgressIndicator())
              : Container()
        ]));
  }
}
