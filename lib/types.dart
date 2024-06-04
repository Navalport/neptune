// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import 'interfaces.dart';

enum DraftPosition { mean, aft, mid, fore }

enum DraftType { declared, arrival, loading, leaving }

class StageBehaviorSubject {
  static final StageBehaviorSubject _singleton = StageBehaviorSubject._internal();
  final BehaviorSubject<Stage> _stageController = BehaviorSubject<Stage>();

  factory StageBehaviorSubject() {
    return _singleton;
  }

  Stream<Stage> getStream() {
    return _stageController.stream;
  }

  void setValue(Stage value) {
    _stageController.add(value);
  }

  Future<void> refresh(int stageId) async {
    var value = await VoyageInterface.getStage(stageId);
    _stageController.add(value);
    return;
  }

  StageBehaviorSubject._internal();
}

class VoyagesBehaviorSubject {
  static final VoyagesBehaviorSubject _singleton = VoyagesBehaviorSubject._internal();
  final BehaviorSubject<List<Voyage>> _voyagesController = BehaviorSubject<List<Voyage>>();

  factory VoyagesBehaviorSubject() {
    return _singleton;
  }

  Stream<List<Voyage>> getStream() {
    return _voyagesController.stream;
  }

  void setValue(List<Voyage> value) {
    _voyagesController.add(value);
  }

  Future<void> refresh() async {
    var value = await VoyageInterface.getVoyages();
    _voyagesController.add(value);
    return;
  }

  VoyagesBehaviorSubject._internal();
}

class VoyageBehaviorSubject {
  static final VoyageBehaviorSubject _singleton = VoyageBehaviorSubject._internal();
  final BehaviorSubject<Voyage> _voyageController = BehaviorSubject<Voyage>();

  factory VoyageBehaviorSubject() {
    return _singleton;
  }

  Stream<Voyage> getStream() {
    return _voyageController.stream;
  }

  void setValue(Voyage value) {
    _voyageController.add(value);
  }

  Future<void> refresh(int voyageId) async {
    var value = await VoyageInterface.getVoyage(voyageId);
    _voyageController.add(Voyage.fromMap(value));
    return;
  }

  Future<void> refreshFromList(int voyageId) async {
    VoyagesBehaviorSubject voyages$ = VoyagesBehaviorSubject();

    await voyages$.refresh();
    voyages$
        .getStream()
        .first
        .then((value) => _voyageController.add(value.firstWhere((voyage) => voyage.voyage_id == voyageId)));
    return;
  }

  VoyageBehaviorSubject._internal();
}

class InfinityDateTime {
  late bool _isInfinity;
  DateTime? _dateTime;

  InfinityDateTime(dynamic dateTime) {
    assert(dateTime is String || dateTime is DateTime);

    if (dateTime is String) {
      _isInfinity = (dateTime == "infinity");
      _dateTime = _isInfinity ? null : DateTime.parse(dateTime);
    } else if (dateTime is DateTime) {
      _isInfinity = false;
      _dateTime = dateTime;
    }
  }

  String getParse() {
    return _isInfinity ? "infinity" : _dateTime!.toIso8601String();
  }

  DateTime? getDateTime() {
    return _dateTime;
  }
}

class Estimate {
  int estimate_id;
  int voyage_id;
  int stage_id;
  String tstamp;
  int? fence_id;
  DateTime ets;
  DateTime etf;
  bool official;
  bool confirmed;
  int sequential;

  Estimate({
    required this.estimate_id,
    required this.voyage_id,
    required this.stage_id,
    required this.tstamp,
    this.fence_id,
    required this.ets,
    required this.etf,
    required this.official,
    required this.confirmed,
    required this.sequential,
  });

