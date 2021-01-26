import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'naliGATOR',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'naliGATOR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _index = 0;
  Completer<GoogleMapController> _controller = Completer();

  LatLng _initCenter = const LatLng(45.521563, -122.677433);

  CameraPosition _initPos;

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _getCurrentLocation().then((value)=>goToThePos());
    // _determinePosition().then((value) =>
    //     setState(() => _center = LatLng(value.latitude, value.longitude)));
  }

  Future<void> _getCurrentLocation() async {
    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _initCenter = LatLng(pos.latitude, pos.longitude);
    _initPos = CameraPosition(
    bearing: 0,
    target: LatLng(pos.latitude, pos.longitude),
    tilt: 0,
    zoom: 15);
  }

  Future<void> goToThePos() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_initPos));
  }

  void _setIndex(int newIndex) {
    setState(() {
      _index = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _index == 0
          ? GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initCenter,
                zoom: 11.0,
              ),
              myLocationEnabled: true,
              compassEnabled: true,
            )
          : Center(),
      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.white,
          selectedItemBackgroundColor: Colors.green,
          selectedItemIconColor: Colors.white,
          selectedItemLabelColor: Colors.black,
        ),
        selectedIndex: _index,
        onSelectTab: _setIndex,
        items: [
          FFNavigationBarItem(
            iconData: Icons.map,
            label: 'Map',
          ),
          FFNavigationBarItem(
            iconData: Icons.remove_red_eye,
            label: 'View',
          ),
        ],
      ),
    );
  }
}
