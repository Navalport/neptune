import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:neptune/interfaces.dart';
import 'package:neptune/types.dart';

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = Set();
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

class TethersWidget extends StatefulWidget {
  final Berth berth;
  final List<dynamic> hawsers, bollards;

  const TethersWidget(
      {Key? key,
      required this.berth,
      required this.hawsers,
      required this.bollards})
      : super(key: key);

  @override
  State<TethersWidget> createState() => _TethersWidgetState();
}

class _TethersWidgetState extends State<TethersWidget> {
  DateTime? _tieFirstDateTime,
      _tieLastDateTime,
      _untieFirstDateTime,
      _untieLastDateTime;
  dynamic _tieFirstMooring,
      _tieLastMooring,
      _untieFirstMooring,
      _untieLastMooring,
      _bowMooring,
      _sternMooring;
  final _bowController = TextEditingController();
  final _sternController = TextEditingController();
  final _tieFirstController = TextEditingController();
  final _tieLastController = TextEditingController();
  final _untieFirstController = TextEditingController();
  final _untieLastController = TextEditingController();
  final List<bool> _inProgress = List.filled(6, false);
  final List<bool> _isSet = List.filled(6, false);
  List<dynamic>? _mooringList;
  DockingBehaviorSubject docking$ = DockingBehaviorSubject();

