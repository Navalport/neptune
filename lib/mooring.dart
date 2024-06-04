import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:mooringapp/interfaces.dart';
import 'package:mooringapp/types.dart';

class MooringWidget extends StatefulWidget {
  final Stage stage;
  final List<Hawser> hawsers;
  final List<Bollard> bollards;

  const MooringWidget({Key? key, required this.stage, required this.hawsers, required this.bollards}) : super(key: key);

  @override
  State<MooringWidget> createState() => _MooringWidgetState();
}

class _MooringWidgetState extends State<MooringWidget> {
  DateTime? _firstTieDateTime, _lastTieDateTime, _firstUntieDateTime, _lastUntieDateTime;
  Tether? _firstTieTether, _lastTieTether, _firstUntieTether, _lastUntieTether, _bowTether, _sternTether;
  Mooring? _mooring;
  final _bowController = TextEditingController();
  final _sternController = TextEditingController();
  final _tieFirstController = TextEditingController();
  final _tieLastController = TextEditingController();
  final _untieFirstController = TextEditingController();
  final _untieLastController = TextEditingController();
  final _lock0 = TextEditingController();
  final _lock1 = TextEditingController();
  final _lock2 = TextEditingController();
  final _lock3 = TextEditingController();
  final _lock4 = TextEditingController();
  final _lock5 = TextEditingController();
  final List<bool> _inProgress = List.filled(6, false);
  final List<bool> _isSet = List.filled(6, false);
  StageBehaviorSubject stage$ = StageBehaviorSubject();

