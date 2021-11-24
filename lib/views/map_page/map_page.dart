import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:link_text/link_text.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'package:plango_front/model/place_info.dart';
import 'package:plango_front/views/map_page/map_view.dart';
import 'package:plango_front/views/nav_bar/nav_bar_bloc/nav_bar_bloc.dart';
import 'package:plango_front/views/nav_bar/search_text_field.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'map_page_bloc/map_page_bloc.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) => NavBarBloc(),
        ),
        BlocProvider(
          create: (BuildContext context) =>
              MapPageBloc(nvb: context.read<NavBarBloc>()),
        ),
      ],
      child: MapPageView(),
    );
  }
}

class MapPageView extends StatefulWidget {
  const MapPageView({
    Key? key,
  }) : super(key: key);

  @override
  _MapPageViewState createState() => _MapPageViewState();
}

class _MapPageViewState extends State<MapPageView> {
  @override
  Widget build(BuildContext context) {
    return MapViewBody();
  }
}

class MapViewBody extends StatefulWidget {
  const MapViewBody({Key? key}) : super(key: key);

  @override
  _MapViewBodyState createState() => _MapViewBodyState();
}

class _MapViewBodyState extends State<MapViewBody> {
  late PanelController panelController;
  MapView map = MapView();

  @override
  void initState() {
    super.initState();
    panelController = PanelController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapPageBloc, MapPageState>(builder: (context, state) {
      if (state is MapPagePanelState) {
        panelController.show();
        if (map.isReady) {
          map.mapController
              .move(LatLng(state.place!.lat, state.place!.lon), 16.0);
        }
      }

      return SlidingUpPanel(
        controller: panelController,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
        maxHeight: 300,
        panelBuilder: (sc) => _panel(sc, context, state.place),
        backdropEnabled: true,
        body: Column(
          children: [
            SafeArea(
                child: Material(elevation: 10000000, child: SearchTextField())),
            Expanded(child: map),
          ],
        ),
      );
    });
  }

  _panel(
    ScrollController sc,
    BuildContext context,
    Place? place,
  ) {
    if (place == null) {
      panelController.hide();
      return;
    }
    return FutureBuilder(
        future: getInfoPlace(place.osmType, place.osmId),
        builder: (BuildContext context, AsyncSnapshot<PlaceInfo> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      padding: EdgeInsets.only(top: 30),
                      child: CircularProgressIndicator()));
            default:
              if (snapshot.hasError) {
                panelController.hide();
                return Container();
              } else if (snapshot.data == null) {
                return const Text('Pas d\'info sur ce lieu');
              } else {
                return MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(18.0)),
                    ),
                    child: ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 9,
                                child: Container(
                                    padding: EdgeInsets.only(left: 15, top: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(snapshot.data!.name,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 25)),
                                        Text(snapshot.data!.street,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 15)),
                                        Text(snapshot.data!.city,
                                            style: GoogleFonts.montserrat(
                                                fontSize: 15,
                                                color: Colors.black)),
                                      ],
                                    ))),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          panelController.hide();
                                        }),
                                  ),
                                  Align(
                                      alignment: Alignment.bottomRight,
                                      child: IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () =>
                                            map.addMarker(snapshot.data!.point),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ListTile(
                            title: LinkText(
                          "Website : " +
                              (snapshot.data!.website.isNotEmpty
                                  ? snapshot.data!.website
                                  : "-"),
                          onLinkTap: (url) async {
                            if (await canLaunch(url)) {
                              await launch(
                                url,
                                forceSafariVC: false,
                              );
                            }
                          },
                        )),
                        ListTile(
                            title: Text("Prix : " +
                                (snapshot.data!.price.isNotEmpty
                                    ? snapshot.data!.price
                                    : "-"))),
                        ListTile(
                            title: Text("Heure d'ouverture : " +
                                (snapshot.data!.openingHours.isNotEmpty
                                    ? snapshot.data!.openingHours
                                    : "-"))),
                      ],
                    ),
                  ),
                );
              }
          }
        });
  }

  Future<PlaceInfo> getInfoPlace(osmType, osmId) async {
    var oType = osmType == "way"
        ? 'W'
        : osmType == "node"
            ? 'N'
            : 'R';
    Response r = await Dio().get(
        'https://nominatim.openstreetmap.org/details.php?osmtype=$oType&osmid=$osmId&format=json',
        options: Options(responseType: ResponseType.plain));
    return PlaceInfo.fromJson(json.decode(r.data));
  }
}
