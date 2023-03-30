import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mooringapp/types.dart';

const String baseURL = "https://api.navalport.com";
const String _portCode = "BRSSZ";

// extension TryDecode on JsonCodec {
//   String? tryDecode(String source, {Object? Function(Object?, Object?)? reviver}) {
//     try {
//       return decode(source, reviver: reviver);
//     } catch (e) {
//       return null;
//     }
//   }
// }

class RequestInterface {
  // static Future<dynamic> _makeMultipartRequest(String method, String route,
  //     Map fields, List<http.MultipartFile> files) async {
  //   var headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': _authorization,
  //   };

  //   var request = http.MultipartRequest(
  //     method,
  //     Uri.parse(baseURL + route),
  //   );

  //   request.fields.addAll(fields);
  //   files.forEach((file) => request.files.add(file));
  //   request.headers.addAll(headers);

  //   try {
  //     http.StreamedResponse response =
  //         await request.send().timeout(Duration(seconds: 5));
  //     _authorization = response.headers["authorization"] ?? _authorization;
  //     // List<int> data = await response.stream.first;
  //     String data = await response.stream.bytesToString();
  //     return json.decode(data);
  //   } on TimeoutException catch (e) {
  //     print('Timeout Error: $e');
  //     return {
  //       "error": "timeout",
  //       "message": "Tempo esgotado. Verifique sua conexão e tente novamente.",
  //     };
  //   } on SocketException catch (e) {
  //     print('Socket Error: $e');
  //     return {
  //       "error": "socket error",
  //       "message": "Erro de Socket. Verifique sua conexão com a internet.",
  //     };
  //   } catch (e) {
  //     print('General Error: $e');
  //     return {
  //       "error": "error",
  //       "message": "Ocorreu um erro. Por favor, tente mais tarde.",
  //     };
  //   }
  // }

  static Future<dynamic> _makeRequest(String method, String route, [String? body]) async {
    var headers = {
      'Content-Type': 'application/json',
    };

    var request = http.Request(
      method,
      Uri.parse(baseURL + route),
    );
    request.body = body ?? "";
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send(); //.timeout(const Duration(seconds: 5));
      String data = await response.stream.bytesToString();
      // return Future.error("falha de teste");
      if (data == "") {
        data = "{}";
      }
      return json.decode(data);
    } catch (e) {
      return Future.error(e.toString());
    }
    // on TimeoutException catch (e) {
    //   print('Timeout Error: $e');
    //   return {
    //     "error": "timeout",
    //     "message": "Tempo esgotado. Verifique sua conexão e tente novamente.",
    //   };
    // } on SocketException catch (e) {
    //   print('Socket Error: $e');
    //   return {
    //     "error": "socket error",
    //     "message": "Erro de Socket. Verifique se outra aplicação não está interferindo na conexão.",
    //   };
    // } catch (e) {
    //   print('General Error: $e');
    //   return {
    //     "error": "error",
    //     "message": "Ocorreu um erro. Por favor, tente mais tarde.",
    //   };
    // }
  }
}

class BerthInterface with RequestInterface {
  static Future<dynamic> getBerths() async {
    // return RequestInterface._makeRequest("GET", "/smart/ports/$_portCode/berthed");
    DateTime now = DateTime.now();
    var lineup = await RequestInterface._makeRequest(
        "GET", "/voyage/lineup/$_portCode"); //?limit=100&ts=0&tf=${now.millisecondsSinceEpoch}
    var temp = (lineup as List)
        .map((voyage) {
          var stage = (voyage["stages"] as List?)?.where((s) => s["stagetype"] == 'berthed').firstWhere(
              (s) =>
                  (s["ats"] == null || now.compareTo(DateTime.parse(s["ats"])) >= 0) &&
                  (s["atf"] == null || now.compareTo(DateTime.parse(s["atf"])) <= 0),
              orElse: () => null);
          if (stage != null) {
            return {
              ...stage,
              "mmsi": voyage["mmsi"],
              "vessel_name": voyage["vessel_name"],
              "port_code": voyage["port_code"]
            };
          } else {
            return null;
          }
        })
        .where((e) => e != null && e["berthing"]["berth_id"] != null)
        .toList();

    return temp
        .map((e) => ({
              'voyage_id': e!['voyage_id'],
              'stage_id': e['stage_id'],
              'mmsi': e['mmsi'],
              'vessel_name': e['vessel_name'],
              'berth_id': e["berthing"]['berth_id'],
              'berth_name': e["berthing"]['berth_name'],
              'boardside_abbr': e["berthing"]['boardside_abbr'],
              'boardside_desc': e["berthing"]['boardside_desc'],
              'boardside_id': e["berthing"]['boardside_id'],
              'port_code': e['port_code']
            }))
        .toList();
  }
}