  @override
  void dispose() {
    _bowController.dispose();
    _sternController.dispose();
    _tieFirstController.dispose();
    _tieLastController.dispose();
    _untieFirstController.dispose();
    _untieLastController.dispose();
    _lock0.dispose();
    _lock1.dispose();
    _lock2.dispose();
    _lock3.dispose();
    _lock4.dispose();
    _lock5.dispose();
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
        _populateMoorings(stage);

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
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
                          child: !_isSet[0]
                              ? DropdownButtonFormField(
                                  value: _firstTieTether?.tether_id,
                                  validator: (value) => value == null ? 'Requerido' : null,
                                  dropdownColor: const Color(0xFF292B2F),
                                  decoration: const InputDecoration(
                                    labelText: "Primeiro Cabo",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  items: ((_mooring?.tethers ?? []))
                                      .map((e) => DropdownMenuItem(
                                          value: e.tether_id,
                                          child: Text(
                                              "${getHawser(e.hawser_id).hawser_desc} / ${getBollard(e.bollard_id).bollard_name}")))
                                      .toList(),
                                  onChanged: (int? val) {
                                    setState(() {
                                      _firstTieTether =
                                          _mooring?.tethers.firstWhere((element) => element.tether_id == val);
                                    });
                                  },
                                )
                              : TextFormField(
                                  enabled: !_isSet[0],
                                  decoration: const InputDecoration(
                                    labelText: "Primeiro Cabo",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  controller: _lock0,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            enabled: !_isSet[0],
                            validator: (value) => value!.isEmpty ? 'Requerido' : null,
                            controller: _tieFirstController,
                            decoration: const InputDecoration(
                              labelText: "Data",
                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            ),
                            keyboardType: TextInputType.datetime,
                            readOnly: true,
                            showCursor: true,
                            onTap: () {
                              DatePicker.showDateTimePicker(
                                context,
                                currentTime: _firstTieDateTime,
                                locale: LocaleType.pt,
                              ).then(
                                (value) {
                                  setState(() {
                                    _tieFirstController.text = value?.toString() ?? _tieFirstController.text;
                                    _firstTieDateTime = value ?? _firstTieDateTime;
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
                                onPressed: (_firstTieDateTime == null || _firstTieTether == null || _isSet[0])
                                    ? null
                                    : () async {
                                        setState(() {
                                          _inProgress[0] = true;
                                        });
                                        await DockingsInterface.bindTether(
                                          _mooring!.mooring_id,
                                          _firstTieTether!.tether_id,
                                          {
                                            ..._mooring!.toMap(),
                                            "tie_started_at": _firstTieDateTime!.toIso8601String(),
                                          },
                                          {
                                            ..._firstTieTether!.toMap(),
                                            "first_tie": true,
                                          },
                                        );
                                        await stage$.refresh(stage.stage_id);
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
                          child: !_isSet[1]
                              ? DropdownButtonFormField(
                                  value: _lastTieTether?.tether_id,
                                  validator: (value) => value == null ? 'Requerido' : null,
                                  dropdownColor: const Color(0xFF292B2F),
                                  decoration: const InputDecoration(
                                    labelText: "Último Cabo",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  items: ((_mooring?.tethers ?? []))
                                      .map((e) => DropdownMenuItem(
                                          value: e.tether_id,
                                          child: Text(
                                              "${getHawser(e.hawser_id).hawser_desc} / ${getBollard(e.bollard_id).bollard_name}")))
                                      .toList(),
                                  onChanged: (int? val) {
                                    setState(() {
                                      _lastTieTether =
                                          _mooring?.tethers.firstWhere((element) => element.tether_id == val);
                                    });
                                  },
                                )
                              : TextFormField(
                                  enabled: !_isSet[1],
                                  decoration: const InputDecoration(
                                    labelText: "Último Cabo",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  controller: _lock1,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            enabled: !_isSet[1],
                            validator: (value) => value!.isEmpty ? 'Requerido' : null,
                            controller: _tieLastController,
                            decoration: const InputDecoration(
                              labelText: "Data",
                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            ),
                            keyboardType: TextInputType.datetime,
                            readOnly: true,
                            showCursor: true,
                            onTap: () {
                              DatePicker.showDateTimePicker(
                                context,
                                currentTime: _lastTieDateTime,
                                locale: LocaleType.pt,
                              ).then(
                                (value) {
                                  setState(() {
                                    _tieLastController.text = value?.toString() ?? _tieLastController.text;
                                    _lastTieDateTime = value ?? _lastTieDateTime;
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
                                onPressed: (_lastTieDateTime == null || _lastTieTether == null || _isSet[1])
                                    ? null
                                    : () async {
                                        setState(() {
                                          _inProgress[1] = true;
                                        });
                                        await DockingsInterface.bindTether(
                                          _mooring!.mooring_id,
                                          _lastTieTether!.tether_id,
                                          {
                                            ..._mooring!.toMap(),
                                            "tie_finished_at": _lastTieDateTime!.toIso8601String(),
                                          },
                                          {
                                            ..._lastTieTether!.toMap(),
                                            "last_tie": true,
                                          },
                                        );
                                        await stage$.refresh(stage.stage_id);
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
                          child: !_isSet[2]
                              ? DropdownButtonFormField(
                                  value: _bowTether?.tether_id,
                                  validator: (value) => value == null ? 'Requerido' : null,
                                  dropdownColor: const Color(0xFF292B2F),
                                  decoration: const InputDecoration(
                                    labelText: "Cabeço",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  items: ((_mooring?.tethers ?? []))
                                      .where((e) => e.pristine == true)
                                      .map((e) => DropdownMenuItem(
                                          value: e.tether_id, child: Text(getBollard(e.bollard_id).bollard_name)))
                                      .toList(),
                                  onChanged: (int? val) {
                                    setState(() {
                                      _bowTether = _mooring?.tethers.firstWhere((element) => element.tether_id == val);
                                    });
                                  },
                                )
                              : TextFormField(
                                  enabled: !_isSet[2],
                                  decoration: const InputDecoration(
                                    labelText: "Cabeço",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  controller: _lock2,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 1,
                          child: TextField(
                            enabled: !_isSet[2],
                            controller: _bowController,
                            cursorColor: const Color(0xFFE4F8EF),
                            decoration: InputDecoration(
                                labelText: "Proa",
                                suffixText: "m",
                                suffixStyle: Theme.of(context).textTheme.bodyMedium),
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
                                onPressed: (_bowController.text.isEmpty || _bowTether == null || _isSet[2])
                                    ? null
                                    : () async {
                                        setState(() {
                                          _inProgress[2] = true;
                                        });
                                        await DockingsInterface.patchTether(_bowTether!.tether_id, {
                                          ..._bowTether!.toMap(),
                                          "bow_distance": double.parse(_bowController.text),
                                        });
                                        await stage$.refresh(stage.stage_id);
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
                          child: !_isSet[3]
                              ? DropdownButtonFormField(
                                  value: _sternTether?.tether_id,
                                  validator: (value) => value == null ? 'Requerido' : null,
                                  dropdownColor: const Color(0xFF292B2F),
                                  decoration: const InputDecoration(
                                    labelText: "Cabeço",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  items: ((_mooring?.tethers ?? []))
                                      .where((e) => e.pristine == true)
                                      .map((e) => DropdownMenuItem(
                                          value: e.tether_id, child: Text(getBollard(e.bollard_id).bollard_name)))
                                      .toList(),
                                  onChanged: (int? val) {
                                    setState(() {
                                      _sternTether =
                                          _mooring?.tethers.firstWhere((element) => element.tether_id == val);
                                    });
                                  },
                                )
                              : TextFormField(
                                  enabled: !_isSet[3],
                                  decoration: const InputDecoration(
                                    labelText: "Cabeço",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  controller: _lock3,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 1,
                          child: TextField(
                            enabled: !_isSet[3],
                            controller: _sternController,
                            cursorColor: const Color(0xFFE4F8EF),
                            decoration: InputDecoration(
                                labelText: "Popa",
                                suffixText: "m",
                                suffixStyle: Theme.of(context).textTheme.bodyMedium),
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
                                onPressed: (_sternController.text.isEmpty || _sternTether == null || _isSet[3])
                                    ? null
                                    : () async {
                                        setState(() {
                                          _inProgress[3] = true;
                                        });
                                        await DockingsInterface.patchTether(_sternTether!.tether_id, {
                                          ..._sternTether!.toMap(),
                                          "stern_distance": double.parse(_sternController.text),
                                        });
                                        await stage$.refresh(stage.stage_id);
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
                          child: !_isSet[4]
                              ? DropdownButtonFormField(
                                  value: _firstUntieTether?.tether_id,
                                  validator: (value) => value == null ? 'Requerido' : null,
                                  dropdownColor: const Color(0xFF292B2F),
                                  decoration: const InputDecoration(
                                    labelText: "Primeiro Cabo",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  items: ((_mooring?.tethers ?? []))
                                      .map((e) => DropdownMenuItem(
                                          value: e.tether_id,
                                          child: Text(
                                              "${getHawser(e.hawser_id).hawser_desc} / ${getBollard(e.bollard_id).bollard_name}")))
                                      .toList(),
                                  onChanged: (int? val) {
                                    setState(() {
                                      _firstUntieTether =
                                          _mooring?.tethers.firstWhere((element) => element.tether_id == val);
                                    });
                                  },
                                )
                              : TextFormField(
                                  enabled: !_isSet[4],
                                  decoration: const InputDecoration(
                                    labelText: "Primeiro Cabo",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  controller: _lock4,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            enabled: !_isSet[4],
                            validator: (value) => value!.isEmpty ? 'Requerido' : null,
                            controller: _untieFirstController,
                            decoration: const InputDecoration(
                              labelText: "Data",
                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            ),
                            keyboardType: TextInputType.datetime,
                            readOnly: true,
                            showCursor: true,
                            onTap: () {
                              DatePicker.showDateTimePicker(
                                context,
                                currentTime: _firstUntieDateTime,
                                locale: LocaleType.pt,
                              ).then(
                                (value) {
                                  setState(() {
                                    _untieFirstController.text = value?.toString() ?? _untieFirstController.text;
                                    _firstUntieDateTime = value ?? _firstUntieDateTime;
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
                                onPressed: (_firstUntieDateTime == null || _firstUntieTether == null || _isSet[4])
                                    ? null
                                    : () async {
                                        setState(() {
                                          _inProgress[4] = true;
                                        });
                                        await DockingsInterface.bindTether(
                                          _mooring!.mooring_id,
                                          _firstUntieTether!.tether_id,
                                          {
                                            ..._mooring!.toMap(),
                                            "untie_started_at": _firstUntieDateTime!.toIso8601String(),
                                          },
                                          {
                                            ..._firstUntieTether!.toMap(),
                                            "first_untie": true,
                                            "pristine": null,
                                          },
                                        );
                                        await stage$.refresh(stage.stage_id);
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
                          child: !_isSet[5]
                              ? DropdownButtonFormField(
                                  value: _lastUntieTether?.tether_id,
                                  validator: (value) => value == null ? 'Requerido' : null,
                                  dropdownColor: const Color(0xFF292B2F),
                                  decoration: const InputDecoration(
                                    labelText: "Último Cabo",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  items: ((_mooring?.tethers ?? []))
                                      .map((e) => DropdownMenuItem(
                                          value: e.tether_id,
                                          child: Text(
                                              "${getHawser(e.hawser_id).hawser_desc} / ${getBollard(e.bollard_id).bollard_name}")))
                                      .toList(),
                                  onChanged: (int? val) {
                                    setState(() {
                                      _lastUntieTether =
                                          _mooring?.tethers.firstWhere((element) => element.tether_id == val);
                                    });
                                  },
                                )
                              : TextFormField(
                                  enabled: !_isSet[5],
                                  decoration: const InputDecoration(
                                    labelText: "Último Cabo",
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                  controller: _lock5,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            enabled: !_isSet[5],
                            validator: (value) => value!.isEmpty ? 'Requerido' : null,
                            controller: _untieLastController,
                            decoration: const InputDecoration(
                              labelText: "Data",
                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            ),
                            keyboardType: TextInputType.datetime,
                            readOnly: true,
                            showCursor: true,
                            onTap: () {
                              DatePicker.showDateTimePicker(
                                context,
                                currentTime: _lastUntieDateTime,
                                locale: LocaleType.pt,
                              ).then(
                                (value) {
                                  setState(() {
                                    _untieLastController.text = value?.toString() ?? _untieLastController.text;
                                    _lastUntieDateTime = value ?? _lastUntieDateTime;
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
                                onPressed: (_lastUntieDateTime == null || _lastUntieTether == null || _isSet[5])
                                    ? null
                                    : () async {
                                        setState(() {
                                          _inProgress[5] = true;
                                        });
                                        List<Future<dynamic>> futures = [];
                                        futures.add(DockingsInterface.bindTether(
                                          _mooring!.mooring_id,
                                          _lastUntieTether!.tether_id,
                                          {
                                            ..._mooring!.toMap(),
                                            "untie_finished_at": _lastUntieDateTime!.toIso8601String(),
                                          },
                                          {
                                            ..._lastUntieTether!.toMap(),
                                            "last_untie": true,
                                            "pristine": null,
                                          },
                                        ));

                                        //unties remaning tethers
                                        _mooring?.tethers
                                            .where((tether) =>
                                                tether.pristine == true &&
                                                tether.tether_id != _lastUntieTether!.tether_id)
                                            .forEach((tether) =>
                                                futures.add(DockingsInterface.patchTether(tether.tether_id, {
                                                  ...tether.toMap(),
                                                  "pristine": null,
                                                })));

                                        await Future.wait(futures);

                                        await stage$.refresh(stage.stage_id);
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
      },
    );
  }

  void _populateMoorings(Stage stage) {
    _mooring = (stage.moorings?.isEmpty ?? false) ? null : stage.moorings!.first;
    List<Tether>? temp;

    temp = _mooring?.tethers.where((e) => e.first_tie == true).toList();
    _firstTieTether = (temp ?? []).isEmpty ? _firstTieTether : temp?.first;
    _isSet[0] = _firstTieTether != null && (_firstTieTether!.first_tie == true);
    if (_isSet[0]) {
      _tieFirstController.text = _mooring!.tie_started_at!;
      _lock0.text =
          "${getHawser(_firstTieTether!.hawser_id).hawser_desc} / ${getBollard(_firstTieTether!.bollard_id).bollard_name}";
    }

    temp = _mooring?.tethers.where((e) => e.last_tie == true).toList();
    _lastTieTether = (temp ?? []).isEmpty ? _lastTieTether : temp?.first;
    _isSet[1] = _lastTieTether != null && (_lastTieTether!.last_tie == true);
    if (_isSet[1]) {
      _tieLastController.text = _mooring!.tie_finished_at ?? "";
      _lock1.text =
          "${getHawser(_lastTieTether!.hawser_id).hawser_desc} / ${getBollard(_lastTieTether!.bollard_id).bollard_name}";
    }

    temp = _mooring?.tethers.where((e) => e.bow_distance != null).toList();
    _bowTether = (temp ?? []).isEmpty ? _bowTether : temp?.first;
    _isSet[2] = _bowTether != null && _bowTether!.bow_distance != null;
    if (_isSet[2]) {
      _bowController.text = _bowTether!.bow_distance.toString();
      _lock2.text = getBollard(_bowTether!.bollard_id).bollard_name;
    }

    temp = _mooring?.tethers.where((e) => e.stern_distance != null).toList();
    _sternTether = (temp ?? []).isEmpty ? _sternTether : temp?.first;
    _isSet[3] = _sternTether != null && _sternTether!.stern_distance != null;
    if (_isSet[3]) {
      _sternController.text = _sternTether!.stern_distance.toString();
      _lock3.text = getBollard(_sternTether!.bollard_id).bollard_name;
    }

    temp = _mooring?.tethers.where((e) => e.first_untie == true).toList();
    _firstUntieTether = (temp ?? []).isEmpty ? _firstUntieTether : temp?.first;
    _isSet[4] = _firstUntieTether != null && (_firstUntieTether!.first_untie == true);
    if (_isSet[4]) {
      _untieFirstController.text = _mooring!.untie_started_at ?? "";
      _lock4.text =
          "${getHawser(_firstUntieTether!.hawser_id).hawser_desc} / ${getBollard(_firstUntieTether!.bollard_id).bollard_name}";
    }

    temp = _mooring?.tethers.where((e) => e.last_untie == true).toList();
    _lastUntieTether = (temp ?? []).isEmpty ? _lastUntieTether : temp?.first;
    _isSet[5] = _lastUntieTether != null && (_lastUntieTether!.last_untie == true);
    if (_isSet[5]) {
      _untieLastController.text = _mooring!.untie_finished_at ?? "";
      _lock5.text =
          "${getHawser(_lastUntieTether!.hawser_id).hawser_desc} / ${getBollard(_lastUntieTether!.bollard_id).bollard_name}";
    }
  }

  Hawser getHawser(int id) {
    return widget.hawsers.firstWhere((hawser) => hawser.hawser_id == id);
  }

  Bollard getBollard(int id) {
    return widget.bollards.firstWhere((bollard) => bollard.bollard_id == id);
  }
}

dynamic tryDecode(data) {
  try {
    return jsonDecode(data);
  } catch (e) {
    return null;
  }
}
