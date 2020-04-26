import 'dart:async';
import 'dart:collection';

import 'package:covid19/pages/sidebar.dart';
import 'package:covid19/services/authentication.dart';
import 'package:covid19/style/theme.dart';
import 'package:covid19/widgets/counter.dart';
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
  Set<Circle> _circles = HashSet<Circle>();
  List<LatLng> latLng = List<LatLng>();
  double radius = 500.0;
  bool _isCircle = true;
  int _circleIdCounter = 1;
  StreamSubscription<LocationData> _locationSubscription;
  String _error;
  var pos;

  @override
  void initState() {
    super.initState();
    _listenLocation();
    setCustomMapPin();
    _circles.clear();
    _checkLocationPermission();
    _requestPermission();
    _locationData = widget.location;
    getLocation();
  }

  Future<void> getLocation() async {
    final LocationData _locationResult = await location.getLocation();
    setState(() {
    pos = _locationResult;
    print(pos);
    });
  }

  Future<void> _listenLocation() async {
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
      setState(() {
        _error = err.code;
      });
      _locationSubscription.cancel();
    }).listen((LocationData currentLocation) {
      setState(() {
        _error = null;

        _locationData = currentLocation;
      });
    });
  }

  Future<void> _stopListen() async {
    _locationSubscription.cancel();
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

  @override
  Widget build(BuildContext context) {
    LatLng pinPosition = LatLng(-0.4250893, 36.9535040);

    CameraPosition initialLocation =
        CameraPosition(zoom: 16, bearing: 30, target: pinPosition);
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
      body: GoogleMap(
        myLocationEnabled: true,
        compassEnabled: true,
        mapType: MapType.hybrid,
        mapToolbarEnabled: true,
        circles: _circles,
        markers: _markers,
        initialCameraPosition: initialLocation,
        onMapCreated: (GoogleMapController controller) {
          // controller.setMapStyle(Utils.mapStyles);
          _controller.complete(controller);
          setState(() {
            _markers.add(Marker(
                markerId: MarkerId('<MARKER_ID>'),
                position: pinPosition,
                icon: pinLocationIcon));
          });
        },
        onTap: (point) {
          setState(() {
            _setCircles(point);
          });
        },
      ),
    );
  }
}
