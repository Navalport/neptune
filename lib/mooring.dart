import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mooringapp/voyage.dart';
import 'package:mooringapp/interfaces.dart';
import 'package:mooringapp/types.dart';

class MorringWidget extends StatefulWidget {
  final Berth berthing;
  final List<dynamic> hawsers, bollards;

  const MorringWidget({Key? key, required this.berthing, required this.hawsers, required this.bollards})
      : super(key: key);

  @override
  State<MorringWidget> createState() => _MorringWidgetState();
}

class _MorringWidgetState extends State<MorringWidget> {
  final _formKey = GlobalKey<FormState>();

  dynamic _hawser, _bollard;
  List<dynamic>? _mooringList;
  bool _inProgress = false;
  bool _refreshing = false;
  VoyageBehaviorSubject voyage$ = VoyageBehaviorSubject();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: voyage$.getStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          dynamic voyage = snapshot.data;
          var stage = (voyage["stages"] as List).firstWhere((e) => e["stage_id"] == widget.berthing.stageId);
          _mooringList = stage['moorings']?.reversed.toList();

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
                                  child: DropdownButtonFormField<dynamic>(
                                    value: _hawser,
                                    validator: (value) => value == null ? 'Requerido' : null,
                                    dropdownColor: const Color(0xFF292B2F),
                                    decoration: const InputDecoration(
                                      labelText: "Posição",
                                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    ),
                                    items: widget.hawsers
                                        .map((e) => DropdownMenuItem<dynamic>(value: e, child: Text(e['hawser_desc'])))
                                        .toList(),
                                    onChanged: (dynamic val) {
                                      setState(() {
                                        _hawser = val;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  flex: 1,
                                  child: DropdownButtonFormField<dynamic>(
                                    value: _bollard,
                                    validator: (value) => value == null ? 'Requerido' : null,
                                    dropdownColor: const Color(0xFF292B2F),
                                    decoration: const InputDecoration(
                                      labelText: "Cabeço",
                                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    ),
                                    items: widget.bollards
                                        .map((e) => DropdownMenuItem<dynamic>(value: e, child: Text(e['bollard_name'])))
                                        .toList(),
                                    onChanged: (dynamic val) {
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
                                              onPressed: () async {
                                                if (_formKey.currentState!.validate()) {
                                                  setState(() {
                                                    _inProgress = true;
                                                  });
                                                  await VoyageInterface.postMooring({
                                                    'voyage_id': widget.berthing.voyageId,
                                                    'stage_id': widget.berthing.stageId,
                                                    'assign_id': 1,
                                                    'hawser_id': _hawser["hawser_id"],
                                                    'bollard_id': int.parse(_bollard["bollard_id"]),
                                                    'tied_at': DateTime.now().toIso8601String(),
                                                  });
                                                  await voyage$.refresh(voyage["voyage_id"]);
                                                  setState(() {
                                                    _inProgress = false;
                                                  });
                                                }
                                              },
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
                                              onPressed: _mooringList?.any((e) =>
                                                          e["hawser_id"] == _hawser?["hawser_id"] &&
                                                          e["bollard_id"] ==
                                                              int.tryParse(_bollard?["bollard_id"] ?? '') &&
                                                          e["untied_at"] == null &&
                                                          e["broken_at"] == null) ??
                                                      false
                                                  ? () async {
                                                      if (_formKey.currentState!.validate()) {
                                                        setState(() {
                                                          _inProgress = true;
                                                        });
                                                        dynamic mooring = _mooringList!.firstWhere((e) =>
                                                            e["hawser_id"] == _hawser["hawser_id"] &&
                                                            e["bollard_id"] == int.parse(_bollard["bollard_id"]) &&
                                                            e["untied_at"] == null &&
                                                            e["broken_at"] == null);
                                                        await VoyageInterface.patchMooring(mooring["mooring_id"], {
                                                          ...mooring,
                                                          "untied_at": DateTime.now().toIso8601String()
                                                        });
                                                        await voyage$.refresh(voyage["voyage_id"]);
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
                                              onPressed: _mooringList?.any((e) =>
                                                          e["hawser_id"] == _hawser?["hawser_id"] &&
                                                          e["bollard_id"] ==
                                                              int.tryParse(_bollard?["bollard_id"] ?? '') &&
                                                          e["untied_at"] == null &&
                                                          e["broken_at"] == null) ??
                                                      false
                                                  ? () async {
                                                      if (_formKey.currentState!.validate()) {
                                                        setState(() {
                                                          _inProgress = true;
                                                        });
                                                        dynamic mooring = _mooringList!.firstWhere((e) =>
                                                            e["hawser_id"] == _hawser["hawser_id"] &&
                                                            e["bollard_id"] == int.parse(_bollard["bollard_id"]));
                                                        await VoyageInterface.patchMooring(mooring["mooring_id"], {
                                                          ...mooring,
                                                          "broken_at": DateTime.now().toIso8601String()
                                                        });
                                                        await voyage$.refresh(voyage["voyage_id"]);
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
                              child: _mooringList == null
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
                                                      await voyage$.refresh(voyage["voyage_id"]);
                                                      setState(() {
                                                        _refreshing = false;
                                                      });
                                                    },
                                                    icon: const Icon(Icons.refresh))
                                          ],
                                        ),
                                      ),
                                    )
                                  : Scrollbar(
                                      radius: const Radius.circular(5),
                                      child: RefreshIndicator(
                                        onRefresh: () => voyage$.refresh(voyage["voyage_id"]),
                                        child: ListView.builder(
                                          itemCount: _mooringList!.length,
                                          itemBuilder: (context, index) {
                                            dynamic mooring = _mooringList![index];

                                            final bool isBroken = mooring['broken_at'] != null;
                                            final bool isUntied = mooring['untied_at'] != null;

                                            final Color textColor = () {
                                              if (isBroken) {
                                                return Colors.red;
                                              } else if (isUntied) {
                                                return Colors.white;
                                              } else {
                                                return const Color(0xFFF38D36);
                                              }
                                            }();

                                            return Card(
                                              child: InkWell(
                                                onLongPress: () {
                                                  _showDeleteDialog(mooring, voyage["voyage_id"]);
                                                },
                                                onTap: () {
                                                  setState(() {
                                                    _bollard = widget.bollards.firstWhere(
                                                        (e) => int.parse(e["bollard_id"]) == mooring["bollard_id"]);
                                                    _hawser = widget.hawsers
                                                        .firstWhere((e) => e["hawser_id"] == mooring["hawser_id"]);
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
                                                              widget.hawsers.firstWhere((e) =>
                                                                  e["hawser_id"] ==
                                                                  mooring["hawser_id"])["hawser_desc"],
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
                                                              mooring["bollard_name"].toString(),
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
        });
  }

  List<dynamic>? _expandMorrings(dynamic moorings) {
    return moorings
        .map((e) {
          if (e['broken_at'] != null) {
            return [
              e,
              {...e, "broken_at": null},
            ];
          } else if (e['untied_at'] != null) {
            return [
              e,
              {...e, "untied_at": null},
            ];
          } else {
            return [e];
          }
        })
        .toList()
        .fold([], (p, e) => [...p, ...e])
        .toList();
  }

  Future<void> _showDeleteDialog(dynamic mooring, int voyageId) async {
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
                if (mooring["untied_at"] != null) {
                  await VoyageInterface.patchMooring(mooring["mooring_id"], {...mooring, "untied_at": null});
                }
                if (mooring["broken_at"] != null) {
                  await VoyageInterface.patchMooring(mooring["mooring_id"], {...mooring, "broken_at": null});
                } else {
                  await VoyageInterface.deleteMooring(mooring["mooring_id"]);
                }
                await voyage$.refresh(voyageId);
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
