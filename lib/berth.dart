import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mooringapp/defaultAppBar.dart';
import 'package:mooringapp/interfaces.dart';
import 'package:mooringapp/messages.dart';
import 'package:mooringapp/tethers.dart';
import 'package:mooringapp/drafting.dart';
import 'package:mooringapp/mooring.dart';
import 'package:mooringapp/types.dart';

class BerthWidget extends StatefulWidget {
  final Voyage voyage;
  final Stage stage;
  final Berth berth;
  const BerthWidget({Key? key, required this.voyage, required this.berth, required this.stage}) : super(key: key);

  @override
  State<BerthWidget> createState() => _BerthWidgetState();
}

class _BerthWidgetState extends State<BerthWidget> {
  Future<Stage> _stage$ = Completer<Stage>().future;
  Future<List<Hawser>> _hawsers$ = Completer<List<Hawser>>().future;

  @override
  void initState() {
    loadData();
    setState(() {});

    super.initState();
  }

  @override
  void dispose() {
    // DockingSingleton
    super.dispose();
  }

  Future<void> loadData() async {
    _stage$ = VoyageInterface.getStage(widget.stage.stage_id);
    _hawsers$ = HawsersInterface.getHawsers();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: DefaultAppBar(
          bottom: const TabBar(
            indicatorColor: Color(0xFFF38D36),
            tabs: [
              Tab(text: "Calado"),
              Tab(text: "Cabos"),
              Tab(text: "Amarração"),
              // Tab(text: "Mensagens"),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(
                    widget.voyage.vessel_name ?? "Embarcação sem nome",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.berth.berth_name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ],
              ),
            ),
            const Divider(
              height: 1,
              color: Colors.white,
            ),
            Expanded(
              child: FutureBuilder<dynamic>(
                future: Future.wait([_stage$, _hawsers$]),
                builder: (context, snapshot) {
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
                                  loadData();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.refresh))
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    Stage stage = snapshot.data[0];
                    List<Hawser> hawsers = snapshot.data[1];
                    var bollards = widget.berth.bollards;

                    StageBehaviorSubject().setValue(stage);

                    return TabBarView(
                      children: [
                        DrafitingWidget(stage: stage),
                        TethersWidget(stage: stage, hawsers: hawsers, bollards: bollards),
                        MooringWidget(stage: stage, hawsers: hawsers, bollards: bollards),
                        // MessagesWidget(berth: widget.berth, voyage: snapshot.data),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
