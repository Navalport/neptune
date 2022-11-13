class Berth {
  int dockingId;
  DateTime eta;
  int mmsi;
  String vesselName;
  int berthId;
  String berthName;
  String portCode;
  String boardsideAbbr;
  String boardsideDesc;
  int boardsideId;

  Berth(
      {required this.dockingId,
      required this.eta,
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
      dockingId: json['docking_id'],
      eta: DateTime.parse(json['eta']),
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
    data['docking_id'] = dockingId;
    data['eta'] = eta;
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
