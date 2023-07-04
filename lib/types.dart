// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

import 'interfaces.dart';

class Berth {
  int voyageId;
  int stageId;
  int mmsi;
  String vesselName;
  int berthId;
  String berthName;
  String portCode;
  String boardsideAbbr;
  String boardsideDesc;
  int boardsideId;

  Berth(
      {required this.voyageId,
      required this.stageId,
      required this.mmsi,
      required this.vesselName,
      required this.berthId,
      required this.berthName,
      required this.portCode,
      required this.boardsideAbbr,
      required this.boardsideDesc,
      required this.boardsideId});

  factory Berth.fromJson(Map<String, dynamic> json) {
    return Berth(
      voyageId: json['voyage_id'],
      stageId: json['stage_id'],
      mmsi: json['mmsi'],
      vesselName: json['vessel_name'],
      berthId: json['berth_id'],
      berthName: json['berth_name'],
      boardsideAbbr: json['boardside_abbr'],
      boardsideDesc: json['boardside_desc'],
      boardsideId: json['boardside_id'],
      portCode: json['port_code'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['voyage_id'] = voyageId;
    data['mmsi'] = mmsi;
    data['vessel_name'] = vesselName;
    data['berth_id'] = berthId;
    data['berth_name'] = berthName;
    data['port_code'] = portCode;
    data['boardside_abbr'] = boardsideAbbr;
    data['boardside_desc'] = boardsideDesc;
    data['boardside_id'] = boardsideId;
    return data;
  }
}

class VoyageBehaviorSubject {
  static final VoyageBehaviorSubject _singleton =
      VoyageBehaviorSubject._internal();
  final BehaviorSubject<dynamic> _voyageController = BehaviorSubject<dynamic>();

  factory VoyageBehaviorSubject() {
    return _singleton;
  }

  Stream<dynamic> getStream() {
    return _voyageController.stream;
  }

  void setValue(dynamic value) {
    _voyageController.add(value);
  }

  Future<void> refresh(int voyageId) async {
    var value = await VoyagesInterface.getVoyage(voyageId);
    _voyageController.add(value);
    return;
  }

  VoyageBehaviorSubject._internal();
}

// enum Boardside {
//   BE = 1;
//   BB = 2;
//   CB = 3;
//   CBB = 4;
// }

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
  num estimate_id;
  num voyage_id;
  num stage_id;
  String tstamp;
  num? fence_id;
  DateTime ets;
  DateTime etf;
  bool official;
  bool confirmed;
  num sequential;

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
    num? estimate_id,
    num? voyage_id,
    num? stage_id,
    String? tstamp,
    num? fence_id,
    DateTime? ets,
    DateTime? etf,
    bool? official,
    bool? confirmed,
    num? sequential,
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
      estimate_id: map['estimate_id'] as num,
      voyage_id: map['voyage_id'] as num,
      stage_id: map['stage_id'] as num,
      tstamp: map['tstamp'] as String,
      fence_id: map['fence_id'] != null ? map['fence_id'] as num : null,
      ets: DateTime.parse(map['ets']),
      etf: DateTime.parse(map['etf']),
      official: map['official'] as bool,
      confirmed: map['confirmed'] as bool,
      sequential: map['sequential'] as num,
    );
  }

  String toJson() => json.encode(toMap());

  factory Estimate.fromJson(String source) =>
      Estimate.fromMap(json.decode(source) as Map<String, dynamic>);

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
  num org_id;
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
    num? org_id,
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
      org_id: map['org_id'] as num,
      id: map['id'] as String,
      id_type: map['id_type'] as String,
      name: map['name'] as String,
      desc: map['desc'] != null ? map['desc'] as String : null,
      picture: map['picture'] != null ? map['picture'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Org.fromJson(String source) =>
      Org.fromMap(json.decode(source) as Map<String, dynamic>);

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
    return org_id.hashCode ^
        id.hashCode ^
        id_type.hashCode ^
        name.hashCode ^
        desc.hashCode ^
        picture.hashCode;
  }
}

