import 'dart:async';
import 'dart:developer';
import 'package:dr_ai/core/constant/color.dart';
import 'package:dr_ai/core/helper/location.dart';
import 'package:dr_ai/data/model/place_directions.dart';
import 'package:dr_ai/data/model/place_location.dart';
import 'package:dr_ai/view/widget/directions_details_card.dart';
import 'package:dr_ai/view/widget/floating_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../logic/maps/maps_cubit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    await LocationHelper.determineCurrentPosition();
    position = await Geolocator.getCurrentPosition().whenComplete(() {
      setState(() {});
    });
  }

  Completer<GoogleMapController> mapController = Completer();
  static Position? position;
  static final CameraPosition myCurrrentPositionCameraPosition = CameraPosition(
      bearing: 0,
      target: LatLng(position!.latitude, position!.longitude),
      tilt: 0.0,
      zoom: 17);

//!
  Set<Marker> markers = {};
  late String? placeSuggestion;
  late PlaceLocationModel selectedPlace;
  late Marker searchedPlaceMarker;
  late CameraPosition goToSearchedForPlace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            position != null
                ? buildMap()
                : Container(
                    alignment: Alignment.center,
                    width: 50.w,
                    height: 50.w,
                    decoration: const BoxDecoration(
                      color: ColorManager.white,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 25.w,
                      height: 25.w,
                      child: const CircularProgressIndicator(
                        strokeCap: StrokeCap.round,
                        color: ColorManager.green,
                      ),
                    ),
                  ),
            buildSelectedPlaceLocation(),
            isSearchedPlaceMarkerClicked
                ? DistanceAndTime(
                    isTimeAndDistanceVisible: isTimeAndDistanceVisible,
                    placeDirections: placeDirections)
                : Container(),
            buildPlaceDiretions(),
            const MyFloatingSearchBar(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          splashColor: ColorManager.white.withOpacity(0.3),
          backgroundColor: ColorManager.green,
          heroTag: 1,
          onPressed: goToMyCurrentLocation,
          child: const Icon(
            Icons.zoom_in_map_rounded,
            color: ColorManager.white,
          ),
        ));
  }

  void buildCameraNewPosition() {
    isSearchedPlaceMarkerClicked = false;
    log("${selectedPlace.lat}  ${selectedPlace.lng}");
    goToSearchedForPlace = CameraPosition(
      bearing: 0.0,
      tilt: 0.0,
      target: LatLng(
        selectedPlace.lat,
        selectedPlace.lng,
      ),
      zoom: 13,
    );
    setState(() {});
  }

  Widget buildMap() {
    return GoogleMap(
      markers: markers,
      initialCameraPosition: CameraPosition(
        target: LatLng(position!.latitude, position!.longitude),
        zoom: 15.0,
      ),
      circles: {
        Circle(
          circleId: const CircleId("current_location"),
          center: LatLng(position!.latitude, position!.longitude),
          radius: 25,
          fillColor: MyColors.blue.withOpacity(0.3),
          strokeColor: MyColors.blue.withOpacity(0.4),
          strokeWidth: 2,
        ),
      },
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        mapController.complete(controller);
      },
      polylines: placeDirections != null
          ? {
              Polyline(
                geodesic: true,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
                jointType: JointType.round,
                polylineId: const PolylineId('polyline'),
                color: ColorManager.error,
                width: 5,
                points: polylinePoints,
              ),
            }
          : {},
    );
  }

  Future<void> goToMyCurrentLocation() async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(myCurrrentPositionCameraPosition));
  }

  Widget buildSelectedPlaceLocation() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is MapsLoadedLocationSuccess) {
          selectedPlace = state.placeLocation[0];
          placeDirections = null;
          setState(() {});
          placeSuggestion = state.placeLocation[1];
          log(selectedPlace.toString());
          goToMySearchedForLocation();
        }
      },
      child: Container(),
    );
  }

  Future<void> goToMySearchedForLocation() async {
    buildCameraNewPosition();
    final GoogleMapController controller = await mapController.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(goToSearchedForPlace));
    buildSearchedPlaceMarker();
  }

  void buildSearchedPlaceMarker() {
    searchedPlaceMarker = Marker(
      position: goToSearchedForPlace.target,
      markerId: const MarkerId('1'),
      onTap: () {
        isSearchedPlaceMarkerClicked = true;
        isTimeAndDistanceVisible = true;
        getDirections();
        setState(() {});
      },
      infoWindow: InfoWindow(title: placeSuggestion),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    addMarkerToMarkersAndUpdateUI(searchedPlaceMarker);
  }

  void addMarkerToMarkersAndUpdateUI(Marker marker) {
    markers = {};
    setState(() {
      markers.add(marker);
    });
  }

  PlaceDirectionsModel? placeDirections;
  bool progressIndicator = false;
  late List<LatLng> polylinePoints;
  bool isSearchedPlaceMarkerClicked = false;
  bool isTimeAndDistanceVisible = false;
  late String time;
  late String distance;

  Widget buildPlaceDiretions() {
    placeDirections = null;
    setState(() {});
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is MapsLoadedDirectionsSuccess) {
          placeDirections = state.placeDirections;
          getPolylinePoints();
        }
      },
      child: Container(),
    );
  }

  void getPolylinePoints() {
    polylinePoints = [];
    polylinePoints = placeDirections!.polylinePoints
        .map((polyline) => LatLng(polyline.latitude, polyline.longitude))
        .toList();
  }

  /// call
  Future<void> getDirections() async {
    await BlocProvider.of<MapsCubit>(context).getPlaceDirections(
      origin: LatLng(position!.latitude, position!.longitude),
      destination: LatLng(selectedPlace.lat, selectedPlace.lng),
    );
    setState(() {});
  }
}
