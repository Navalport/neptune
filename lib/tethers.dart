import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:neptune/interfaces.dart';
import 'package:neptune/types.dart';

class TethersWidget extends StatefulWidget {
  final Berth berth;
  final dynamic docking;
  final List<dynamic> hawsers, bollards;

  const TethersWidget(
      {Key? key, required this.berth, required this.docking, required this.hawsers, required this.bollards})
      : super(key: key);

  @override
  State<TethersWidget> createState() => _TethersWidgetState();
}

class _TethersWidgetState extends State<TethersWidget> {
  DateTime? _tieFirstDateTime, _tieLastDateTime, _untieFirstDateTime, _untieLastDateTime;
  dynamic _tieFirstBollard, _tieLastBollard, _untieFirstBollard, _untieLastBollard, _bowBollard, _sternBollard;
  final _bowController = TextEditingController();
  final _sternController = TextEditingController();
  final _tieFirstController = TextEditingController();
  final _tieLastController = TextEditingController();
  final _untieFirstController = TextEditingController();
  final _untieLastController = TextEditingController();
  List<bool> _inProgress = List.filled(6, false);

  @override
  void initState() {
    super.initState();
  }

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
                      child: DropdownButtonFormField<dynamic>(
                        value: _tieFirstBollard,
                        validator: (value) => value == null ? 'Requerido' : null,
                        dropdownColor: const Color(0xFF292B2F),
                        decoration: const InputDecoration(
                          labelText: "Primeiro Cabeço",
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        items: widget.bollards
                            .map((e) => DropdownMenuItem<dynamic>(value: e, child: Text(e['bollard_name'])))
                            .toList(),
                        onChanged: (dynamic val) {
                          setState(() {
                            _tieFirstBollard = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 1,
                      child: TextFormField(
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
                            currentTime: _tieFirstDateTime,
                            locale: LocaleType.pt,
                          ).then(
                            (value) {
                              setState(() {
                                _tieFirstController.text = value?.toString() ?? _tieFirstController.text;
                                _tieFirstDateTime = value ?? _tieFirstDateTime;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    _inProgress[0]
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : IconButton(
                            onPressed: () {},
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
                        value: _tieLastBollard,
                        validator: (value) => value == null ? 'Requerido' : null,
                        dropdownColor: const Color(0xFF292B2F),
                        decoration: const InputDecoration(
                          labelText: "Último Cabeço",
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        items: widget.bollards
                            .map((e) => DropdownMenuItem<dynamic>(value: e, child: Text(e['bollard_name'])))
                            .toList(),
                        onChanged: (dynamic val) {
                          setState(() {
                            _tieLastBollard = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 1,
                      child: TextFormField(
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
                            currentTime: _tieLastDateTime,
                            locale: LocaleType.pt,
                          ).then(
                            (value) {
                              setState(() {
                                _tieLastController.text = value?.toString() ?? _tieLastController.text;
                                _tieLastDateTime = value ?? _tieLastDateTime;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    _inProgress[1]
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : IconButton(
                            onPressed: () {},
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
                        value: _bowBollard,
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
                            _bowBollard = val;
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
                            labelText: "Proa", suffixText: "m", suffixStyle: Theme.of(context).textTheme.bodyText2),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    _inProgress[2]
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : IconButton(
                            onPressed: () {},
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
                        value: _sternBollard,
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
                            _sternBollard = val;
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
                            labelText: "Popa", suffixText: "m", suffixStyle: Theme.of(context).textTheme.bodyText2),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    _inProgress[3]
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : IconButton(
                            onPressed: () {},
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
                        value: _untieFirstBollard,
                        validator: (value) => value == null ? 'Requerido' : null,
                        dropdownColor: const Color(0xFF292B2F),
                        decoration: const InputDecoration(
                          labelText: "Primeiro Cabeço",
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        items: widget.bollards
                            .map((e) => DropdownMenuItem<dynamic>(value: e, child: Text(e['bollard_name'])))
                            .toList(),
                        onChanged: (dynamic val) {
                          setState(() {
                            _untieFirstBollard = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 1,
                      child: TextFormField(
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
                            currentTime: _untieFirstDateTime,
                            locale: LocaleType.pt,
                          ).then(
                            (value) {
                              setState(() {
                                _untieFirstController.text = value?.toString() ?? _untieFirstController.text;
                                _untieFirstDateTime = value ?? _untieFirstDateTime;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    _inProgress[4]
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : IconButton(
                            onPressed: () {},
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
                        value: _untieLastBollard,
                        validator: (value) => value == null ? 'Requerido' : null,
                        dropdownColor: const Color(0xFF292B2F),
                        decoration: const InputDecoration(
                          labelText: "Último Cabeço",
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        items: widget.bollards
                            .map((e) => DropdownMenuItem<dynamic>(value: e, child: Text(e['bollard_name'])))
                            .toList(),
                        onChanged: (dynamic val) {
                          setState(() {
                            _untieLastBollard = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 1,
                      child: TextFormField(
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
                            currentTime: _untieLastDateTime,
                            locale: LocaleType.pt,
                          ).then(
                            (value) {
                              setState(() {
                                _untieLastController.text = value?.toString() ?? _untieLastController.text;
                                _untieLastDateTime = value ?? _untieLastDateTime;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    _inProgress[5]
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : IconButton(
                            onPressed: () {},
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
  }
}
