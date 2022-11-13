import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:neptune/interfaces.dart';
import 'package:neptune/types.dart';

enum Position { mean, aft, mid, fore }

enum Stage { decl, arrival, loading, leaving }

class DrafitingWidget extends StatefulWidget {
  final Berth berth;
  final dynamic docking;

  const DrafitingWidget({Key? key, required this.berth, required this.docking}) : super(key: key);

  @override
  State<DrafitingWidget> createState() => _DrafitingWidgetState();
}

class _DrafitingWidgetState extends State<DrafitingWidget> {
  Position _position = Position.mid;
  Stage _stage = Stage.decl;
  final _draftController = TextEditingController();
  DateTime? _dateTime;
  final _dateTimeController = TextEditingController();
  bool _inProgress = false;
  List<dynamic>? _draftingList;

  @override
  void initState() {
    _draftingList = widget.docking['drafting'];
    super.initState();
  }

  @override
  void dispose() {
    _draftController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(2.5)),
                border: Border.all(color: const Color(0xFF36393F)),
                color: const Color(0xFF292B2F),
              ),
              child: Column(
                children: [
                  SvgPicture.asset('assets/SHIP_NP_BLUE.svg'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text("Vante"),
                          Radio<Position>(
                            value: Position.aft,
                            groupValue: _position,
                            onChanged: (Position? val) {
                              setState(() {
                                _position = val ?? _position;
                              });
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Médio"),
                          Radio<Position>(
                            value: Position.mid,
                            groupValue: _position,
                            onChanged: (Position? val) {
                              setState(() {
                                _position = val ?? _position;
                              });
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Ré"),
                          Radio<Position>(
                            value: Position.fore,
                            groupValue: _position,
                            onChanged: (Position? val) {
                              setState(() {
                                _position = val ?? _position;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                    width: MediaQuery.of(context).size.width / 2,
                    child: const Divider(
                      height: 1,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text("Declarado"),
                          Radio<Stage>(
                            value: Stage.decl,
                            groupValue: _stage,
                            onChanged: (Stage? val) {
                              setState(() {
                                _stage = val ?? _stage;
                              });
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Chegada"),
                          Radio<Stage>(
                            value: Stage.arrival,
                            groupValue: _stage,
                            onChanged: (Stage? val) {
                              setState(() {
                                _stage = val ?? _stage;
                              });
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Carregamento"),
                          Radio<Stage>(
                            value: Stage.loading,
                            groupValue: _stage,
                            onChanged: (Stage? val) {
                              setState(() {
                                _stage = val ?? _stage;
                              });
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Partida"),
                          Radio<Stage>(
                            value: Stage.leaving,
                            groupValue: _stage,
                            onChanged: (Stage? val) {
                              setState(() {
                                _stage = val ?? _stage;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: _draftController,
                    decoration: InputDecoration(
                        labelText: "Calado", suffixText: "m", suffixStyle: Theme.of(context).textTheme.bodyText2),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 2,
                  child: TextField(
                    controller: _dateTimeController,
                    decoration: const InputDecoration(labelText: "Data"),
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    showCursor: true,
                    onTap: () {
                      DatePicker.showDateTimePicker(
                        context,
                        currentTime: _dateTime,
                        locale: LocaleType.pt,
                      ).then(
                        (value) {
                          setState(() {
                            _dateTimeController.text = value.toString();
                            _dateTime = value;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _inProgress
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF38D36)),
                    onPressed: _enableSave()
                        ? (() async {
                            setState(() {
                              _inProgress = true;
                            });
                            DockingInterface.postDrafting(widget.berth.dockingId, {
                              'docking_id': widget.berth.dockingId,
                              'assign_id': 0,
                              't': _dateTime?.toIso8601String(),
                              'draft': int.parse(_draftController.text.toString()),
                              'pos': EnumToString.convertToString(_position),
                              'stage': EnumToString.convertToString(_stage),
                            }).onError((error, stackTrace) {
                              setState(() {
                                _inProgress = false;
                              });
                              _showErrorDialog(error.toString());
                            }).then(
                              (value) {
                                setState(() {
                                  _draftingList ??= [];
                                  _draftingList!.insert(_draftingList!.length, value);
                                  _inProgress = false;
                                });
                              },
                            );
                          })
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [Text("Salvar")],
                    ),
                  ),
            const SizedBox(height: 8),
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(2.5)),
                    border: Border.all(color: const Color(0xFF36393F)),
                    color: const Color(0xFF292B2F),
                  ),
                  child: _draftingList == null
                      ? const Center(
                          child: Text("No Data"),
                        )
                      : Scrollbar(
                          radius: const Radius.circular(5),
                          child: ListView.builder(
                            itemCount: _draftingList!.length,
                            itemBuilder: (context, index) {
                              dynamic drafting = _draftingList![index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                          flex: 4,
                                          child: Text(
                                              "Calado ${_parsePos(drafting['pos'])} ${_parseStage(drafting['stage'])}")),
                                      Flexible(
                                        flex: 3,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              DateFormat("HH:mm dd/MMM").format(DateTime.parse(drafting['t'])),
                                            ), //12:00 10/nov
                                            Text("${drafting['draft']}m"),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _parsePos(String pos) {
    switch (pos) {
      case 'mean':
      case 'mid':
        return 'Médio';

      case 'aft':
        return 'Vante';

      case 'fore':
        return 'Ré';

      default:
        return '';
    }
  }

  String _parseStage(String stage) {
    switch (stage) {
      case 'decl':
        return 'Declarado';

      case 'arrival':
        return 'Chegada';

      case 'loading':
        return 'Carregamento';

      case 'leaving':
        return 'Partida';

      default:
        return '';
    }
  }

  bool _enableSave() {
    return _draftController.text.isNotEmpty && _dateTimeController.text.isNotEmpty;
  }

  Future<void> _showErrorDialog(String error) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro ao salvar arqueação'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