class VoyagesInterface with RequestInterface {
  static Future<dynamic> getVoyage(int voyageId) async {
    return RequestInterface._makeRequest("GET", "/smart-voyages/voyages/$voyageId");
  }

  static Future<dynamic> patchVoyage(int voyageId, Map<String, dynamic> data) async {
    return RequestInterface._makeRequest("PATCH", "/smart-voyages/voyages/$voyageId", jsonEncode(data));
  }
}

class DockingsInterface with RequestInterface {
  static Future<dynamic> postDrafting(Map<String, dynamic> data) async {
    return RequestInterface._makeRequest("POST", "/smart-voyages/draftings", jsonEncode(data));
  }

  static Future<dynamic> deleteDrafting(int draftingId) async {
    return RequestInterface._makeRequest("DELETE", "/smart-voyages/draftings/$draftingId");
  }

  // static Future<dynamic> postMooring(Map<String, dynamic> data) async {
  //   return RequestInterface._makeRequest("POST", "/voyage/moorings", jsonEncode(data));
  // }

  static Future<dynamic> postMooring(int stageId, Map<String, dynamic> data) async {
    final mooring = await RequestInterface._makeRequest(
        "POST",
        "/smart-voyages/moorings",
        jsonEncode({
          "stage_id": stageId,
          "tethers": [data]
        }));
    // final tether = await RequestInterface._makeRequest(
    //     "POST", "/smart-voyages/moorings/${mooring["mooring_id"]}/tethers", jsonEncode(data));
    return mooring;
  }

  static Future<dynamic> patchMooring(int mooringId, Map<String, dynamic> data) async {
    return RequestInterface._makeRequest("PATCH", "/smart-voyages/moorings/$mooringId", jsonEncode(data));
  }

  static Future<dynamic> deleteMooring(int mooringId) async {
    return RequestInterface._makeRequest("DELETE", "/voyage/moorings/$mooringId");
  }

  static Future<dynamic> postTether(int mooringId, Map<String, dynamic> data) async {
    return RequestInterface._makeRequest("POST", "/smart-voyages/moorings/$mooringId/tethers", jsonEncode(data));
  }

  static Future<dynamic> patchTether(int mooringId, int tetherId, Map<String, dynamic> data) async {
    final tether = await RequestInterface._makeRequest(
        "PATCH", "/smart-voyages/moorings/$mooringId/tethers/$tetherId", jsonEncode(data));
    return tether;
  }

  static Future<dynamic> deleteTether(int mooringId, int tetherId) async {
    return RequestInterface._makeRequest("DELETE", "/smart-voyages/moorings/$mooringId/tethers/$tetherId");
  }

  static Future<dynamic> bindTether(
      int mooringId, int tetherId, Map<String, dynamic> mooringData, Map<String, dynamic> tetherData) async {
    await DockingsInterface.patchMooring(mooringId, mooringData);
    return DockingsInterface.patchTether(mooringId, tetherId, tetherData);
  }
}

class HawsersInterface with RequestInterface {
  static Future<dynamic> getHawsers() async {
    return RequestInterface._makeRequest("GET", "/model/hawsers");
  }
}

class BollardsInterface with RequestInterface {
  static Future<dynamic> getBollards(int berthId) async {
    return RequestInterface._makeRequest("GET", "/smart/ports/$_portCode/bollards/$berthId");
  }
}

class AuthInterface {
  // static dynamic userData;

  static Future<dynamic> signInWithWebUI() async {
    await logOut();
    try {
      SignInResult res = await Amplify.Auth.signInWithWebUI();
      if (await isSignedIn()) {
        // var userData = await getUserInfo();
        return {"status": true};
      }
      return {"status": false};
    } catch (e) {
      return {"status": false, "message": e};
    }
  }

  static Future<void> logOut() async {
    try {
      if (await isSignedIn()) {
        await Amplify.Auth.signOut();
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> getUserInfo() async {
    var result = await Amplify.Auth.fetchUserAttributes();
    print(result);
    return result;
  }

  static Future<bool> isSignedIn() async {
    AuthSession session = await Amplify.Auth.fetchAuthSession();
    // userData = await getUserInfo();
    return session.isSignedIn;
  }
}
