import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mooringapp/interfaces.dart';
import 'package:mooringapp/types.dart';

class TethersWidget extends StatefulWidget {
  final Stage stage;
  final List<Hawser> hawsers;
  final List<Bollard> bollards;

  const TethersWidget({Key? key, required this.stage, required this.hawsers, required this.bollards}) : super(key: key);

  @override
  State<TethersWidget> createState() => _TethersWidgetState();
}

class _TethersWidgetState extends State<TethersWidget> {
  final _formKey = GlobalKey<FormState>();

  Hawser? _hawser;
  Bollard? _bollard;
  bool _inProgress = false;
  bool _refreshing = false;
  StageBehaviorSubject stage$ = StageBehaviorSubject();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stage$.getStream(),
      builder: (context, AsyncSnapshot<Stage?> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        Stage stage = snapshot.data!;

        Mooring? mooring = (stage.moorings?.isEmpty ?? false) ? null : stage.moorings!.first;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Image.asset('assets/static_mooring.png'),
                        // const SizedBox(height: 8),
                        Form(
                          key: _formKey,
                          child: Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: DropdownButtonFormField(
                                  value: _hawser,
                                  validator: (value) => value == null ? 'Requerido' : null,
                                  dropdownColor: const Color(0xFF292B2F),
                                  decoration: const InputDecoration(
                                    labelText: "Posição",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  items: widget.hawsers
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e.hawser_desc)))
                                      .toList(),
                                  onChanged: (Hawser? val) {
                                    setState(() {
                                      _hawser = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                flex: 1,
                                child: DropdownButtonFormField(
                                  value: _bollard,
                                  validator: (value) => value == null ? 'Requerido' : null,
                                  dropdownColor: const Color(0xFF292B2F),
                                  decoration: const InputDecoration(
                                    labelText: "Cabeço",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  items: widget.bollards
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e.bollard_name)))
                                      .toList(),
                                  onChanged: (Bollard? val) {
                                    setState(() {
                                      _bollard = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
                            border: Border.all(color: const Color(0xFF36393F)),
                            color: const Color(0xFF292B2F),
                          ),
                          child: _inProgress
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.all(23),
                                  child: CircularProgressIndicator(),
                                ))
                              : Row(
                                  children: [
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: ElevatedButton(
                                            onPressed: !(mooring?.tethers.any((tether) =>
                                                        tether.hawser_id == _hawser?.hawser_id &&
                                                        tether.bollard_id == _bollard?.bollard_id &&
                                                        tether.pristine == true) ??
                                                    false)
                                                ? () async {
                                                    if (_formKey.currentState!.validate()) {
                                                      setState(() {
                                                        _inProgress = true;
                                                      });
                                                      if (mooring == null) {
                                                        // await DockingsInterface.postMooring(stage.stage_id, {
                                                        //   'hawser_id': _hawser["hawser_id"],
                                                        //   'bollard_id': _bollard.bollard_id,
                                                        //   'stern_distance': null,
                                                        //   'bow_distance': null,
                                                        // });
                                                        await DockingsInterface.postMooring({
                                                          "stage_id": stage.stage_id,
                                                          "tie_started_at": null,
                                                          "tie_finished_at": null,
                                                          "untie_started_at": null,
                                                          "untie_finished_at": null,
                                                          "tethers": [
                                                            {
                                                              'hawser_id': _hawser!.hawser_id,
                                                              'bollard_id': _bollard!.bollard_id,
                                                              "first_tie": null,
                                                              "last_tie": null,
                                                              "first_untie": null,
                                                              "last_untie": null,
                                                              'bow_distance': null,
                                                              'stern_distance': null,
                                                              "pristine": true,
                                                              "broken": false
                                                            }
                                                          ]
                                                        });
                                                      } else {
                                                        await DockingsInterface.postTether({
                                                          "mooring_id": mooring.mooring_id,
                                                          'hawser_id': _hawser!.hawser_id,
                                                          'bollard_id': _bollard!.bollard_id,
                                                          "first_tie": null,
                                                          "last_tie": null,
                                                          "first_untie": null,
                                                          "last_untie": null,
                                                          'stern_distance': null,
                                                          'bow_distance': null,
                                                          "pristine": true,
                                                          "broken": false
                                                        });
                                                      }
                                                      await stage$.refresh(stage.stage_id);
                                                      setState(() {
                                                        _inProgress = false;
                                                      });
                                                    }
                                                  }
                                                : null,
                                            child: SvgPicture.asset(
                                              'assets/amarracao.svg',
                                              color: const Color(0xFFD9D9D9),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Padding(padding: const EdgeInsets.all(4), child: Container()),
                                      ),
                                    ),
                                    // Expanded(
                                    //   child: AspectRatio(
                                    //     aspectRatio: 1,
                                    //     child: Padding(
                                    //       padding: const EdgeInsets.all(4),
                                    //       child: ElevatedButton(
                                    //         onPressed: null,
                                    //         child: SvgPicture.asset(
                                    //           'assets/mudanca.svg',
                                    //           color: const Color(0xFFD9D9D9),
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    // Expanded(
                                    //   child: AspectRatio(
                                    //     aspectRatio: 1,
                                    //     child: Padding(
                                    //       padding: const EdgeInsets.all(4),
                                    //       child: ElevatedButton(
                                    //         onPressed: null,
                                    //         child: SvgPicture.asset(
                                    //           'assets/puxada.svg',
                                    //           color: const Color(0xFFD9D9D9),
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: ElevatedButton(
                                            onPressed: (mooring?.tethers.any((tether) =>
                                                        tether.hawser_id == _hawser?.hawser_id &&
                                                        tether.bollard_id == _bollard?.bollard_id &&
                                                        tether.pristine != null &&
                                                        tether.broken == false) ??
                                                    false)
                                                ? () async {
                                                    if (_formKey.currentState!.validate()) {
                                                      setState(() {
                                                        _inProgress = true;
                                                      });
                                                      Tether tether = mooring!.tethers.lastWhere((tether) =>
                                                          tether.hawser_id == _hawser!.hawser_id &&
                                                          tether.bollard_id == _bollard?.bollard_id &&
                                                          tether.pristine != null &&
                                                          tether.broken == false);
                                                      await DockingsInterface.patchTether(
                                                        tether.tether_id,
                                                        {
                                                          ...tether.toMap(),
                                                          "pristine": null,
                                                        },
                                                      );
                                                      await stage$.refresh(stage.stage_id);
                                                      setState(() {
                                                        _inProgress = false;
                                                      });
                                                    }
                                                  }
                                                : null,
                                            child: SvgPicture.asset(
                                              'assets/desamarracao.svg',
                                              color: const Color(0xFFD9D9D9),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Padding(padding: const EdgeInsets.all(4), child: Container()),
                                      ),
                                    ),
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: ElevatedButton(
                                            onPressed: (mooring?.tethers.any((tether) =>
                                                        tether.hawser_id == _hawser?.hawser_id &&
                                                        tether.bollard_id == _bollard?.bollard_id &&
                                                        tether.pristine == true &&
                                                        tether.broken == false) ??
                                                    false)
                                                ? () async {
                                                    if (_formKey.currentState!.validate()) {
                                                      setState(() {
                                                        _inProgress = true;
                                                      });
                                                      Tether tether = mooring!.tethers.lastWhere((tether) =>
                                                          tether.hawser_id == _hawser!.hawser_id &&
                                                          tether.bollard_id == _bollard?.bollard_id &&
                                                          tether.pristine != null &&
                                                          tether.broken == false);
                                                      await DockingsInterface.patchTether(
                                                        tether.tether_id,
                                                        {
                                                          ...tether.toMap(),
                                                          "pristine": null,
                                                          "broken": true,
                                                        },
                                                      );
                                                      await stage$.refresh(stage.stage_id);
                                                      setState(() {
                                                        _inProgress = false;
                                                      });
                                                    }
                                                  }
                                                : null,
                                            child: SvgPicture.asset(
                                              'assets/ruptura.svg',
                                              color: const Color(0xFFD9D9D9),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height / 3,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(2.5)),
                              border: Border.all(color: const Color(0xFF36393F)),
                              color: const Color(0xFF292B2F),
                            ),
                            child: (mooring == null || mooring.tethers.isEmpty)
                                ? Center(
                                    child: IntrinsicHeight(
                                      child: Column(
                                        children: [
                                          const Text("Sem dados"),
                                          _refreshing
                                              ? const Padding(
                                                  padding: EdgeInsets.all(6),
                                                  child: CircularProgressIndicator(),
                                                )
                                              : IconButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      _refreshing = true;
                                                    });
                                                    await stage$.refresh(stage.stage_id);
                                                    setState(() {
                                                      _refreshing = false;
                                                    });
                                                  },
                                                  icon: const Icon(Icons.refresh),
                                                )
                                        ],
                                      ),
                                    ),
                                  )
                                : Scrollbar(
                                    radius: const Radius.circular(5),
                                    child: RefreshIndicator(
                                      onRefresh: () => stage$.refresh(stage.stage_id),
                                      child: ListView.builder(
                                        itemCount: mooring.tethers.length,
                                        itemBuilder: (context, index) {
                                          Tether tether = mooring.tethers[index];

                                          final Color textColor = () {
                                            if (tether.broken) {
                                              return Colors.red;
                                            } else if (tether.pristine == null || !tether.pristine!) {
                                              return Colors.white;
                                            } else {
                                              return const Color(0xFFF38D36);
                                            }
                                          }();

                                          return Card(
                                            child: InkWell(
                                              // onLongPress: () {
                                              //   _showDeleteDialog(tether, stage.stage_id);
                                              // },
                                              onTap: () {
                                                setState(() {
                                                  _bollard = widget.bollards
                                                      .lastWhere((e) => e.bollard_id == tether.bollard_id);
                                                  _hawser =
                                                      widget.hawsers.lastWhere((e) => e.hawser_id == tether.hawser_id);
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            widget.hawsers
                                                                .lastWhere((e) => e.hawser_id == tether.hawser_id)
                                                                .hawser_desc,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: textColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            getBollard(tether.bollard_id).bollard_name,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: textColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Bollard getBollard(int id) {
    return widget.bollards.firstWhere((bollard) => bollard.bollard_id == id);
  }

  Future<void> _showDeleteDialog(Tether tether, int voyageId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmar deleção',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          // content: Text(error),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: Theme.of(context).textTheme.bodyText1),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sim', style: Theme.of(context).textTheme.bodyText1),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _inProgress = true;
                });
                await DockingsInterface.deleteTether(tether.tether_id);
                await stage$.refresh(voyageId);
                setState(() {
                  _inProgress = false;
                });
              },
            ),
          ],
        );
      },
    );
  }
}
