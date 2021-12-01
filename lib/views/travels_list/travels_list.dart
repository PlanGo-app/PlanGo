import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:plango_front/model/travel.dart';
import 'package:plango_front/service/travel_service.dart';
import 'package:plango_front/util/constant.dart';
import 'package:plango_front/util/loading.dart';
import 'package:plango_front/util/storage.dart';
import 'package:plango_front/views/components/small_rounded_button.dart';
import 'package:plango_front/views/create_travel/create_travel.dart';
import 'package:plango_front/views/join_travel/join_page.dart';
import 'package:plango_front/views/screen/screen.dart';
import 'package:plango_front/views/sharing/sharing_page.dart';

class TravelsList extends StatefulWidget {
  TravelsList({Key? key}) : super(key: key);

  @override
  _TravelsListState createState() => _TravelsListState();
}

class _TravelsListState extends State<TravelsList> {
  @override
  Widget build(BuildContext context) {
    Storage.getToken()
        .then((value) => print("aaaaaaaaaaaaaaaaaaa" + value.toString()));
    TravelService().getTravels();

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Image.asset(
              "assets/image/plango_title.png",
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              width: 330,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Scaffold(
                backgroundColor: Colors.white60,
                body: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: FutureBuilder<List<Travel>>(
                    future: TravelService().getTravels(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Travel>> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Loading();
                        default:
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return const Center(
                              child: Text(
                                'Impossible de recupérer vos voyages pour le moment',
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else if (snapshot.data!.isEmpty) {
                            return Center(child: const Text('Aucun voyage'));
                          } else {
                            // return Text(snapshot.data!);
                            print(snapshot.data![0].id);
                            return TravelsListBuilder(
                                dateFormat: dateFormat, snapshot: snapshot);
                          }
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                      ),
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          height: 300,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    child: Text(
                                      "Voulez-vous créer ou rejoindre un plan?",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 30, color: kPrimaryColor),
                                      textAlign: TextAlign.center,
                                    )),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  margin: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SmallRoundedButton(
                                          text: "Rejoindre",
                                          press: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) =>
                                                      JoinPage(),
                                                ));
                                          }),
                                      SmallRoundedButton(
                                          text: "Créer",
                                          press: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) =>
                                                      const CreateTravel(),
                                                ));
                                          }),
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 3,
                                child: SmallRoundedButton(
                                    text: "Annuler",
                                    press: () {
                                      Navigator.pop(context);
                                    }),
                              ),
                            ],
                          ),
                        );
                      });
                },
                iconSize: 60,
                icon: const Icon(
                  Icons.add_circle,
                  color: kPrimaryLightColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Future<String> _loadTravelsAssets() async {
  //   return await rootBundle
  //       .loadString('assets/travels.json'); // return your response
  // }

  // Future<List<Travel>> loadTravels() async {
  //   await Future.delayed(const Duration(seconds: 1), () => {});
  //   String jsonString = await _loadTravelsAssets();
  //   final jsonResponse = json.decode(jsonString);
  //   List<Travel> travels = [];
  //   for (dynamic travel in jsonResponse) {
  //     travels.add(Travel.fromJson(travel));
  //   }
  //   return travels;
  // }
}

class TravelsListBuilder extends StatelessWidget {
  const TravelsListBuilder({
    Key? key,
    required this.dateFormat,
    required this.snapshot,
  }) : super(key: key);

  final DateFormat dateFormat;
  final AsyncSnapshot<List<Travel>> snapshot;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          return Container(
            color: kPrimaryColor,
            margin: const EdgeInsets.only(bottom: 1.0),
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      snapshot.data![index].city +
                          " ( " +
                          snapshot.data![index].country +
                          " )",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        dateFormat.format(snapshot.data![index].date_start) +
                            " -- " +
                            dateFormat.format(snapshot.data![index].date_end),
                        style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Screen(
                            city: snapshot.data![index].city,
                            country: snapshot.data![index].country,
                            date: snapshot.data![index].date_start,
                            endDate: snapshot.data![index].date_end),
                      ));
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  color: Colors.white,
                  onPressed: () {
                    print(snapshot.data![index].invitationCode);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (
                            context,
                          ) =>
                              SharingPage(
                                  invitationCode:
                                      snapshot.data![index].invitationCode),
                        ));
                  },
                ),
              ],
            ),
          );
        });
  }
}
