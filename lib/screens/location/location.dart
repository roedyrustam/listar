import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:listar/models/model.dart';
import 'package:listar/utils/utils.dart';

class Location extends StatefulWidget {
  final LocationModel location;

  const Location({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  _LocationState createState() {
    return _LocationState();
  }
}

class _LocationState extends State<Location> {
  final _markers = <MarkerId, Marker>{};

  CameraPosition _initPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _onLoadMap();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///On load map
  void _onLoadMap() {
    final markerId = MarkerId(widget.location.name);
    final position = LatLng(
      widget.location.latitude,
      widget.location.longitude,
    );
    final marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: widget.location.name),
    );

    setState(() {
      _initPosition = CameraPosition(
        target: position,
        zoom: 14.4746,
      );
      _markers[markerId] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('location'),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: _initPosition,
        markers: Set<Marker>.of(_markers.values),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
