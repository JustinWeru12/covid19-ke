import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid19/pages/sidebar.dart';
import 'package:covid19/services/authentication.dart';
import 'package:covid19/services/crud.dart';
import 'package:covid19/style/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/rxdart.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key, this.auth, this.userId, this.logoutCallback, this.location})
      : super(key: key);

  final BaseAuth auth;
  final logoutCallback;
  final String userId;
  final LocationData location;

  void _signOut() async {
    try {
      await auth.signOut();
      logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor stationLocationIcon;
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  BehaviorSubject<double> radis = BehaviorSubject<double>.seeded(1.0);
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Stream<dynamic> query;
  // StreamSubscription<List<DocumentSnapshot>> subscription;
  Location location = new Location();
  Geoflutterfire geo = Geoflutterfire();
  PermissionStatus _permissionGranted;
  LocationData currentLocation;
  Set<Circle> _circles = HashSet<Circle>();
  Set<Marker> _marker = HashSet<Marker>();
  StreamSubscription<LocationData> locationsubs;
  Stream<List<DocumentSnapshot>> stream;
  List<LatLng> latLng = List<LatLng>();
  double radius = 100.0;
  double zoomSize = 10;
  double tiltAngle = 80;
  double bearingAngle = 30;
  DateTime date;
  String _name, station;
  var clients = [];
  bool clientsToggle = false;
  GoogleMapController mapController;
  CrudMethods crudObj = new CrudMethods();
  var pos;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    location = new Location();
    locationsubs = location.onLocationChanged.listen((LocationData cLoc) {
      setState(() {
        currentLocation = cLoc;
      });
      updatePinOnMap();
    });
    setCustomMapPin();
    _circles.clear();
    _checkLocationPermission();
    _requestPermission();
    initialLocation();
    checkDist();
  }

  @override
  void dispose() {
    locationsubs.cancel();
    super.dispose();
    radis.close();
    // subscription.cancel();
  }

  void updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: zoomSize,
      tilt: tiltAngle,
      bearing: bearingAngle,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    setState(() {
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);
      _markers.removeWhere((m) => m.markerId.value == 'pinLocationIcon');
      _markers.add(Marker(
          markerId: MarkerId('pinLocationIcon'),
          position: pinPosition, // updated position
          icon: pinLocationIcon));
    });
  }

  void initialLocation() async {
    pos = await location.getLocation();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/destination_map_marker.png');
    stationLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/pin.png');
  }

  Future<void> _checkLocationPermission() async {
    final PermissionStatus permissionGrantedResult =
        await location.hasPermission();
    setState(() {
      _permissionGranted = permissionGrantedResult;
    });
  }

  Future<void> _requestPermission() async {
    if (_permissionGranted != PermissionStatus.granted) {
      final PermissionStatus permissionRequestedResult =
          await location.requestPermission();
      setState(() {
        _permissionGranted = permissionRequestedResult;
      });
      if (permissionRequestedResult != PermissionStatus.granted) {
        return;
      }
    }
  }

  addToList() async {
    GeoFirePoint point = geo.point(
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
    );
    Firestore.instance.collection('markers').add({
      'location': point.data,
      'date': DateTime.now().millisecondsSinceEpoch
    });
  }

  addToStation() async {
    GeoFirePoint point = geo.point(
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
    );
    Firestore.instance.collection('station').add({
      'location': point.data,
      'name': _name,
    });
  }

  remove() async {}

  checkDist() async {
    var pos = await location.getLocation();
    geo = Geoflutterfire();
    GeoFirePoint center =
        geo.point(latitude: pos.latitude, longitude: pos.longitude);
    stream = radis.switchMap((rad) {
      var collectionReference = Firestore.instance.collection('markers');
      return geo.collection(collectionRef: collectionReference).within(
          center: center, radius: 1, field: 'location', strictMode: true);
    });
  }

  String validateStation(String value) {
    if (value.isEmpty) {
      return 'Enter the Name of this station';
    } else if (value.length < 5)
      return 'Enter a valid Name\n5 or more characters';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    LatLng pinPosition = LatLng(-0.4250893, 36.9535040);
    CameraPosition initialLocation;
    if (currentLocation != null) {
      initialLocation = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: zoomSize,
          tilt: tiltAngle,
          bearing: bearingAngle);
    } else {
      initialLocation = CameraPosition(zoom: zoomSize, target: pinPosition);
    }
    return new WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, '/');
        return null;
      },
      child: Scaffold(
        drawer: SideBar(
          logoutCallback: widget._signOut,
        ),
        appBar: new AppBar(
          title: Text(
            'Map',
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
        body: Stack(
          children: <Widget>[
            StreamBuilder(
              stream: Firestore.instance.collection('markers').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text('Loading maps.. Please Wait'),
                  );
                } else if (snapshot.hasData) {
                  for (int i = 0; i < snapshot.data.documents.length; i++) {
                    if (DateTime.now().millisecondsSinceEpoch -
                            snapshot.data.documents[i]['date'] >
                        2419200000) {
                      crudObj.deleteData(snapshot.data.documents[i].documentID);
                    }
                    final String circleIdVal = 'case_id_$i';
                    _circles.add(Circle(
                        circleId: CircleId(circleIdVal),
                        center: new LatLng(
                            snapshot.data.documents[i]['location']['geopoint']
                                .latitude,
                            snapshot.data.documents[i]['location']['geopoint']
                                .longitude),
                        radius: radius,
                        fillColor: kDeathColor.withOpacity(0.7),
                        strokeWidth: 3,
                        strokeColor: kDeathColor,
                        onTap:
                            () {} //crudObj.deleteData(snapshot.data.documents[i].documentID)
                        ));
                  }
                }
                return StreamBuilder(
                  stream: Firestore.instance.collection('station').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    } else if (snapshot.hasData) {
                      for (int i = 0; i < snapshot.data.documents.length; i++) {
                        _markers.add(Marker(
                            icon: stationLocationIcon,
                            markerId:
                                MarkerId(snapshot.data.documents[i]['name']),
                            position: LatLng(
                                snapshot
                                    .data
                                    .documents[i]['location']['geopoint']
                                    .latitude,
                                snapshot
                                    .data
                                    .documents[i]['location']['geopoint']
                                    .longitude),
                            draggable: false,
                            infoWindow: InfoWindow(
                                title: snapshot.data.documents[i]['name'])));
                      }
                    }
                    return GoogleMap(
                      myLocationEnabled: true,
                      tiltGesturesEnabled: true,
                      compassEnabled: false,
                      mapType: MapType.hybrid,
                      mapToolbarEnabled: true,
                      circles: _circles,
                      markers: _markers,
                      initialCameraPosition: initialLocation,
                      zoomControlsEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        // controller.setMapStyle(Utils.mapStyles);
                        _controller.complete(controller);
                        //  / checkDist();
                        setState(() {
                          stream.listen((List<DocumentSnapshot> documentList) {
                            if (documentList != null) {
                              crudObj.createOrUpdateUserData({
                                'aColor': 4294920264,
                                'date': DateTime.now().millisecondsSinceEpoch
                              });
                            }
                          });
                        });
                      },
                      onTap: (point) {
                        setState(() {
                          // _setCircles(point);
                        });
                      },
                      onLongPress: (point) {
                        // crudObj.deleteData(snapshot.data.documents.documentID);
                      },
                      onCameraMove: (CameraPosition cameraPosition) {
                        setState(() {
                          zoomSize = cameraPosition.zoom;
                          bearingAngle = cameraPosition.bearing;
                          tiltAngle = cameraPosition.tilt;
                        });
                      },
                    );
                  },
                );
              },
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 80.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: MaterialButton(
                      color: kRecovercolor,
                      padding: EdgeInsets.all(16),
                      shape: CircleBorder(),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white.withOpacity(0.85),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "This area (Current Location) will be added as a testing facility.\n\n Are you sure you want to proceed?\n",
                                      style: TextStyle(color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                    Form(
                                      key: _formKey,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              hintText: 'Station Name'),
                                          keyboardType: TextInputType.text,
                                          onSaved: (value) => _name = value,
                                          validator: validateStation,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
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
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            onPressed: () {
                                              if (_formKey.currentState
                                                  .validate()) {
                                                _formKey.currentState.save();
                                                addToStation();
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
                                              style: TextStyle(
                                                  color: Colors.black),
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
                      // tooltip: 'Increment',
                      child: Icon(Icons.healing),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
                                "This area (Current Location) will be recorded as one with a confirmed covid-19 case.\n All people within 100m radius will be put under mandatory lockdown and observation for 14-21 days.\n\n Are you sure you want to proceed?\n",
                                style: TextStyle(color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                        addToList();
                                        Navigator.of(context).pop();
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
      ),
    );
  }

  Widget stationMarkers() {
    return StreamBuilder(
        stream: Firestore.instance.collection('station').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return null;
          } else if (snapshot.hasData) {
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              _marker.add(Marker(
                  icon: pinLocationIcon,
                  markerId: MarkerId(snapshot.data.documents[i]['name']),
                  position: LatLng(
                      snapshot
                          .data.documents[i]['location']['geopoint'].latitude,
                      snapshot
                          .data.documents[i]['location']['geopoint'].longitude),
                  draggable: false,
                  infoWindow:
                      InfoWindow(title: snapshot.data.documents[i]['name'])));
            }
          }
          return null;
        });
  }
}
