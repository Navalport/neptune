import 'dart:async';

import 'package:flutter/material.dart';
import 'package:neptune/defaultAppBar.dart';
import 'package:neptune/interfaces.dart';
import 'package:neptune/messages.dart';
import 'package:neptune/mooring.dart';
import 'package:neptune/drafting.dart';
import 'package:neptune/tethers.dart';
import 'package:neptune/types.dart';

class DockingWidget extends StatefulWidget {
  final Berth berth;
  const DockingWidget({Key? key, required this.berth}) : super(key: key);

  @override
  State<DockingWidget> createState() => _DockingWidgetState();
}

class _DockingWidgetState extends State<DockingWidget> {
  Future<dynamic> _docking$ = Completer().future;
  Future<dynamic> _hawsers$ = Completer().future;
  Future<dynamic> _bollards$ = Completer().future;

  @override
  void initState() {
    loadData();
    setState(() {});

    super.initState();
  }

  Future<void> loadData() async {
    _docking$ = DockingInterface.getDocking(widget.berth.dockingId);
    _hawsers$ = HawsersInterface.getHawsers();
    _bollards$ = BollardsInterface.getBollards(widget.berth.berthId);
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
                    widget.berth.vesselName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.berth.berthName,
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
                future: Future.wait([_docking$, _hawsers$, _bollards$]),
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
                    var docking = snapshot.data[0];
                    var hawsers = snapshot.data[1];
                    var bollards = snapshot.data[2];
                    return TabBarView(
                      children: [
                        DrafitingWidget(berth: widget.berth, docking: docking),
                        MorringWidget(berth: widget.berth, docking: docking, hawsers: hawsers, bollards: bollards),
                        TethersWidget(berth: widget.berth, docking: docking, hawsers: hawsers, bollards: bollards),
                        // MessagesWidget(berth: widget.berth, docking: snapshot.data),
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
