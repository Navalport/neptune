import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mooringapp/interfaces.dart';
import 'package:mooringapp/types.dart';

class DrafitingWidget extends StatefulWidget {
  final Stage stage;

  const DrafitingWidget({Key? key, required this.stage}) : super(key: key);

  @override
  State<DrafitingWidget> createState() => _DrafitingWidgetState();
}

class _DrafitingWidgetState extends State<DrafitingWidget> {
  DraftPosition _position = DraftPosition.mid;
  DraftType _type = DraftType.declared;
  final _draftController = TextEditingController();
  DateTime? _dateTime;
  final _dateTimeController = TextEditingController();
  bool _inProgress = false;
  // bool _inProgressBoardside = false;
  bool _refreshing = false;
  StageBehaviorSubject stage$ = StageBehaviorSubject();

  @override
  void dispose() {
    _draftController.dispose();
    _dateTimeController.dispose();
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
          // _inProgress = false;
          // _inProgressBoardside = false;
          // _refreshing = false;

          return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: IntrinsicHeight(
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
                              // _inProgressBoardside
                              //     ? const Center(
                              //         child: CircularProgressIndicator(),
                              //       )
                              //     : InkWell(
                              //         onTap: () async {
                              //           // setState(() {
                              //           //   _inProgressBoardside = true;
                              //           // });
                              //           // await VoyageInterface.patchVoyage(
                              //           //     stage.stage_id, {"boardside_id": voyage["boardside_id"] == 1 ? 2 : 1});
                              //           // await voyage$.refresh(stage.stage_id);
                              //           // setState(() {
                              //           //   _inProgressBoardside = false;
                              //           // });
                              //         },
                              //         child: Transform(
                              //             alignment: Alignment.center,
                              //             transform: Matrix4.rotationY(voyage["boardside_id"] == 1 ? 0 : math.pi),
                              //             child: SvgPicture.asset('assets/SHIP_NP_BLUE.svg')),
                              //       ),
                              SvgPicture.asset('assets/SHIP_NP_BLUE.svg'),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const Text("Vante"),
                                      Radio<DraftPosition>(
                                        value: DraftPosition.aft,
                                        groupValue: _position,
                                        onChanged: (DraftPosition? val) {
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
                                      Radio<DraftPosition>(
                                        value: DraftPosition.mid,
                                        groupValue: _position,
                                        onChanged: (DraftPosition? val) {
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
                                      Radio<DraftPosition>(
                                        value: DraftPosition.fore,
                                        groupValue: _position,
                                        onChanged: (DraftPosition? val) {
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
                                      Radio<DraftType>(
                                        value: DraftType.declared,
                                        groupValue: _type,
                                        onChanged: (DraftType? val) {
                                          setState(() {
                                            _type = val ?? _type;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text("Chegada"),
                                      Radio<DraftType>(
                                        value: DraftType.arrival,
                                        groupValue: _type,
                                        onChanged: (DraftType? val) {
                                          setState(() {
                                            _type = val ?? _type;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text("Carregamento"),
                                      Radio<DraftType>(
                                        value: DraftType.loading,
                                        groupValue: _type,
                                        onChanged: (DraftType? val) {
                                          setState(() {
                                            _type = val ?? _type;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text("Partida"),
                                      Radio<DraftType>(
                                        value: DraftType.leaving,
                                        groupValue: _type,
                                        onChanged: (DraftType? val) {
                                          setState(() {
                                            _type = val ?? _type;
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
                                    labelText: "Calado",
                                    suffixText: "m",
                                    suffixStyle: Theme.of(context).textTheme.bodyText2),
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
                                        _dateTimeController.text = value?.toString() ?? _dateTimeController.text;
                                        _dateTime = value ?? _dateTime;
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
                                        await DockingsInterface.postDrafting({
                                          'stage_id': widget.stage.stage_id,
                                          'draft': double.parse(_draftController.text.toString()),
                                          'position': EnumToString.convertToString(_position),
                                          'type': EnumToString.convertToString(_type),
                                          'date': _dateTime?.toIso8601String(),
                                        }).onError((error, stackTrace) {
                                          setState(() {
                                            _inProgress = false;
                                          });
                                          _showErrorDialog(error.toString());
                                        });
                                        await stage$.refresh(stage.stage_id);
                                        setState(() {
                                          _inProgress = false;
                                        });
                                      })
                                    : null,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [Text("Salvar")],
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
                            child: stage.draftings == null
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
                                                  icon: const Icon(Icons.refresh))
                                        ],
                                      ),
                                    ),
                                  )
                                : Scrollbar(
                                    radius: const Radius.circular(5),
                                    child: RefreshIndicator(
                                      onRefresh: () => stage$.refresh(stage.stage_id),
                                      child: ListView.builder(
                                        itemCount: stage.draftings!.length,
                                        itemBuilder: (context, index) {
                                          Drafting drafting = stage.draftings![index];
                                          return Card(
                                            child: InkWell(
                                              onLongPress: () {
                                                _showDeleteDialog(drafting.drafting_id, stage.stage_id);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Flexible(
                                                        flex: 4,
                                                        child: Text(
                                                            "Calado ${_parsePos(drafting.position)} ${_parseType(drafting.type)}")),
                                                    Flexible(
                                                      flex: 3,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            DateFormat("HH:mm dd/MMM")
                                                                .format(DateTime.parse(drafting.date)),
                                                          ), //12:00 10/nov
                                                          Text("${drafting.draft}m"),
                                                        ],
                                                      ),
                                                    )
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
          });
        });
  }

  String _parsePos(DraftPosition pos) {
    switch (pos) {
      case DraftPosition.mean:
      case DraftPosition.mid:
        return 'Médio';

      case DraftPosition.aft:
        return 'Vante';

      case DraftPosition.fore:
        return 'Ré';

      default:
        return '';
    }
  }

  String _parseType(DraftType type) {
    switch (type) {
      case DraftType.declared:
        return 'Declarado';

      case DraftType.arrival:
        return 'Chegada';

      case DraftType.loading:
        return 'Carregamento';

      case DraftType.leaving:
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

  Future<void> _showDeleteDialog(int draftingId, int voyageId) async {
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
                await DockingsInterface.deleteDrafting(draftingId);
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
