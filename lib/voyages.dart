import 'package:flutter/material.dart';
import 'package:mooringapp/berths.dart';
import 'package:mooringapp/defaultAppBar.dart';
import 'package:mooringapp/interfaces.dart';
import 'package:mooringapp/login2.dart';

import 'types.dart';

class DockingsWidget extends StatefulWidget {
  const DockingsWidget({Key? key}) : super(key: key);

  @override
  State<DockingsWidget> createState() => _DockingsWidgetState();
}

class _DockingsWidgetState extends State<DockingsWidget> {
  final VoyagesBehaviorSubject _voyages$ = VoyagesBehaviorSubject();
  final _searchBarController = TextEditingController();

  @override
  void initState() {
    VoyageInterface.getVoyages().then((value) => VoyagesBehaviorSubject().setValue(value));
    super.initState();
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

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
                        MaterialPageRoute(builder: (context) => const LoginWidget()),
                        ModalRoute.withName(""),
                      );
                    },
                    icon: const Icon(Icons.logout))
              ],
            ),
          ),
          // Image.asset('assets/static_map.png'),
          // const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: TextField(
              onChanged: (value) {
                setState(() {});
              },
              controller: _searchBarController,
              decoration: InputDecoration(
                  labelText: "Buscar",
                  suffixIcon: const Icon(Icons.search),
                  suffixIconColor: const Color(0xFFE4F8EF),
                  suffixStyle: Theme.of(context).textTheme.bodyText2),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder(
              stream: _voyages$.getStream(),
              builder: (context, AsyncSnapshot<List<Voyage>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                // if (snapshot.connectionState != ConnectionState.done) {
                //   return const Center(
                //     child: CircularProgressIndicator(),
                //   );
                // }
                // if (snapshot.hasError) {
                //   return Center(
                //     child: IntrinsicHeight(
                //       child: Column(
                //         children: [
                //           Text(snapshot.error.toString()),
                //           IconButton(
                //               onPressed: () async {
                //                 await _voyages$.refresh();
                //                 setState(() {});
                //               },
                //               icon: const Icon(Icons.refresh))
                //         ],
                //       ),
                //     ),
                //   );
                // }
                // else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final voyages = snapshot.data!;
                print(voyages.length);

                var filteredVoyages = voyages
                    .where((e) =>
                        (e.vessel_name?.toLowerCase().contains(_searchBarController.text.toLowerCase()) ?? false) ||
                        (e.voyage_desc?.toLowerCase().contains(_searchBarController.text.toLowerCase()) ?? false) ||
                        e.imo.toString().startsWith(_searchBarController.text.toLowerCase()) ||
                        e.duv.toString().startsWith(_searchBarController.text.toLowerCase()))
                    .toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    return await _voyages$.refresh();
                    // return _voyages$.onError((_, __) {
                    //   setState(() {});
                    //   return [];
                    // }).then((_) => setState(() {}));
                  },
                  child: ListView.builder(
                    itemCount: filteredVoyages.length,
                    itemBuilder: (context, index) {
                      final voyage = filteredVoyages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Card(
                          child: InkWell(
                            // onTap: () {
                            //   var berthStages = voyage.stages.where((e) => e.stagetype_id == 4);
                            //   if (berthStages.isNotEmpty) {
                            //     int? fenceId = berthStages.first.fence_id;
                            //     if (fenceId != null) {
                            //       BerthInterface.getBerthByFenceId(fenceId).then((value) => print(value));
                            //     }
                            //   }
                            // },
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BerthsWidget(
                                      voyage: voyage,
                                      // voyageId: voyage.voyage_id,
                                      // stages: voyage.stages.where((e) => e.stagetype_id == 4).toList(),
                                    ))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(voyage.vessel_name ?? "Embarcação sem nome"),
                                            const SizedBox(height: 4),
                                            Text(voyage.voyage_desc ?? "N/D"),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                // }
                // else {
                //   return Center(
                //     child: IntrinsicHeight(
                //       child: Column(
                //         children: [
                //           const Text("Sem dados"),
                //           IconButton(
                //               onPressed: () async {
                //                 await _voyages$.refresh();
                //                 setState(() {});
                //               },
                //               icon: const Icon(Icons.refresh))
                //         ],
                //       ),
                //     ),
                //   );
                // }
              },
            ),
          ),
        ],
      ),
    );
  }
}
