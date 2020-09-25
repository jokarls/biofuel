import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Tanka HVO100'),
            backgroundColor: Colors.green[700],
          ),
          body: StationsMap()
      ),
    );
  }
}

class StationsMap extends StatefulWidget {

  @override
  State createState() => StationsMapState();
}

class StationsMapState extends State<StationsMap> {

  final Firestore firestore = Firestore.instance;

  final _markers = <MarkerId, Marker>{};
  final _center = const LatLng(62.2808548, 16.5867504);
  final _zoom = 5.2;

  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    firestore.collection('stations').getDocuments().then((snapshot) => {
      snapshot.documents.forEach((document) {
        final markerId = MarkerId(document.documentID);
        final GeoPoint location = document.data['location'];
        final marker = Marker(
            markerId: markerId,
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: document.data['brand'] + ' ' + document.data['name'],
              snippet: document.data['street'] + ' ' + document.data['city']
            )
        );
        setState(() {
          _markers[markerId] = marker;
        });
      })
    });
  }

  @override
  Widget build(BuildContext context) {

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: _zoom,
      ),
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      compassEnabled: true,
      mapToolbarEnabled: true,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
      rotateGesturesEnabled: true,
      markers: _markers.values.toSet()
    );
  }
}
