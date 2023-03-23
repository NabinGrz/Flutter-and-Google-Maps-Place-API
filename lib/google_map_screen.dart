import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemapplaceapi/repository/repo.dart';

import 'model/place_model/place_model.dart';

Color color = const Color(0xfffe8903);

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late final BitmapDescriptor currentLocation;
  TextEditingController placeController = TextEditingController();

  late final GoogleMapController _controller;
  Position? _currentPosition;

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  getLocation() async {
    // WidgetsBinding.instance.addPostFrameCallback((_) async {

    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {});
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(48, 48)),
            'assets/images/currentLocation.png')
        .then((onValue) {
      currentLocation = onValue;
    });
    // });
  }

  Widget autoComplete() {
    return Container(
      // height: 50,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.8),
                blurRadius: 8.0,
                spreadRadius: 1,
                offset: const Offset(0, 4))
          ],
          borderRadius: BorderRadius.circular(12)),
      child: TypeAheadFormField<Description?>(
        onSuggestionSelected: (suggestion) {
          setState(() {
            placeController.text =
                suggestion?.structured_formatting?.main_text ?? "";
          });
        },
        getImmediateSuggestions: true,
        keepSuggestionsOnLoading: false,
        textFieldConfiguration: TextFieldConfiguration(
            controller: placeController,
            style: GoogleFonts.poppins(),
            decoration: InputDecoration(
              isDense: false,
              fillColor: Colors.transparent,
              filled: false,
              prefixIcon: Icon(CupertinoIcons.search, color: color),
              suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      placeController.clear();
                    });
                  },
                  child: const Icon(Icons.clear, color: Colors.red)),
              // contentPadding:
              //     const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              hintText: "Where are you going?",
              hintStyle: GoogleFonts.lato(),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            )),
        itemBuilder: (context, Description? itemData) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${itemData?.structured_formatting?.main_text}",
                      style: const TextStyle(color: Colors.green),
                    ),
                    Text("${itemData?.structured_formatting?.secondary_text}"),
                    const Divider()
                  ],
                ),
              ],
            ),
          );
        },
        noItemsFoundBuilder: (context) {
          return Wrap(
            children: const [
              Center(
                  heightFactor: 2,
                  child: Text(
                    "Location Not Found!!",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  )),
            ],
          );
        },
        suggestionsCallback: (String pattern) async {
          var predictionModel =
              await Repo.placeAutoComplete(placeInput: pattern);

          if (predictionModel != null) {
            return predictionModel.predictions!.where((element) => element
                .description!
                .toLowerCase()
                .contains(pattern.toLowerCase()));
          } else {
            return [];
          }
        },
      ),
    );
  }

  Widget locationsWidget() {
    return Container(
      margin: EdgeInsets.zero,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Colors.grey,
              blurRadius: 10.0,
              spreadRadius: 1,
              offset: Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(
                  width: 8,
                ),
                Wrap(
                  direction: Axis.vertical,
                  children: const [
                    Text(
                      "Current Location",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Samakhusi, Rehdon College",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 20),
              child: Divider(
                height: 8,
                color: color.withOpacity(0.6),
              ),
            ),
            Row(
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                      border: Border.all(color: color, width: 4),
                      shape: BoxShape.circle),
                ),
                const SizedBox(
                  width: 8,
                ),
                Wrap(
                  direction: Axis.vertical,
                  children: [
                    const Text(
                      "Destination",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: Text(
                        placeController.text.isEmpty
                            ? "Select Destination"
                            : placeController.text,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: _currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                      zoom: 16,
                      target: LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude)),
                  onMapCreated: (controller) async {
                    setState(() {
                      _controller = controller;
                    });
                    String val = "json/google_map_dark_theme.json";
                    var c = await rootBundle.loadString(val);
                    _controller.setMapStyle(c);
                  },
                  markers: {
                    Marker(
                        markerId: const MarkerId("1"),
                        icon: currentLocation,
                        position: LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude))
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 70),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        autoComplete(),
                        const SizedBox(
                          height: 12,
                        ),
                        locationsWidget(),
                        const Spacer(),
                        confirmButton(),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget confirmButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(double.infinity, 40)),
        onPressed: () {
          // _controller.animateCamera(CameraUpdate.newCameraPosition(
          //     const CameraPosition(target: LatLng(0, 0))));
        },
        child: Text(
          "CONFIRM",
          style: GoogleFonts.lato(fontSize: 18),
        ));
  }
}
