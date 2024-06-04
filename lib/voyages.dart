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

class _DockingsWidgetState extends State<DockingsWidget> with TickerProviderStateMixin {
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
    TabController tabController = TabController(length: 2, vsync: this);

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
                  style: Theme.of(context).textTheme.bodyLarge,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: TextField(
              onChanged: (value) {
                setState(() {});
              },
              controller: _searchBarController,
              cursorColor: const Color(0xFFE4F8EF),
              decoration: InputDecoration(
                  labelText: "Buscar",
                  suffixIcon: const Icon(Icons.search),
                  suffixIconColor: const Color(0xFFE4F8EF),
                  suffixStyle: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          const SizedBox(height: 4),
          DefaultTabController(
            length: 2,
            child: TabBar(
              controller: tabController,
              tabs: const [
                Tab(
                  child: Text(
                    "Sem amarrações\nabertas",
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  child: Text(
                    "Com amarrações\nabertas",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _voyages$.getStream(),
              builder: (context, AsyncSnapshot<List<Voyage>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final voyages = snapshot.data!;

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
                  },
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      VoyagesList(
                          voyages: filteredVoyages.where((voyage) => !(voyage.hasOpenMoorings ?? false)).toList()),
                      VoyagesList(
                          voyages: filteredVoyages.where((voyage) => (voyage.hasOpenMoorings ?? false)).toList()),
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

class VoyagesList extends StatelessWidget {
  final List<Voyage> voyages;
  const VoyagesList({super.key, required this.voyages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: voyages.length,
      itemBuilder: (context, index) {
        final voyage = voyages[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Card(
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BerthsWidget(
                        voyage: voyage,
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
    );
  }
}
