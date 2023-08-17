import 'package:flutter/material.dart';
import 'package:mooringapp/interfaces.dart';
import 'package:mooringapp/types.dart';
import 'package:mooringapp/berth.dart';
import 'package:tuple/tuple.dart';

import 'defaultAppBar.dart';

class BerthsWidget extends StatefulWidget {
  final Voyage voyage;

  const BerthsWidget({Key? key, required this.voyage}) : super(key: key);

  @override
  State<BerthsWidget> createState() => _BerthsWidgetState();
}

class _BerthsWidgetState extends State<BerthsWidget> {
  late Future<List<Berth>> _berths$;
  final VoyageBehaviorSubject _voyage$ = VoyageBehaviorSubject();

  @override
  void initState() {
    _berths$ = BerthInterface.getBerths();
    _voyage$.setValue(widget.voyage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (context) => fillStageIdDialog(context)),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _berths$,
        builder: (context, AsyncSnapshot<List<Berth>> snapshot) {
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
                          setState(() {
                            _berths$ = BerthInterface.getBerths(true);
                          });
                        },
                        icon: const Icon(Icons.refresh))
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return StreamBuilder(
              stream: _voyage$.getStream(),
              builder: (context, AsyncSnapshot<Voyage> streamSnapshot) {
                if (!streamSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final voyage = streamSnapshot.data!;
                final berths = snapshot.data!;
                final stageWithBerths = voyage.stages.map((stage) {
                  final berth = berths.where((berth) => berth.fence_id == stage.fence_id);
                  return Tuple2<Stage, Berth?>(stage, berth.isNotEmpty ? berth.first : null);
                }).toList();

                return stageWithBerths.isEmpty
                    ? const Center(
                        child: IntrinsicHeight(
                          child: Text("Sem estágios de atracação"),
                        ),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(voyage.vessel_name ?? "Embarcação sem nome"),
                                const SizedBox(height: 4),
                                Text(voyage.voyage_desc ?? "N/D"),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("IMO: ${voyage.imo}"),
                                const SizedBox(height: 4),
                                Text("DUV: ${voyage.duv}"),
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: stageWithBerths.length,
                              itemBuilder: (context, index) {
                                final stageWithBerth = stageWithBerths[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Card(
                                    child: InkWell(
                                      onTap: () {
                                        if (stageWithBerth.item2 == null) {
                                          showDialog(
                                              context: context,
                                              builder: (context) => fillStageIdDialog(context, stageWithBerth.item1));
                                        } else {
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => BerthWidget(
                                                    voyage: voyage,
                                                    stage: stageWithBerth.item1,
                                                    berth: stageWithBerth.item2!,
                                                  )));
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(stageWithBerth.item2?.berth_name ?? "Berço indefinido"),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text("ATS: ${stageWithBerth.item1.ats ?? "N/A"}"),
                                                      const SizedBox(height: 4),
                                                      Text("ATF: ${stageWithBerth.item1.atf ?? "N/A"}"),
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
                          ),
                        ],
                      );
              },
            );
          } else {
            return const Center(
              child: IntrinsicHeight(
                child: Text("Sem dados"),
              ),
            );
          }
        },
      ),
    );
  }

  Widget fillStageIdDialog(BuildContext context, [Stage? stage]) {
    int? fenceId;

    return StatefulBuilder(
      builder: (context, setState) => FutureBuilder(
        future: _berths$,
        builder: (context, AsyncSnapshot<List<Berth>> snapshot) {
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
                          setState(() {
                            _berths$ = BerthInterface.getBerths(true);
                          });
                        },
                        icon: const Icon(Icons.refresh))
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return AlertDialog(
              title: Text(
                stage == null ? "Novo estágio de atracação" : "Editar estágio",
                style: Theme.of(context).textTheme.headline5!.copyWith(fontSize: 24),
              ),
              actions: [
                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                ElevatedButton(
                    onPressed: fenceId != null
                        ? () async {
                            bool inProgress = true;
                            showDialog(
                              barrierDismissible: false,
                              builder: (context) => WillPopScope(
                                onWillPop: () async => !inProgress,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              context: context,
                            );

                            if (stage == null) {
                              await VoyageInterface.postStage({
                                "voyage_id": widget.voyage.voyage_id,
                                "stagetype_id": 4,
                                "fence_id": fenceId,
                                "atf": null,
                                "ats": null,
                              });
                            } else {
                              await VoyageInterface.patchStage(stage.stage_id, {
                                "fence_id": fenceId,
                                "ats": stage.ats?.toIso8601String(),
                                "atf": stage.atf?.toIso8601String(),
                                "cancelled": stage.cancelled,
                              });
                            }

                            await _voyage$.refreshFromList(widget.voyage.voyage_id);

                            inProgress = false;
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: const Text("OK")),
              ],
              content: DropdownButton(
                value: fenceId,
                dropdownColor: Theme.of(context).cardColor,
                isExpanded: true,
                hint: Text("Selecionar berço", style: Theme.of(context).textTheme.bodyText2),
                items: snapshot.data!
                    .map((berth) => DropdownMenuItem(
                          value: berth.fence_id,
                          child: Text(berth.berth_name, style: Theme.of(context).textTheme.bodyText2),
                        ))
                    .toList(),
                onChanged: (int? value) {
                  setState(() {
                    fenceId = value;
                  });
                },
              ),
            );
          } else {
            return const Center(
              child: IntrinsicHeight(
                child: Text("Sem dados"),
              ),
            );
          }
        },
      ),
    );
  }
}
