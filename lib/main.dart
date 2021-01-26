import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'textField.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARiGATOR',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'ARiGATOR'),
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

  String API_KEY = "AIzaSyDmWkyo2MbQ5Aa-i0bgKdCjpOWJTWDmNMw";

  GoogleMapController mapController;

  final destAddressController = TextEditingController();
  Position _startCoordinates;

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _startCoordinates = position;
      });
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18.0,
          ),
        ),
      );
    }).catchError((e) {
      print(e);
    });
  }

  void _setIndex(int newIndex) {
    setState(() {
      _index = newIndex;
    });
  }

  String _currentAddress;
  String _destinationAddress = '';
  Position _destCoordinates;

  Future<void> _getDestAddress() async {
    try {
      // Places are retrieved using the coordinates
      List<Address> p =
          await Geocoder.google(API_KEY)
              .findAddressesFromQuery(_destinationAddress);

      setState(() {
        _destCoordinates = Position(
            latitude: p[0].coordinates.latitude,
            longitude: p[0].coordinates.longitude);

        destAddressController.text = _currentAddress;

        _destinationAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  Position _northeastCoordinates;
  Position _southwestCoordinates;

  void _BuildPath() async {
    Marker startMarker = Marker(
      markerId: MarkerId('$_startCoordinates'),
      position: LatLng(
        _startCoordinates.latitude,
        _startCoordinates.longitude,
      ),
      infoWindow: InfoWindow(
        title: 'Start',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker;
    _getDestAddress().then((value) {
      destinationMarker = Marker(
        markerId: MarkerId('$_destCoordinates'),
        position: LatLng(
          _destCoordinates.latitude,
          _destCoordinates.longitude,
        ),
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      if (_startCoordinates.latitude <= _destCoordinates.latitude) {
        _southwestCoordinates = _startCoordinates;
        _northeastCoordinates = _destCoordinates;
      } else {
        _southwestCoordinates = _destCoordinates;
        _northeastCoordinates = _startCoordinates;
      }

      setState(() {
        markers = {};
        markers.add(destinationMarker);
        markers.add(startMarker);
      });

      mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
              ),
            ),
            100.0, // padding
          )
      );

      _createPolylines(_startCoordinates, _destCoordinates);
    });
  }

  Set<Marker> markers = {};
  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _createPolylines(Position start, Position destination) async {
    polylinePoints = PolylinePoints();
    polylineCoordinates = [];
    polylines = {};

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      API_KEY,
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.green,
      points: polylineCoordinates,
      width: 3,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _index == 0
          ? Stack(children: [
              GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  _destinationAddress == '' ? null : _BuildPath();
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(50.48, 30.5),
                  zoom: 11.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                markers: markers != null ? Set<Marker>.from(markers) : null,
                polylines: Set<Polyline>.of(polylines.values)
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white70,
                      ),
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(height: 10),
                            textField(
                                label: 'Destination',
                                hint: 'Type destination address',
                                initialValue: '',
                                width: width * 0.95,
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.navigate_next),
                                  onPressed: _BuildPath,
                                  color: Colors.green,
                                ),
                                // Icon(Icons.navigate_next,),
                                controller: destAddressController,
                                locationCallback: (String value) {
                                  setState(() {
                                    _destinationAddress = value;
                                  });
                                }),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ])
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
