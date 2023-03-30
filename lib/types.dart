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
  static final VoyageBehaviorSubject _singleton = VoyageBehaviorSubject._internal();
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