  @override
  void dispose() {
    _bowController.dispose();
    _sternController.dispose();
    _tieFirstController.dispose();
    _tieLastController.dispose();
    _untieFirstController.dispose();
    _untieLastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: docking$.getStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          dynamic docking = snapshot.data;
          _populateMoorings(docking);

          return LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Amarração",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: DropdownButtonFormField<dynamic>(
                              value: _tieFirstMooring?["mooring_id"],
                              validator: (value) =>
                                  value == null ? 'Requerido' : null,
                              dropdownColor: const Color(0xFF292B2F),
                              decoration: const InputDecoration(
                                labelText: "Primeiro Cabo",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                              items: _mooringList
                                  ?.map((e) => DropdownMenuItem<dynamic>(
                                      value: e["mooring_id"],
                                      child: Text(
                                          "${e["hawser_desc"]} / ${e['bollard_name']}")))
                                  .toList(),
                              onChanged: (dynamic val) {
                                setState(() {
                                  _tieFirstMooring = _mooringList!.firstWhere(
                                      (element) =>
                                          element["mooring_id"] == val);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              validator: (value) =>
                                  value!.isEmpty ? 'Requerido' : null,
                              controller: _tieFirstController,
                              decoration: const InputDecoration(
                                labelText: "Data",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                              keyboardType: TextInputType.datetime,
                              readOnly: true,
                              showCursor: true,
                              onTap: () {
                                DatePicker.showDateTimePicker(
                                  context,
                                  currentTime: _tieFirstDateTime,
                                  locale: LocaleType.pt,
                                ).then(
                                  (value) {
                                    setState(() {
                                      _tieFirstController.text =
                                          value?.toString() ??
                                              _tieFirstController.text;
                                      _tieFirstDateTime =
                                          value ?? _tieFirstDateTime;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          _inProgress[0]
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : IconButton(
                                  onPressed: (_tieFirstDateTime == null ||
                                          _tieFirstMooring == null ||
                                          _isSet[0])
                                      ? null
                                      : () async {
                                          setState(() {
                                            _inProgress[0] = true;
                                          });
                                          await DockingInterface.patchMooring(
                                              widget.berth.dockingId,
                                              _tieFirstMooring["mooring_id"], {
                                            ..._tieFirstMooring,
                                            "tied_at": _tieFirstDateTime!
                                                .toIso8601String(),
                                            "type": jsonEncode([
                                              ...(tryDecode(_tieFirstMooring[
                                                      "type"]) ??
                                                  []),
                                              "FirstTie"
                                            ])
                                          });
                                          await docking$
                                              .refresh(docking["docking_id"]);
                                          setState(() {
                                            _inProgress[0] = false;
                                          });
                                        },
                                  icon: const Icon(Icons.save),
                                ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: DropdownButtonFormField<dynamic>(
                              value: _tieLastMooring?["mooring_id"],
                              validator: (value) =>
                                  value == null ? 'Requerido' : null,
                              dropdownColor: const Color(0xFF292B2F),
                              decoration: const InputDecoration(
                                labelText: "Último Cabo",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                              items: _mooringList
                                  ?.map((e) => DropdownMenuItem<dynamic>(
                                      value: e["mooring_id"],
                                      child: Text(
                                          "${e["hawser_desc"]} / ${e['bollard_name']}")))
                                  .toList(),
                              onChanged: (dynamic val) {
                                setState(() {
                                  _tieLastMooring = _mooringList!.firstWhere(
                                      (element) =>
                                          element["mooring_id"] == val);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              validator: (value) =>
                                  value!.isEmpty ? 'Requerido' : null,
                              controller: _tieLastController,
                              decoration: const InputDecoration(
                                labelText: "Data",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                              keyboardType: TextInputType.datetime,
                              readOnly: true,
                              showCursor: true,
                              onTap: () {
                                DatePicker.showDateTimePicker(
                                  context,
                                  currentTime: _tieLastDateTime,
                                  locale: LocaleType.pt,
                                ).then(
                                  (value) {
                                    setState(() {
                                      _tieLastController.text =
                                          value?.toString() ??
                                              _tieLastController.text;
                                      _tieLastDateTime =
                                          value ?? _tieLastDateTime;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          _inProgress[1]
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : IconButton(
                                  onPressed: (_tieLastDateTime == null ||
                                          _tieLastMooring == null ||
                                          _isSet[1])
                                      ? null
                                      : () async {
                                          setState(() {
                                            _inProgress[1] = true;
                                          });
                                          await DockingInterface.patchMooring(
                                              widget.berth.dockingId,
                                              _tieLastMooring["mooring_id"], {
                                            ..._tieLastMooring,
                                            "tied_at": _tieLastDateTime!
                                                .toIso8601String(),
                                            "type": jsonEncode([
                                              ...(tryDecode(_tieLastMooring[
                                                      "type"]) ??
                                                  []),
                                              "LastTie"
                                            ])
                                          });
                                          await docking$
                                              .refresh(docking["docking_id"]);
                                          setState(() {
                                            _inProgress[1] = false;
                                          });
                                        },
                                  icon: const Icon(Icons.save),
                                ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Distâncias",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: DropdownButtonFormField<dynamic>(
                              value: _bowMooring?["mooring_id"],
                              validator: (value) =>
                                  value == null ? 'Requerido' : null,
                              dropdownColor: const Color(0xFF292B2F),
                              decoration: const InputDecoration(
                                labelText: "Cabeço",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                              items: _mooringList
                                  ?.unique((e) => e['bollard_name'])
                                  .map((e) => DropdownMenuItem<dynamic>(
                                      value: e["mooring_id"],
                                      child: Text(e['bollard_name'])))
                                  .toList(),
                              onChanged: (dynamic val) {
                                setState(() {
                                  _bowMooring = _mooringList!.firstWhere(
                                      (element) =>
                                          element["mooring_id"] == val);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 1,
                            child: TextField(
                              controller: _bowController,
                              decoration: InputDecoration(
                                  labelText: "Proa",
                                  suffixText: "m",
                                  suffixStyle:
                                      Theme.of(context).textTheme.bodyText2),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                          _inProgress[2]
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : IconButton(
                                  onPressed: (_bowController.text.isEmpty ||
                                          _bowMooring == null ||
                                          _isSet[2])
                                      ? null
                                      : () async {
                                          setState(() {
                                            _inProgress[2] = true;
                                          });
                                          await DockingInterface.patchMooring(
                                              widget.berth.dockingId,
                                              _bowMooring["mooring_id"], {
                                            ..._bowMooring,
                                            "distance": double.parse(
                                                _bowController.text),
                                            "type": jsonEncode([
                                              ...(tryDecode(
                                                      _bowMooring["type"]) ??
                                                  []),
                                              "BowDistance"
                                            ])
                                          });
                                          await docking$
                                              .refresh(docking["docking_id"]);
                                          setState(() {
                                            _inProgress[2] = false;
                                          });
                                        },
                                  icon: const Icon(Icons.save),
                                ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: DropdownButtonFormField<dynamic>(
                              value: _sternMooring?["mooring_id"],
                              validator: (value) =>
                                  value == null ? 'Requerido' : null,
                              dropdownColor: const Color(0xFF292B2F),
                              decoration: const InputDecoration(
                                labelText: "Cabeço",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                              items: _mooringList
                                  ?.unique((e) => e['bollard_name'])
                                  .map((e) => DropdownMenuItem<dynamic>(
                                      value: e["mooring_id"],
                                      child: Text(e['bollard_name'])))
                                  .toList(),
                              onChanged: (dynamic val) {
                                setState(() {
                                  _sternMooring = _mooringList!.firstWhere(
                                      (element) =>
                                          element["mooring_id"] == val);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 1,
                            child: TextField(
                              controller: _sternController,
                              decoration: InputDecoration(
                                  labelText: "Popa",
                                  suffixText: "m",
                                  suffixStyle:
                                      Theme.of(context).textTheme.bodyText2),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                          _inProgress[3]
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : IconButton(
                                  onPressed: (_sternController.text.isEmpty ||
                                          _sternMooring == null ||
                                          _isSet[3])
                                      ? null
                                      : () async {
                                          setState(() {
                                            _inProgress[3] = true;
                                          });
                                          await DockingInterface.patchMooring(
                                              widget.berth.dockingId,
                                              _sternMooring["mooring_id"], {
                                            ..._sternMooring,
                                            "distance": double.parse(
                                                _sternController.text),
                                            "type": jsonEncode([
                                              ...(tryDecode(
                                                      _sternMooring["type"]) ??
                                                  []),
                                              "SternDistance"
                                            ])
                                          });
                                          await docking$
                                              .refresh(docking["docking_id"]);
                                          setState(() {
                                            _inProgress[3] = false;
                                          });
                                        },
                                  icon: const Icon(Icons.save),
                                ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Desamarração",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: DropdownButtonFormField<dynamic>(
                              value: _untieFirstMooring?["mooring_id"],
                              validator: (value) =>
                                  value == null ? 'Requerido' : null,
                              dropdownColor: const Color(0xFF292B2F),
                              decoration: const InputDecoration(
                                labelText: "Primeiro Cabo",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                              items: _mooringList
                                  ?.map((e) => DropdownMenuItem<dynamic>(
                                      value: e["mooring_id"],
                                      child: Text(
                                          "${e["hawser_desc"]} / ${e['bollard_name']}")))
                                  .toList(),
                              onChanged: (dynamic val) {
                                setState(() {
                                  _untieFirstMooring = _mooringList!.firstWhere(
                                      (element) =>
                                          element["mooring_id"] == val);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              validator: (value) =>
                                  value!.isEmpty ? 'Requerido' : null,
                              controller: _untieFirstController,
                              decoration: const InputDecoration(
                                labelText: "Data",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                              keyboardType: TextInputType.datetime,
                              readOnly: true,
                              showCursor: true,
                              onTap: () {
                                DatePicker.showDateTimePicker(
                                  context,
                                  currentTime: _untieFirstDateTime,
                                  locale: LocaleType.pt,
                                ).then(
                                  (value) {
                                    setState(() {
                                      _untieFirstController.text =
                                          value?.toString() ??
                                              _untieFirstController.text;
                                      _untieFirstDateTime =
                                          value ?? _untieFirstDateTime;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          _inProgress[4]
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : IconButton(
                                  onPressed: (_untieFirstDateTime == null ||
                                          _untieFirstMooring == null ||
                                          _isSet[4])
                                      ? null
                                      : () async {
                                          setState(() {
                                            _inProgress[4] = true;
                                          });
                                          await DockingInterface.patchMooring(
                                              widget.berth.dockingId,
                                              _untieFirstMooring["mooring_id"],
                                              {
                                                ..._untieFirstMooring,
                                                "untied_at":
                                                    _untieFirstDateTime!
                                                        .toIso8601String(),
                                                "type": jsonEncode([
                                                  ...(tryDecode(
                                                          _untieFirstMooring[
                                                              "type"]) ??
                                                      []),
                                                  "FirstUntie"
                                                ])
                                              });
                                          await docking$
                                              .refresh(docking["docking_id"]);
                                          setState(() {
                                            _inProgress[4] = false;
                                          });
                                        },
                                  icon: const Icon(Icons.save),
                                ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: DropdownButtonFormField<dynamic>(
                              value: _untieLastMooring?["mooring_id"],
                              validator: (value) =>
                                  value == null ? 'Requerido' : null,
                              dropdownColor: const Color(0xFF292B2F),
                              decoration: const InputDecoration(
                                labelText: "Último Cabo",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                              items: _mooringList
                                  ?.map((e) => DropdownMenuItem<dynamic>(
                                      value: e["mooring_id"],
                                      child: Text(
                                          "${e["hawser_desc"]} / ${e['bollard_name']}")))
                                  .toList(),
                              onChanged: (dynamic val) {
                                setState(() {
                                  _untieLastMooring = _mooringList!.firstWhere(
                                      (element) =>
                                          element["mooring_id"] == val);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              validator: (value) =>
                                  value!.isEmpty ? 'Requerido' : null,
                              controller: _untieLastController,
                              decoration: const InputDecoration(
                                labelText: "Data",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                              keyboardType: TextInputType.datetime,
                              readOnly: true,
                              showCursor: true,
                              onTap: () {
                                DatePicker.showDateTimePicker(
                                  context,
                                  currentTime: _untieLastDateTime,
                                  locale: LocaleType.pt,
                                ).then(
                                  (value) {
                                    setState(() {
                                      _untieLastController.text =
                                          value?.toString() ??
                                              _untieLastController.text;
                                      _untieLastDateTime =
                                          value ?? _untieLastDateTime;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          _inProgress[5]
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : IconButton(
                                  onPressed: (_untieLastDateTime == null ||
                                          _untieLastMooring == null ||
                                          _isSet[5])
                                      ? null
                                      : () async {
                                          setState(() {
                                            _inProgress[5] = true;
                                          });
                                          await DockingInterface.patchMooring(
                                              widget.berth.dockingId,
                                              _untieLastMooring["mooring_id"], {
                                            ..._untieLastMooring,
                                            "untied_at": _untieLastDateTime!
                                                .toIso8601String(),
                                            "type": jsonEncode([
                                              ...(tryDecode(_untieLastMooring[
                                                      "type"]) ??
                                                  []),
                                              "LastUntie"
                                            ])
                                          });

                                          List<Future<dynamic>> futures = [];
                                          (docking["mooring"] as List)
                                              .where((mooring) =>
                                                  mooring["untied_at"] ==
                                                      null &&
                                                  mooring["broken_at"] == null)
                                              .forEach((mooring) =>
                                                  futures.add(
                                                      DockingInterface
                                                          .patchMooring(
                                                              widget.berth
                                                                  .dockingId,
                                                              mooring[
                                                                  "mooring_id"],
                                                              {
                                                        ...mooring,
                                                        "untied_at":
                                                            _untieLastDateTime!
                                                                .toIso8601String()
                                                      })));
                                          Future.wait(futures);

                                          await docking$
                                              .refresh(docking["docking_id"]);
                                          setState(() {
                                            _inProgress[5] = false;
                                          });
                                        },
                                  icon: const Icon(Icons.save),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  void _populateMoorings(dynamic docking) {
    _mooringList = docking['mooring']?.reversed.toList();

    _tieFirstMooring = _mooringList?.firstWhere(
            (e) => tryDecode(e["type"])?.contains("FirstTie") ?? false,
            orElse: () => null) ??
        _tieFirstMooring;
    _isSet[0] = _tieFirstMooring != null &&
        (_tieFirstMooring["type"]?.contains("FirstTie") ?? false);
    if (_isSet[0]) {
      _tieFirstController.text = _tieFirstMooring?["tied_at"] ?? "";
    }

    _tieLastMooring = _mooringList?.firstWhere(
            (e) => tryDecode(e["type"])?.contains("LastTie") ?? false,
            orElse: () => null) ??
        _tieLastMooring;
    _isSet[1] = _tieLastMooring != null &&
        (_tieLastMooring["type"]?.contains("LastTie") ?? false);
    if (_isSet[1]) {
      _tieLastController.text = _tieLastMooring?["tied_at"] ?? "";
    }

    _bowMooring = _mooringList?.firstWhere(
            (e) => tryDecode(e["type"])?.contains("BowDistance") ?? false,
            orElse: () => null) ??
        _bowMooring;
    _isSet[2] = _bowMooring != null &&
        (_bowMooring["type"]?.contains("BowDistance") ?? false);
    if (_isSet[2]) {
      _bowController.text = _bowMooring?["distance"].toString() ?? "";
    }

    _sternMooring = _mooringList?.firstWhere(
            (e) => tryDecode(e["type"])?.contains("SternDistance") ?? false,
            orElse: () => null) ??
        _sternMooring;
    _isSet[3] = _sternMooring != null &&
        (_sternMooring["type"]?.contains("SternDistance") ?? false);
    if (_isSet[3]) {
      _sternController.text = _sternMooring?["distance"].toString() ?? "";
    }

    _untieFirstMooring = _mooringList?.firstWhere(
            (e) => tryDecode(e["type"])?.contains("FirstUntie") ?? false,
            orElse: () => null) ??
        _untieFirstMooring;
    _isSet[4] = _untieFirstMooring != null &&
        (_untieFirstMooring["type"]?.contains("FirstUntie") ?? false);
    if (_isSet[4]) {
      _untieFirstController.text = _untieFirstMooring?["untied_at"] ?? "";
    }

    _untieLastMooring = _mooringList?.firstWhere(
            (e) => tryDecode(e["type"])?.contains("LastUntie") ?? false,
            orElse: () => null) ??
        _untieLastMooring;
    _isSet[5] = _untieLastMooring != null &&
        (_untieLastMooring["type"]?.contains("LastUntie") ?? false);
    if (_isSet[5]) {
      _untieLastController.text = _untieLastMooring?["untied_at"] ?? "";
    }
  }
}

dynamic tryDecode(data) {
  try {
    return jsonDecode(data);
  } catch (e) {
    return null;
  }
}
