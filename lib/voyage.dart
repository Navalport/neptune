import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mooringapp/defaultAppBar.dart';
import 'package:mooringapp/interfaces.dart';
import 'package:mooringapp/messages.dart';
import 'package:mooringapp/mooring.dart';
import 'package:mooringapp/drafting.dart';
import 'package:mooringapp/tethers.dart';
import 'package:mooringapp/types.dart';

class DockingWidget extends StatefulWidget {
  final Berth stage;
  const DockingWidget({Key? key, required this.stage}) : super(key: key);

  @override
  State<DockingWidget> createState() => _DockingWidgetState();
}

class _DockingWidgetState extends State<DockingWidget> {
  Future<dynamic> _voyage$ = Completer().future;
  Future<dynamic> _hawsers$ = Completer().future;
  Future<dynamic> _bollards$ = Completer().future;

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
    _voyage$ = VoyageInterface.getVoyage(widget.stage.voyageId);
    _hawsers$ = HawsersInterface.getHawsers();
    _bollards$ = BollardsInterface.getBollards(widget.stage.berthId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: DefaultAppBar(
          bottom: const TabBar(
            indicatorColor: Color(0xFFF38D36),
            tabs: [
              // Tab(text: "Calado"),
              Tab(text: "Amarração"),
              Tab(text: "Cabos"),
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
                    widget.stage.vesselName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.stage.berthName,
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
                future: Future.wait([_voyage$, _hawsers$, _bollards$]),
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
                    var voyage = snapshot.data[0];
                    var hawsers = snapshot.data[1];
                    var bollards = snapshot.data[2];

                    VoyageBehaviorSubject().setValue(voyage);

                    return TabBarView(
                      children: [
                        // DrafitingWidget(berth: widget.berth),
                        MorringWidget(berthing: widget.stage, hawsers: hawsers, bollards: bollards),
                        TethersWidget(berthing: widget.stage, hawsers: hawsers, bollards: bollards),
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