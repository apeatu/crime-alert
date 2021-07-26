import 'dart:io';

import 'package:crime_alert/bloc/crime_alert_bloc.dart';
import 'package:crime_alert/bloc/crime_alert_event.dart';
import 'package:crime_alert/bloc/crime_alert_state.dart';
import 'package:crime_alert/constants/assets.dart';
import 'package:crime_alert/model/crime_location.dart';
import 'package:crime_alert/resources/firebase_repository.dart';
import 'package:crime_alert/resources/google_map_location_picker.dart';
import 'package:crime_alert/utils/general_methods.dart';
import 'package:crime_alert/widgets/progress_indicator_widget.dart';
import 'package:crime_alert/widgets/slide_into_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:flutter_geocoder/geocoder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseRepository _firebaserepository = FirebaseRepository();
  TextEditingController nameController = TextEditingController();
  late GoogleMapController mapController;
  late AnimationController newCrimeController;
  bool _isSaving = false;
  var _address;

  LatLng _currentLocation = LatLng(52.172249, 9.187372);

  final Map<String, Marker> _markers = {};

  var _image;

  Future getImage(BuildContext context, ImgSource source) async {
    var image = await ImagePickerGC.pickImage(
      enableCloseButton: true,
      closeIcon: Icon(
        Icons.close,
        color: Colors.red,
        size: 12,
      ),
      context: context,
      source: source,
      barrierDismissible: true,
      cameraIcon: Icon(
        Icons.camera_alt,
        color: Colors.red,
      ),
      cameraText: Text(
        'From Camera',
        style: TextStyle(color: Colors.deepOrange.shade400),
      ),
      galleryText: Text(
        'From Gallery',
        style: TextStyle(color: Colors.blue),
      ),
    );
    setState(() {
      _image = image;
    });
    if (image != null) {
      await _firebaserepository.uploadImage(context, image);
      print('_image ### ' + _image.path);
    }
  }

  Future<void> _onMapCreated(
      BuildContext context, GoogleMapController controller) async {
    mapController = controller;
    BlocProvider.of<CrimeAlertBloc>(context).add(CrimeAlertStartEvent());
    setState(() {
      _markers.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    newCrimeController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 500,
      ),
    );
  }

  void clearData() {
    _markers.clear();
  }

  Future addCrimeLocations(
      List<CrimeLocation> crimeLocations, LatLng currentLocation) async {
    await mapController.moveCamera(CameraUpdate.newLatLng(currentLocation));
    _markers.clear();
    await Future.wait(crimeLocations.map((crimeLocation) async {
      var redMarkerIcon = await getBytesFromAsset(Assets.redMarker, 100);
      var orangeMarkerIcon = await getBytesFromAsset(Assets.orangeMarker, 100);
      var greenMarkerIcon = await getBytesFromAsset(Assets.greenMarker, 100);
      var descriptor;
      if (crimeLocation.reportNumber > 20) {
        descriptor = BitmapDescriptor.fromBytes(redMarkerIcon);
      } else if (crimeLocation.reportNumber > 5 &&
          crimeLocation.reportNumber < 20) {
        descriptor = BitmapDescriptor.fromBytes(orangeMarkerIcon);
      } else {
        descriptor = BitmapDescriptor.fromBytes(greenMarkerIcon);
      }
      final marker = Marker(
        markerId: MarkerId(crimeLocation.name),
        position: LatLng(crimeLocation.lat, crimeLocation.lng),
        infoWindow: InfoWindow(
          title: crimeLocation.name,
          snippet: crimeLocation.address,
        ),
        icon: descriptor,
      );
      _markers[crimeLocation.name] = marker;
    }));
    setState(() {});
  }

  Future<void> _onSave(
      BuildContext context, AnimationController newCrimeController) async {
    await newCrimeController.reverse();
    setState(() {
      _isSaving = true;
    });
    var address = (await getUserLocation(
            _currentLocation.latitude, _currentLocation.longitude))
        .subLocality;
    await _firebaserepository.addNewCrimeLocationtoDb(
        context,
        CrimeLocation(nameController.text, _address, 1, '',
            _currentLocation.latitude, _currentLocation.longitude));
    setState(() {
      _isSaving = false;
    });
  }

  Future<Address> getUserLocation(double latitude, double longitude) async {
    final coordinates = Coordinates(latitude, longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print(
        ' ${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');
    setState(() {
      _address = first;
    });
    return first;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrimeAlertBloc, CrimeAlertState>(
        listener: (context, state) {
          if (state is CrimeAlertNotSelectedState) {
            addCrimeLocations(state.crimeLocations, state.currentLocation);
            setState(() {
              _currentLocation = state.currentLocation;
            });
          }
        },
        child: Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text('Crime Alert'),
                backgroundColor: Colors.grey,
              ),
              body: GoogleMap(
                onMapCreated: (controller) =>
                    _onMapCreated(context, controller),
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: _currentLocation,
                  zoom: 2.0,
                ),
                markers: _markers.values.toSet(),
              ),
              floatingActionButton:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: () {
                    mapController
                        .moveCamera(CameraUpdate.newLatLng(_currentLocation));
                  },
                  heroTag: null,
                  child: Icon(
                    Icons.location_searching,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                FloatingActionButton(
                  backgroundColor: Colors.deepOrange.shade400,
                  onPressed: () {
                    newCrimeController.forward();
                  },
                  heroTag: null,
                  child: Icon(Icons.add),
                )
              ]),
            ),
            SlideInToView(
              newCrimeController,
              Material(
                child: InkWell(
                  onDoubleTap: () => newCrimeController.reverse(),
                  child: Container(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.8),
                              offset: const Offset(4, 4),
                              blurRadius: 8),
                        ],
                      ),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              height: kToolbarHeight * 1.5,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          newCrimeController.reverse();
                                        },
                                      ),
                                      Text(
                                        'New Crime',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        _onSave(context, newCrimeController),
                                    child: Text(
                                      'SAVE',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: 'Enter Title',
                                  hintText: 'Enter Title'),
                              controller: nameController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                setState(() {
                                  // _title = value;
                                });
                              },
                            ),
                            Row(
                              children: [
                                Text(_image != null ? _image.path.split().last : 'No Image Selected'),
                                SizedBox(
                                  width: 8,
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      getImage(context, ImgSource.Both),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.deepOrange.shade400,
                                  ),
                                  child: Text(
                                    'Upload Image'.toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.black12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_address ??
                                          'Search for location on map '),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      IconButton(
                                          icon: Icon(Icons.search),
                                          onPressed: () => showLocationPicker(
                                                context,
                                                Platform.isAndroid
                                                    ? 'AIzaSyCb6G_LBCa8dEZWBFL8oNxAfJOvaOjthCI'
                                                    : '',
                                                initialCenter: _currentLocation,
                                                myLocationButtonEnabled: true,
                                                countries: ['AE', 'GH'],
                                              )),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                InkWell(
                                  onTap: () {
                                    getUserLocation(_currentLocation.latitude, _currentLocation.longitude);
                                  },
                                  child: Text(
                                    'Or use current location'.toUpperCase(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _isSaving,
              child: CustomProgressIndicatorWidget(),
            )
          ],
        ));
  }
}
