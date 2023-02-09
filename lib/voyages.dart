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
  Future<dynamic> _berths$ = BerthInterface.getBerths();

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
          Image.asset('assets/static_map.png'),
          const SizedBox(height: 4),
          Expanded(
            child: FutureBuilder<dynamic>(
              future: _berths$,
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
                                _berths$ = BerthInterface.getBerths();
                                setState(() {});
                              },
                              icon: const Icon(Icons.refresh))
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data.length > 0) {
                  final berthList = snapshot.data;
                  if ((berthList as List).isEmpty) {
                    return Center(
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const Text("Sem dados"),
                            IconButton(
                                onPressed: () async {
                                  _berths$ = BerthInterface.getBerths();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.refresh))
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _berths$ = BerthInterface.getBerths();
                      return _berths$.onError((_, __) => setState(() {})).then((_) => setState(() {}));
                    },
                    child: ListView.builder(
                      itemCount: berthList.length,
                      itemBuilder: (context, index) {
                        final berth = Berth.fromJson(berthList[index]);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Card(
                            child: InkWell(
                              onTap: () => Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) => DockingWidget(stage: berth))),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(berth.vesselName),
                                        const SizedBox(height: 4),
                                        Text(berth.berthName)
                                      ],
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
                                _berths$ = BerthInterface.getBerths();
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
