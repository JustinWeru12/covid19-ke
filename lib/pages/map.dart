import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid19/pages/sidebar.dart';
import 'package:covid19/services/authentication.dart';
import 'package:covid19/style/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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
  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  LocationData currentLocation;
  Set<Circle> _circles = HashSet<Circle>();
  StreamSubscription<LocationData> locationsubs;
  List<LatLng> latLng = List<LatLng>();
  double radius = 100.0;
  double zoomSize = 10;
  double tiltAngle = 80;
  double bearingAngle = 30;
  bool _isCircle = true;
  int _circleIdCounter = 1;
  String _error;
  var pos;

  @override
  void initState() {
    super.initState();
    location = new Location();
    locationsubs = location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
    });
    setCustomMapPin();
    _circles.clear();
    _checkLocationPermission();
    _requestPermission();
    _locationData = widget.location;
    initialLocation();
  }

  @override
  void dispose() {
    locationsubs.cancel();
    super.dispose();
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

  void _setCircles(LatLng point) {
    final String circleIdVal = 'case_id_$_circleIdCounter';
    _circleIdCounter++;
    _circles.add(Circle(
        circleId: CircleId(circleIdVal),
        center: point,
        radius: radius,
        fillColor: kDeathColor.withOpacity(0.7),
        strokeWidth: 3,
        strokeColor: kDeathColor));
  }

  addToList() async {
    Firestore.instance.collection('markers').add({
      'location':
          new GeoPoint(currentLocation.latitude, currentLocation.longitude),
    });
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
    return Scaffold(
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
      body: StreamBuilder(
        stream: Firestore.instance.collection('markers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('Loading maps.. Please Wait'),
            );
          }
          for (int i = 0; i < snapshot.data.documents.length; i++) {
            final String circleIdVal = 'case_id_$i';
            _circles.add(Circle(
                circleId: CircleId(circleIdVal),
                center: new LatLng(
                    snapshot.data.documents[i]['location'].latitude,
                    snapshot.data.documents[i]['location'].longitude),
                radius: radius,
                fillColor: kDeathColor.withOpacity(0.7),
                strokeWidth: 3,
                strokeColor: kDeathColor));
          }
          return GoogleMap(
            myLocationEnabled: true,
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
              setState(() {
                // _markers.add(Marker(
                //     markerId: MarkerId('<MARKER_ID>'),
                //     position: currentLocation,
                //     icon: pinLocationIcon));
              });
            },
            onTap: (point) {
              setState(() {
                _setCircles(point);
              });
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
    );
  }
}
