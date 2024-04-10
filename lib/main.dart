import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapmyindia/bloc/routing/routign_bloc.dart';
import 'package:mapmyindia/bloc/routing/routing_events.dart';
import 'package:mapmyindia/bloc/routing/routing_states.dart';
import 'package:mapmyindia/bloc/use_loc/user_location_bloc.dart';
import 'package:mapmyindia/bloc/use_loc/user_location_event.dart';
import 'package:mapmyindia/bloc/use_loc/user_location_states.dart';
import 'package:mapmyindia/components/routing.dart';
import 'package:mapmyindia/constants.dart';
import 'package:mappls_gl/mappls_gl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserLocationBloc>(
          create: (context) => UserLocationBloc(),
        ),
        BlocProvider<RoutingBloc>(
          create: (context) => RoutingBloc(null),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    MapplsAccountManager.setMapSDKKey(MAP_SDK_KEY);
    MapplsAccountManager.setRestAPIKey(REST_API_KEY);
    MapplsAccountManager.setAtlasClientId(ATLAS_CLIENT_ID);
    MapplsAccountManager.setAtlasClientSecret(ATLAS_CLIENT_SECRET);

    BlocProvider.of<UserLocationBloc>(context).add(InitUserLocation());
  }

  late MapplsMapController mapController;

  late double initialLatitude;
  late double initialLongitude;

  bool showSearch = false;

  List<String> selected = [
    "Current Location",
    "Select on Map",
    "Search Location",
    "Recent Searches",
    "Saved Places",
    "Home",
    "Work",
  ];

  TextEditingController destinationController = TextEditingController();
  TextEditingController sourceController = TextEditingController();
  List<LatLng> selectedPoints = [];
  addInitialMarker() async {
    await mapController.addSymbol(
      SymbolOptions(
        geometry: LatLng(initialLatitude, initialLongitude),
        iconSize: 0.5,
      ),
    );
  }

  List<NearbyResult> nearbyResult = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocConsumer<UserLocationBloc, UserLocationStates>(
            listener: (context, state) {
              if (state is UserLocationLoadedState) {
                if (state.locationData != null) {
                  print(
                      "Location: ${state.locationData!.latitude}, ${state.locationData!.longitude}");
                  setState(() {
                    // initialLatitude = state.locationData!.latitude!;
                    // initialLongitude = state.locationData!.longitude!;
                    initialLatitude = 23.1842;
                    initialLongitude = 72.6309;
                  });
                } else {
                  setState(() {
                    initialLatitude = 23.1842;
                    initialLongitude = 72.6309;
                  });
                }
              }
            },
            builder: (context, state) {
              if (state is UserLocationLoadedState) {
                return MapplsMap(
                  onMapClick: (point, coordinates) async {
                    print("Map Clicked: $coordinates");
                    if (selectedPoints.length < 2) {
                      setState(() {
                        selectedPoints.add(coordinates);
                      });

                      mapController.addSymbol(
                        SymbolOptions(
                          geometry: coordinates,
                          iconSize: 0.5,
                        ),
                      );
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(initialLatitude, initialLongitude),
                    zoom: 14.0,
                  ),
                  onMapCreated: (controller) {
                    setState(() {
                      mapController = controller;
                      BlocProvider.of<RoutingBloc>(context).mapController =
                          controller;
                    });
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          SizedBox.expand(
            child: DraggableScrollableSheet(
              maxChildSize: 0.7,
              initialChildSize: 0.3,
              builder: (context, controller) {
                return Container(
                  color: Colors.white,
                  child: ListView(
                    controller: controller,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          selectedPoints.length == 2
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: ()async{
                                          BlocProvider.of<RoutingBloc>(context).add(PointsSelectedEvent(selectedPoints));
                                        },
                                        child: const Text(
                                          "Generate Route",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.delete_forever_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container()
                        ],
                      ),
                      SourceAndDestinationInputForm(
                        onSearch: () {
                          BlocProvider.of<RoutingBloc>(context).add(
                              SearchLocationEvent(
                                  destinationController.text.toLowerCase(),
                                  initialLatitude,
                                  initialLongitude));
                        },
                        destinationController: destinationController,
                        onChanged: (value) {},
                      ),
                      BlocListener<RoutingBloc, RoutingState>(
                        listener: (context, state) {
                          if (state is SearchLoactionState) {
                            setState(() {
                              nearbyResult = state.nearbyResult!;
                            });
                          }
                        },
                        child: BlocBuilder<RoutingBloc, RoutingState>(
                          builder: (context, state) {
                            if (state is SearchLoactionState) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: state.nearbyResult!.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(state
                                              .nearbyResult![index].placeName ??
                                          ""),
                                      subtitle: Text(state.nearbyResult![index]
                                              .placeAddress ??
                                          ""),
                                      onTap: () {
                                        print(
                                            "Selected: ${state.nearbyResult![index].latitude}");
                                      },
                                    );
                                  });
                            }
                            return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: nearbyResult.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                        nearbyResult[index].placeName ?? ""),
                                    subtitle: Text(
                                        nearbyResult[index].placeAddress ?? ""),
                                    onTap: () {
                                      print(
                                          "Selected: ${nearbyResult[index].latitude}");
                                    },
                                  );
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SourceAndDestinationInputForm extends StatelessWidget {
  final Function(String) onChanged;
  final Function() onSearch;
  const SourceAndDestinationInputForm({
    super.key,
    required this.destinationController,
    required this.onChanged,
    required this.onSearch,
  });

  final TextEditingController destinationController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.76,
              child: TextField(
                onChanged: onChanged,
                controller: destinationController,
                decoration: InputDecoration(
                  hintText: "Search Destination Enter Key Words",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            IconButton(onPressed: onSearch, icon: const Icon(Icons.search)),
          ],
        ),
      ),
    );
  }
}
