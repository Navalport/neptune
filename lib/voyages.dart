import 'package:flutter/material.dart';
import 'package:mooringapp/defaultAppBar.dart';
import 'package:mooringapp/voyage.dart';
import 'package:mooringapp/interfaces.dart';
import 'package:mooringapp/login.dart';

import 'types.dart';

class DockingsWidget extends StatefulWidget {
  const DockingsWidget({Key? key}) : super(key: key);

  @override
  State<DockingsWidget> createState() => _DockingsWidgetState();
}

class _DockingsWidgetState extends State<DockingsWidget> {
  Future<List<Voyage>> _voyages$ = VoyageInterface.getVoyages();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Porto de Santos",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                IconButton(
                    onPressed: () async {
                      await AuthInterface.logOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginWidget()),
                        ModalRoute.withName(""),
                      );
                    },
                    icon: const Icon(Icons.logout))
              ],
            ),
          ),
          // Image.asset('assets/static_map.png'),
          // const SizedBox(height: 4),
          Expanded(
            child: FutureBuilder(
              future: _voyages$,
              builder: (context, AsyncSnapshot<List<Voyage>> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Text(snapshot.error.toString()),
                          IconButton(
                              onPressed: () async {
                                _voyages$ = VoyageInterface.getVoyages();
                                setState(() {});
                              },
                              icon: const Icon(Icons.refresh))
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final voyages = snapshot.data!;

                  return RefreshIndicator(
                    onRefresh: () async {
                      _voyages$ = VoyageInterface.getVoyages();
                      return _voyages$.onError((_, __) {
                        setState(() {});
                        return [];
                      }).then((_) => setState(() {}));
                    },
                    child: ListView.builder(
                      itemCount: voyages.length,
                      itemBuilder: (context, index) {
                        final voyage = voyages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: Card(
                            child: InkWell(
                              // onTap: () => Navigator.of(context).push(
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             DockingWidget(stage: voyage))),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(voyage.vessel_name ??
                                                  "Embarcação sem nome"),
                                              const SizedBox(height: 4),
                                              Text(voyage.voyage_desc ?? "N/D"),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("IMO: ${voyage.imo}"),
                                              const SizedBox(height: 4),
                                              Text("DUV: ${voyage.duv}"),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(Icons.chevron_right),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Center(
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Text("Sem dados"),
                          IconButton(
                              onPressed: () async {
                                _voyages$ = VoyageInterface.getVoyages();
                                setState(() {});
                              },
                              icon: const Icon(Icons.refresh))
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