  Estimate copyWith({
    int? estimate_id,
    int? voyage_id,
    int? stage_id,
    String? tstamp,
    int? fence_id,
    DateTime? ets,
    DateTime? etf,
    bool? official,
    bool? confirmed,
    int? sequential,
  }) {
    return Estimate(
      estimate_id: estimate_id ?? this.estimate_id,
      voyage_id: voyage_id ?? this.voyage_id,
      stage_id: stage_id ?? this.stage_id,
      tstamp: tstamp ?? this.tstamp,
      fence_id: fence_id ?? this.fence_id,
      ets: ets ?? this.ets,
      etf: etf ?? this.etf,
      official: official ?? this.official,
      confirmed: confirmed ?? this.confirmed,
      sequential: sequential ?? this.sequential,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'estimate_id': estimate_id,
      'voyage_id': voyage_id,
      'stage_id': stage_id,
      'tstamp': tstamp,
      'fence_id': fence_id,
      'ets': ets.toIso8601String(),
      'etf': etf.toIso8601String(),
      'official': official,
      'confirmed': confirmed,
      'sequential': sequential,
    };
  }

  factory Estimate.fromMap(Map<String, dynamic> map) {
    return Estimate(
      estimate_id: map['estimate_id'] as int,
      voyage_id: map['voyage_id'] as int,
      stage_id: map['stage_id'] as int,
      tstamp: map['tstamp'] as String,
      fence_id: map['fence_id'] != null ? map['fence_id'] as int : null,
      ets: DateTime.parse(map['ets']),
      etf: DateTime.parse(map['etf']),
      official: map['official'] as bool,
      confirmed: map['confirmed'] as bool,
      sequential: map['sequential'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Estimate.fromJson(String source) => Estimate.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Estimate(estimate_id: $estimate_id, voyage_id: $voyage_id, stage_id: $stage_id, tstamp: $tstamp, fence_id: $fence_id, ets: $ets, etf: $etf, official: $official, confirmed: $confirmed, sequential: $sequential)';
  }

  @override
  bool operator ==(covariant Estimate other) {
    if (identical(this, other)) return true;

    return other.estimate_id == estimate_id &&
        other.voyage_id == voyage_id &&
        other.stage_id == stage_id &&
        other.tstamp == tstamp &&
        other.fence_id == fence_id &&
        other.ets == ets &&
        other.etf == etf &&
        other.official == official &&
        other.confirmed == confirmed &&
        other.sequential == sequential;
  }

  @override
  int get hashCode {
    return estimate_id.hashCode ^
        voyage_id.hashCode ^
        stage_id.hashCode ^
        tstamp.hashCode ^
        fence_id.hashCode ^
        ets.hashCode ^
        etf.hashCode ^
        official.hashCode ^
        confirmed.hashCode ^
        sequential.hashCode;
  }
}

class Org {
  int org_id;
  String id;
  String id_type;
  String name;
  String? desc;
  String? picture;

  Org({
    required this.org_id,
    required this.id,
    required this.id_type,
    required this.name,
    this.desc,
    this.picture,
  });

  Org copyWith({
    int? org_id,
    String? id,
    String? id_type,
    String? name,
    String? desc,
    String? picture,
  }) {
    return Org(
      org_id: org_id ?? this.org_id,
      id: id ?? this.id,
      id_type: id_type ?? this.id_type,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      picture: picture ?? this.picture,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'org_id': org_id,
      'id': id,
      'id_type': id_type,
      'name': name,
      'desc': desc,
      'picture': picture,
    };
  }

  factory Org.fromMap(Map<String, dynamic> map) {
    return Org(
      org_id: map['org_id'] as int,
      id: map['id'] as String,
      id_type: map['id_type'] as String,
      name: map['name'] as String,
      desc: map['desc'] != null ? map['desc'] as String : null,
      picture: map['picture'] != null ? map['picture'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Org.fromJson(String source) => Org.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Org(org_id: $org_id, id: $id, id_type: $id_type, name: $name, desc: $desc, picture: $picture)';
  }

  @override
  bool operator ==(covariant Org other) {
    if (identical(this, other)) return true;

    return other.org_id == org_id &&
        other.id == id &&
        other.id_type == id_type &&
        other.name == name &&
        other.desc == desc &&
        other.picture == picture;
  }

  @override
  int get hashCode {
    return org_id.hashCode ^ id.hashCode ^ id_type.hashCode ^ name.hashCode ^ desc.hashCode ^ picture.hashCode;
  }
}

class Drafting {
  int drafting_id;
  String tstamp;
  int stage_id;
  num draft;
  DraftPosition position;
  DraftType type;
  String date;

  Drafting({
    required this.drafting_id,
    required this.tstamp,
    required this.stage_id,
    required this.draft,
    required this.position,
    required this.type,
    required this.date,
  });

  Drafting copyWith({
    int? drafting_id,
    String? tstamp,
    int? stage_id,
    num? draft,
    DraftPosition? position,
    DraftType? type,
    String? date,
  }) {
    return Drafting(
      drafting_id: drafting_id ?? this.drafting_id,
      tstamp: tstamp ?? this.tstamp,
      stage_id: stage_id ?? this.stage_id,
      draft: draft ?? this.draft,
      position: position ?? this.position,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'drafting_id': drafting_id,
      'tstamp': tstamp,
      'stage_id': stage_id,
      'draft': draft,
      'position': EnumToString.convertToString(position),
      'type': EnumToString.convertToString(type),
      'date': date,
    };
  }

  factory Drafting.fromMap(Map<String, dynamic> map) {
    return Drafting(
      drafting_id: map['drafting_id']?.toInt() ?? 0,
      tstamp: map['tstamp'] ?? '',
      stage_id: map['stage_id']?.toInt() ?? 0,
      draft: map['draft'] ?? 0,
      position: DraftPosition.values.byName(map['position']),
      type: DraftType.values.byName(map['type']),
      date: map['date'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Drafting.fromJson(String source) => Drafting.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Drafting(drafting_id: $drafting_id, tstamp: $tstamp, stage_id: $stage_id, draft: $draft, position: $position, type: $type, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Drafting &&
        other.drafting_id == drafting_id &&
        other.tstamp == tstamp &&
        other.stage_id == stage_id &&
        other.draft == draft &&
        other.position == position &&
        other.type == type &&
        other.date == date;
  }

  @override
  int get hashCode {
    return drafting_id.hashCode ^
        tstamp.hashCode ^
        stage_id.hashCode ^
        draft.hashCode ^
        position.hashCode ^
        type.hashCode ^
        date.hashCode;
  }
}

class Hawser {
  int hawser_id;
  String hawser_desc;
  num x;
  num y;

  Hawser({
    required this.hawser_id,
    required this.hawser_desc,
    required this.x,
    required this.y,
  });

  Hawser copyWith({
    int? hawser_id,
    String? hawser_desc,
    num? x,
    num? y,
  }) {
    return Hawser(
      hawser_id: hawser_id ?? this.hawser_id,
      hawser_desc: hawser_desc ?? this.hawser_desc,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hawser_id': hawser_id,
      'hawser_desc': hawser_desc,
      'x': x,
      'y': y,
    };
  }

  factory Hawser.fromMap(Map<String, dynamic> map) {
    return Hawser(
      hawser_id: map['hawser_id']?.toInt() ?? 0,
      hawser_desc: map['hawser_desc'] ?? '',
      x: map['x'] ?? 0,
      y: map['y'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Hawser.fromJson(String source) => Hawser.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Hawser(hawser_id: $hawser_id, hawser_desc: $hawser_desc, x: $x, y: $y)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Hawser &&
        other.hawser_id == hawser_id &&
        other.hawser_desc == hawser_desc &&
        other.x == x &&
        other.y == y;
  }

  @override
  int get hashCode {
    return hawser_id.hashCode ^ hawser_desc.hashCode ^ x.hashCode ^ y.hashCode;
  }
}

class Tether {
  int tether_id;
  int mooring_id;
  int hawser_id;
  int bollard_id;
  bool? first_tie;
  bool? last_tie;
  bool? first_untie;
  bool? last_untie;
  num? bow_distance;
  num? stern_distance;
  bool? pristine;
  bool broken;

  Tether({
    required this.tether_id,
    required this.mooring_id,
    required this.hawser_id,
    required this.bollard_id,
    this.first_tie,
    this.last_tie,
    this.first_untie,
    this.last_untie,
    this.bow_distance,
    this.stern_distance,
    this.pristine,
    required this.broken,
  });

  Tether copyWith({
    int? tether_id,
    int? mooring_id,
    int? hawser_id,
    int? bollard_id,
    bool? first_tie,
    bool? last_tie,
    bool? first_untie,
    bool? last_untie,
    num? bow_distance,
    num? stern_distance,
    bool? pristine,
    bool? broken,
  }) {
    return Tether(
      tether_id: tether_id ?? this.tether_id,
      mooring_id: mooring_id ?? this.mooring_id,
      hawser_id: hawser_id ?? this.hawser_id,
      bollard_id: bollard_id ?? this.bollard_id,
      first_tie: first_tie ?? this.first_tie,
      last_tie: last_tie ?? this.last_tie,
      first_untie: first_untie ?? this.first_untie,
      last_untie: last_untie ?? this.last_untie,
      bow_distance: bow_distance ?? this.bow_distance,
      stern_distance: stern_distance ?? this.stern_distance,
      pristine: pristine ?? this.pristine,
      broken: broken ?? this.broken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tether_id': tether_id,
      'mooring_id': mooring_id,
      'hawser_id': hawser_id,
      'bollard_id': bollard_id,
      'first_tie': first_tie,
      'last_tie': last_tie,
      'first_untie': first_untie,
      'last_untie': last_untie,
      'bow_distance': bow_distance,
      'stern_distance': stern_distance,
      'pristine': pristine,
      'broken': broken,
    };
  }

  factory Tether.fromMap(Map<String, dynamic> map) {
    return Tether(
      tether_id: map['tether_id']?.toInt() ?? 0,
      mooring_id: map['mooring_id']?.toInt() ?? 0,
      hawser_id: map['hawser_id']?.toInt() ?? 0,
      bollard_id: map['bollard_id']?.toInt() ?? 0,
      first_tie: map['first_tie'],
      last_tie: map['last_tie'],
      first_untie: map['first_untie'],
      last_untie: map['last_untie'],
      bow_distance: map['bow_distance'],
      stern_distance: map['stern_distance'],
      pristine: map['pristine'],
      broken: map['broken'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tether.fromJson(String source) => Tether.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Tether(tether_id: $tether_id, mooring_id: $mooring_id, hawser_id: $hawser_id, bollard_id: $bollard_id, first_tie: $first_tie, last_tie: $last_tie, first_untie: $first_untie, last_untie: $last_untie, bow_distance: $bow_distance, stern_distance: $stern_distance, pristine: $pristine, broken: $broken)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tether &&
        other.tether_id == tether_id &&
        other.mooring_id == mooring_id &&
        other.hawser_id == hawser_id &&
        other.bollard_id == bollard_id &&
        other.first_tie == first_tie &&
        other.last_tie == last_tie &&
        other.first_untie == first_untie &&
        other.last_untie == last_untie &&
        other.bow_distance == bow_distance &&
        other.stern_distance == stern_distance &&
        other.pristine == pristine &&
        other.broken == broken;
  }

  @override
  int get hashCode {
    return tether_id.hashCode ^
        mooring_id.hashCode ^
        hawser_id.hashCode ^
        bollard_id.hashCode ^
        first_tie.hashCode ^
        last_tie.hashCode ^
        first_untie.hashCode ^
        last_untie.hashCode ^
        bow_distance.hashCode ^
        stern_distance.hashCode ^
        pristine.hashCode ^
        broken.hashCode;
  }
}

class Mooring {
  int mooring_id;
  String tstamp;
  List<Tether> tethers;
  int stage_id;
  String? tie_started_at;
  String? tie_finished_at;
  String? untie_started_at;
  String? untie_finished_at;

  Mooring({
    required this.mooring_id,
    required this.tstamp,
    required this.tethers,
    required this.stage_id,
    this.tie_started_at,
    this.tie_finished_at,
    this.untie_started_at,
    this.untie_finished_at,
  });

  Mooring copyWith({
    int? mooring_id,
    String? tstamp,
    List<Tether>? tethers,
    int? stage_id,
    String? tie_started_at,
    String? tie_finished_at,
    String? untie_started_at,
    String? untie_finished_at,
  }) {
    return Mooring(
      mooring_id: mooring_id ?? this.mooring_id,
      tstamp: tstamp ?? this.tstamp,
      tethers: tethers ?? this.tethers,
      stage_id: stage_id ?? this.stage_id,
      tie_started_at: tie_started_at ?? this.tie_started_at,
      tie_finished_at: tie_finished_at ?? this.tie_finished_at,
      untie_started_at: untie_started_at ?? this.untie_started_at,
      untie_finished_at: untie_finished_at ?? this.untie_finished_at,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mooring_id': mooring_id,
      'tstamp': tstamp,
      'tethers': tethers.map((x) => x.toMap()).toList(),
      'stage_id': stage_id,
      'tie_started_at': tie_started_at,
      'tie_finished_at': tie_finished_at,
      'untie_started_at': untie_started_at,
      'untie_finished_at': untie_finished_at,
    };
  }

  factory Mooring.fromMap(Map<String, dynamic> map) {
    return Mooring(
      mooring_id: map['mooring_id']?.toInt() ?? 0,
      tstamp: map['tstamp'] ?? '',
      tethers: List<Tether>.from(map['tethers']?.map((x) => Tether.fromMap(x)) ?? []),
      stage_id: map['stage_id']?.toInt() ?? 0,
      tie_started_at: map['tie_started_at'],
      tie_finished_at: map['tie_finished_at'],
      untie_started_at: map['untie_started_at'],
      untie_finished_at: map['untie_finished_at'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Mooring.fromJson(String source) => Mooring.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Mooring(mooring_id: $mooring_id, tstamp: $tstamp, tethers: $tethers, stage_id: $stage_id, tie_started_at: $tie_started_at, tie_finished_at: $tie_finished_at, untie_started_at: $untie_started_at, untie_finished_at: $untie_finished_at)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Mooring &&
        other.mooring_id == mooring_id &&
        other.tstamp == tstamp &&
        listEquals(other.tethers, tethers) &&
        other.stage_id == stage_id &&
        other.tie_started_at == tie_started_at &&
        other.tie_finished_at == tie_finished_at &&
        other.untie_started_at == untie_started_at &&
        other.untie_finished_at == untie_finished_at;
  }

  @override
  int get hashCode {
    return mooring_id.hashCode ^
        tstamp.hashCode ^
        tethers.hashCode ^
        stage_id.hashCode ^
        tie_started_at.hashCode ^
        tie_finished_at.hashCode ^
        untie_started_at.hashCode ^
        untie_finished_at.hashCode;
  }
}

class Stage {
  int stage_id;
  String tstamp;
  int voyage_id;
  int stagetype_id;
  int sequential;
  int? fence_id;
  DateTime? ats;
  DateTime? atf;
  bool cancelled;
  List<Drafting>? draftings;
  List<Mooring>? moorings;

  Stage({
    required this.stage_id,
    required this.tstamp,
    required this.voyage_id,
    required this.stagetype_id,
    required this.sequential,
    this.fence_id,
    this.ats,
    this.atf,
    required this.cancelled,
    this.draftings,
    this.moorings,
  });

  Stage copyWith({
    int? stage_id,
    String? tstamp,
    int? voyage_id,
    int? stagetype_id,
    int? sequential,
    int? fence_id,
    DateTime? ats,
    DateTime? atf,
    bool? cancelled,
    List<Drafting>? draftings,
    List<Mooring>? moorings,
  }) {
    return Stage(
      stage_id: stage_id ?? this.stage_id,
      tstamp: tstamp ?? this.tstamp,
      voyage_id: voyage_id ?? this.voyage_id,
      stagetype_id: stagetype_id ?? this.stagetype_id,
      sequential: sequential ?? this.sequential,
      fence_id: fence_id ?? this.fence_id,
      ats: ats ?? this.ats,
      atf: atf ?? this.atf,
      cancelled: cancelled ?? this.cancelled,
      draftings: draftings ?? this.draftings,
      moorings: moorings ?? this.moorings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stage_id': stage_id,
      'tstamp': tstamp,
      'voyage_id': voyage_id,
      'stagetype_id': stagetype_id,
      'sequential': sequential,
      'fence_id': fence_id,
      'ats': ats?.millisecondsSinceEpoch,
      'atf': atf?.millisecondsSinceEpoch,
      'cancelled': cancelled,
      'draftings': draftings?.map((x) => x.toMap()).toList(),
      'moorings': moorings?.map((x) => x.toMap()).toList(),
    };
  }

  factory Stage.fromMap(Map<String, dynamic> map) {
    return Stage(
      stage_id: map['stage_id']?.toInt() ?? 0,
      tstamp: map['tstamp'] ?? '',
      voyage_id: map['voyage_id']?.toInt() ?? 0,
      stagetype_id: map['stagetype_id']?.toInt() ?? 0,
      sequential: map['sequential']?.toInt() ?? 0,
      fence_id: map['fence_id']?.toInt(),
      ats: map['ats'] != null ? DateTime.parse(map['ats']) : null,
      atf: map['atf'] != null ? DateTime.parse(map['atf']) : null,
      cancelled: map['cancelled'] ?? false,
      draftings:
          map['draftings'] != null ? List<Drafting>.from(map['draftings']?.map((x) => Drafting.fromMap(x))) : null,
      moorings: map['moorings'] != null ? List<Mooring>.from(map['moorings']?.map((x) => Mooring.fromMap(x))) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Stage.fromJson(String source) => Stage.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Stage(stage_id: $stage_id, tstamp: $tstamp, voyage_id: $voyage_id, stagetype_id: $stagetype_id, sequential: $sequential, fence_id: $fence_id, ats: $ats, atf: $atf, cancelled: $cancelled, draftings: $draftings, moorings: $moorings)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Stage &&
        other.stage_id == stage_id &&
        other.tstamp == tstamp &&
        other.voyage_id == voyage_id &&
        other.stagetype_id == stagetype_id &&
        other.sequential == sequential &&
        other.fence_id == fence_id &&
        other.ats == ats &&
        other.atf == atf &&
        other.cancelled == cancelled &&
        listEquals(other.draftings, draftings) &&
        listEquals(other.moorings, moorings);
  }

  @override
  int get hashCode {
    return stage_id.hashCode ^
        tstamp.hashCode ^
        voyage_id.hashCode ^
        stagetype_id.hashCode ^
        sequential.hashCode ^
        fence_id.hashCode ^
        ats.hashCode ^
        atf.hashCode ^
        cancelled.hashCode ^
        draftings.hashCode ^
        moorings.hashCode;
  }
}

class Voyage {
  int voyage_id;
  String tstamp;
  String? voyage_desc;
  int imo;
  int duv;
  String last_call;
  String eta;
  String? next_call;
  DateTime? etd;
  DateTime? min_ts;
  InfinityDateTime? max_tf;
  List<Stage> stages;
  int? mmsi;
  String? vessel_name;
  int? course_id;
  bool? done;
  bool? curr;
  Org? agency;
  bool? hasOpenMoorings; //internal use only

  Voyage({
    required this.voyage_id,
    required this.tstamp,
    this.voyage_desc,
    required this.imo,
    required this.duv,
    required this.last_call,
    required this.eta,
    this.next_call,
    this.etd,
    this.min_ts,
    this.max_tf,
    required this.stages,
    this.mmsi,
    this.vessel_name,
    this.course_id,
    this.done,
    this.curr,
    this.agency,
    this.hasOpenMoorings,
  });

  Voyage copyWith({
    int? voyage_id,
    String? tstamp,
    String? voyage_desc,
    int? imo,
    int? duv,
    String? last_call,
    String? eta,
    String? next_call,
    DateTime? etd,
    DateTime? min_ts,
    InfinityDateTime? max_tf,
    List<Stage>? stages,
    int? mmsi,
    String? vessel_name,
    int? course_id,
    bool? done,
    bool? curr,
    Org? agency,
    bool? hasOpenMoorings,
  }) {
    return Voyage(
      voyage_id: voyage_id ?? this.voyage_id,
      tstamp: tstamp ?? this.tstamp,
      voyage_desc: voyage_desc ?? this.voyage_desc,
      imo: imo ?? this.imo,
      duv: duv ?? this.duv,
      last_call: last_call ?? this.last_call,
      eta: eta ?? this.eta,
      next_call: next_call ?? this.next_call,
      etd: etd ?? this.etd,
      min_ts: min_ts ?? this.min_ts,
      max_tf: max_tf ?? this.max_tf,
      stages: stages ?? this.stages,
      mmsi: mmsi ?? this.mmsi,
      vessel_name: vessel_name ?? this.vessel_name,
      course_id: course_id ?? this.course_id,
      done: done ?? this.done,
      curr: curr ?? this.curr,
      agency: agency ?? this.agency,
      hasOpenMoorings: hasOpenMoorings ?? this.hasOpenMoorings,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'voyage_id': voyage_id,
      'tstamp': tstamp,
      'voyage_desc': voyage_desc,
      'imo': imo,
      'duv': duv,
      'last_call': last_call,
      'eta': eta,
      'next_call': next_call,
      'etd': etd?.toIso8601String(),
      'min_ts': min_ts?.toIso8601String(),
      'max_tf': max_tf?.getParse(),
      'stages': stages.map((x) => x.toMap()).toList(),
      'mmsi': mmsi,
      'vessel_name': vessel_name,
      'course_id': course_id,
      'done': done,
      'curr': curr,
      'agency': agency?.toMap(),
    };
  }

  factory Voyage.fromMap(Map<String, dynamic> map) {
    return Voyage(
      voyage_id: map['voyage_id'] as int,
      tstamp: map['tstamp'] as String,
      voyage_desc: map['voyage_desc'] != null ? map['voyage_desc'] as String : null,
      imo: map['imo'] as int,
      duv: map['duv'] as int,
      last_call: map['last_call'] as String,
      eta: map['eta'] as String,
      next_call: map['next_call'] != null ? map['next_call'] as String : null,
      etd: map['etd'] != null ? DateTime.parse(map['etd']) : null,
      min_ts: map['min_ts'] != null ? DateTime.parse(map['min_ts']) : null,
      max_tf: map['max_tf'] != null ? InfinityDateTime(map['max_tf']) : null,
      stages: List<Stage>.from(
        (map['stages'] as List).map<Stage>(
          (x) => Stage.fromMap(x as Map<String, dynamic>),
        ),
      ),
      mmsi: map['mmsi'] != null ? map['mmsi'] as int : null,
      vessel_name: map['vessel_name'] != null ? map['vessel_name'] as String : null,
      course_id: map['course_id'] != null ? map['course_id'] as int : null,
      done: map['done'] != null ? map['done'] as bool : null,
      curr: map['curr'] != null ? map['curr'] as bool : null,
      agency: map['agency'] != null ? Org.fromMap(map['agency'] as Map<String, dynamic>) : null,
      hasOpenMoorings: map['hasOpenMoorings'] != null ? map['hasOpenMoorings'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Voyage.fromJson(String source) => Voyage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Voyage(voyage_id: $voyage_id, tstamp: $tstamp, voyage_desc: $voyage_desc, imo: $imo, duv: $duv, last_call: $last_call, eta: $eta, next_call: $next_call, etd: $etd, min_ts: $min_ts, max_tf: $max_tf, stages: $stages, mmsi: $mmsi, vessel_name: $vessel_name, course_id: $course_id, done: $done, curr: $curr, agency: $agency, hasOpenMoorings: $hasOpenMoorings)';
  }

  @override
  bool operator ==(covariant Voyage other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.voyage_id == voyage_id &&
        other.tstamp == tstamp &&
        other.voyage_desc == voyage_desc &&
        other.imo == imo &&
        other.duv == duv &&
        other.last_call == last_call &&
        other.eta == eta &&
        other.next_call == next_call &&
        other.etd == etd &&
        other.min_ts == min_ts &&
        other.max_tf == max_tf &&
        listEquals(other.stages, stages) &&
        other.mmsi == mmsi &&
        other.vessel_name == vessel_name &&
        other.course_id == course_id &&
        other.done == done &&
        other.curr == curr &&
        other.agency == agency &&
        other.hasOpenMoorings == hasOpenMoorings;
  }

  @override
  int get hashCode {
    return voyage_id.hashCode ^
        tstamp.hashCode ^
        voyage_desc.hashCode ^
        imo.hashCode ^
        duv.hashCode ^
        last_call.hashCode ^
        eta.hashCode ^
        next_call.hashCode ^
        etd.hashCode ^
        min_ts.hashCode ^
        max_tf.hashCode ^
        stages.hashCode ^
        mmsi.hashCode ^
        vessel_name.hashCode ^
        course_id.hashCode ^
        done.hashCode ^
        curr.hashCode ^
        agency.hashCode ^
        hasOpenMoorings.hashCode;
  }
}

class Bollard {
  int bollard_id;
  String bollard_name;

  Bollard({
    required this.bollard_id,
    required this.bollard_name,
  });

  Bollard copyWith({
    int? bollard_id,
    String? bollard_name,
  }) {
    return Bollard(
      bollard_id: bollard_id ?? this.bollard_id,
      bollard_name: bollard_name ?? this.bollard_name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bollard_id': bollard_id,
      'bollard_name': bollard_name,
    };
  }

  factory Bollard.fromMap(Map<String, dynamic> map) {
    return Bollard(
      bollard_id: map['bollard_id']?.toInt() ?? 0,
      bollard_name: map['bollard_name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Bollard.fromJson(String source) => Bollard.fromMap(json.decode(source));

  @override
  String toString() => 'Bollard(bollard_id: $bollard_id, bollard_name: $bollard_name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Bollard && other.bollard_id == bollard_id && other.bollard_name == bollard_name;
  }

  @override
  int get hashCode => bollard_id.hashCode ^ bollard_name.hashCode;
}

class Berth {
  int berth_id;
  String berth_name;
  String berth_desc;
  String berth_code;
  String berth_pier;
  String port_code;
  int fence_id;
  List<Bollard> bollards;

  Berth({
    required this.berth_id,
    required this.berth_name,
    required this.berth_desc,
    required this.berth_code,
    required this.berth_pier,
    required this.port_code,
    required this.fence_id,
    required this.bollards,
  });

  Berth copyWith({
    int? berth_id,
    String? berth_name,
    String? berth_desc,
    String? berth_code,
    String? berth_pier,
    String? port_code,
    int? fence_id,
    List<Bollard>? bollards,
  }) {
    return Berth(
      berth_id: berth_id ?? this.berth_id,
      berth_name: berth_name ?? this.berth_name,
      berth_desc: berth_desc ?? this.berth_desc,
      berth_code: berth_code ?? this.berth_code,
      berth_pier: berth_pier ?? this.berth_pier,
      port_code: port_code ?? this.port_code,
      fence_id: fence_id ?? this.fence_id,
      bollards: bollards ?? this.bollards,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'berth_id': berth_id,
      'berth_name': berth_name,
      'berth_desc': berth_desc,
      'berth_code': berth_code,
      'berth_pier': berth_pier,
      'port_code': port_code,
      'fence_id': fence_id,
      'bollards': bollards.map((x) => x.toMap()).toList(),
    };
  }

  factory Berth.fromMap(Map<String, dynamic> map) {
    return Berth(
      berth_id: map['berth_id']?.toInt() ?? 0,
      berth_name: map['berth_name'] ?? '',
      berth_desc: map['berth_desc'] ?? '',
      berth_code: map['berth_code'] ?? '',
      berth_pier: map['berth_pier'] ?? '',
      port_code: map['port_code'] ?? '',
      fence_id: map['fence_id']?.toInt() ?? 0,
      bollards: List<Bollard>.from(map['bollards']?.map((x) => Bollard.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Berth.fromJson(String source) => Berth.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Berth(berth_id: $berth_id, berth_name: $berth_name, berth_desc: $berth_desc, berth_code: $berth_code, berth_pier: $berth_pier, port_code: $port_code, fence_id: $fence_id, bollards: $bollards)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is Berth &&
        other.berth_id == berth_id &&
        other.berth_name == berth_name &&
        other.berth_desc == berth_desc &&
        other.berth_code == berth_code &&
        other.berth_pier == berth_pier &&
        other.port_code == port_code &&
        other.fence_id == fence_id &&
        listEquals(other.bollards, bollards);
  }

  @override
  int get hashCode {
    return berth_id.hashCode ^
        berth_name.hashCode ^
        berth_desc.hashCode ^
        berth_code.hashCode ^
        berth_pier.hashCode ^
        port_code.hashCode ^
        fence_id.hashCode ^
        bollards.hashCode;
  }
}