class Stage {
  num stage_id;
  String tstamp;
  num voyage_id;
  num stagetype_id;
  num sequential;
  num? fence_id;
  DateTime? ats;
  InfinityDateTime? atf;
  bool cancelled;
  DateTime? minEts;
  DateTime? maxEtf;
  List<Estimate> estimates;

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
    this.minEts,
    this.maxEtf,
    required this.estimates,
  });

  Stage copyWith({
    num? stage_id,
    String? tstamp,
    num? voyage_id,
    num? stagetype_id,
    num? sequential,
    num? fence_id,
    DateTime? ats,
    InfinityDateTime? atf,
    bool? cancelled,
    DateTime? minEts,
    DateTime? maxEtf,
    List<Estimate>? estimates,
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
      minEts: minEts ?? this.minEts,
      maxEtf: maxEtf ?? this.maxEtf,
      estimates: estimates ?? this.estimates,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'stage_id': stage_id,
      'tstamp': tstamp,
      'voyage_id': voyage_id,
      'stagetype_id': stagetype_id,
      'sequential': sequential,
      'fence_id': fence_id,
      'ats': ats?.toIso8601String(),
      'atf': atf?.getParse(),
      'cancelled': cancelled,
      'minEts': minEts?.toIso8601String(),
      'maxEtf': maxEtf?.toIso8601String(),
      'estimates': estimates.map((x) => x.toMap()).toList(),
    };
  }

  factory Stage.fromMap(Map<String, dynamic> map) {
    return Stage(
      stage_id: map['stage_id'] as num,
      tstamp: map['tstamp'] as String,
      voyage_id: map['voyage_id'] as num,
      stagetype_id: map['stagetype_id'] as num,
      sequential: map['sequential'] as num,
      fence_id: map['fence_id'] != null ? map['fence_id'] as num : null,
      ats: map['ats'] != null ? DateTime.parse(map['ats']) : null,
      atf: map['atf'] != null ? InfinityDateTime(map['atf']) : null,
      cancelled: map['cancelled'] as bool,
      minEts: map['minEts'] != null ? DateTime.parse(map['minEts']) : null,
      maxEtf: map['maxEtf'] != null ? DateTime.parse(map['maxEtf']) : null,
      estimates: List<Estimate>.from(
        (map['estimates'] as List).map<Estimate>(
          (x) => Estimate.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Stage.fromJson(String source) =>
      Stage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Stage(stage_id: $stage_id, tstamp: $tstamp, voyage_id: $voyage_id, stagetype_id: $stagetype_id, sequential: $sequential, fence_id: $fence_id, ats: $ats, atf: $atf, cancelled: $cancelled, minEts: $minEts, maxEtf: $maxEtf, estimates: $estimates)';
  }

  @override
  bool operator ==(covariant Stage other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.stage_id == stage_id &&
        other.tstamp == tstamp &&
        other.voyage_id == voyage_id &&
        other.stagetype_id == stagetype_id &&
        other.sequential == sequential &&
        other.fence_id == fence_id &&
        other.ats == ats &&
        other.atf == atf &&
        other.cancelled == cancelled &&
        other.minEts == minEts &&
        other.maxEtf == maxEtf &&
        listEquals(other.estimates, estimates);
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
        minEts.hashCode ^
        maxEtf.hashCode ^
        estimates.hashCode;
  }
}

class Voyage {
  num voyage_id;
  String tstamp;
  String? voyage_desc;
  num imo;
  num duv;
  String last_call;
  String eta;
  String? next_call;
  DateTime? etd;
  DateTime? min_ts;
  InfinityDateTime? max_tf;
  List<Stage> stages;
  num? mmsi;
  String? vessel_name;
  num? course_id;
  bool? done;
  bool? curr;
  Org? agency;

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
  });

  Voyage copyWith({
    num? voyage_id,
    String? tstamp,
    String? voyage_desc,
    num? imo,
    num? duv,
    String? last_call,
    String? eta,
    String? next_call,
    DateTime? etd,
    DateTime? min_ts,
    InfinityDateTime? max_tf,
    List<Stage>? stages,
    num? mmsi,
    String? vessel_name,
    num? course_id,
    bool? done,
    bool? curr,
    Org? agency,
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
      voyage_id: map['voyage_id'] as num,
      tstamp: map['tstamp'] as String,
      voyage_desc:
          map['voyage_desc'] != null ? map['voyage_desc'] as String : null,
      imo: map['imo'] as num,
      duv: map['duv'] as num,
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
      mmsi: map['mmsi'] != null ? map['mmsi'] as num : null,
      vessel_name:
          map['vessel_name'] != null ? map['vessel_name'] as String : null,
      course_id: map['course_id'] != null ? map['course_id'] as num : null,
      done: map['done'] != null ? map['done'] as bool : null,
      curr: map['curr'] != null ? map['curr'] as bool : null,
      agency: map['agency'] != null
          ? Org.fromMap(map['agency'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Voyage.fromJson(String source) =>
      Voyage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Voyage(voyage_id: $voyage_id, tstamp: $tstamp, voyage_desc: $voyage_desc, imo: $imo, duv: $duv, last_call: $last_call, eta: $eta, next_call: $next_call, etd: $etd, min_ts: $min_ts, max_tf: $max_tf, stages: $stages, mmsi: $mmsi, vessel_name: $vessel_name, course_id: $course_id, done: $done, curr: $curr, agency: $agency)';
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
        other.agency == agency;
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
        agency.hashCode;
  }
}
