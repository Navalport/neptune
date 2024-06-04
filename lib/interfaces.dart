import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mooringapp/extensions.dart';
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

mixin class RequestInterface {
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
      try {
        return json.decode(data);
      } catch (e) {
        return null;
      }
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

class VoyageInterface with RequestInterface {
  static Future<List<Voyage>> getVoyages() async {
    var lineup = await RequestInterface._makeRequest("GET", "/voyages/lineup/$_portCode");
    var openMoorings = (await RequestInterface._makeRequest("GET", "/voyages/open-moorings/$_portCode") as List)
        .map((e) => e["voyage_id"]);

    return (lineup as List)
        .map((dynamic v) => Voyage.fromMap({...v, "hasOpenMoorings": openMoorings.contains(v["voyage_id"])}))
        .toList();
  }

  static Future<dynamic> getVoyage(int voyageId) async {
    return RequestInterface._makeRequest("GET", "/voyages/details/$voyageId");
  }

  static Future<Stage> getStage(int stageId) async {
    var stage = await RequestInterface._makeRequest("GET", "/voyages/stages/$stageId");
    return Stage.fromMap(stage);
  }

  static Future<dynamic> postStage(Map<String, dynamic> data) async {
    return RequestInterface._makeRequest("POST", "/voyages/stages", jsonEncode(data));
  }

  static Future<dynamic> patchStage(int stageId, Map<String, dynamic> data) async {
    return RequestInterface._makeRequest("PATCH", "/voyages/stages/$stageId", jsonEncode(data));
  }

  static Future<Stage> getVoyagesWithOpenMoorings() async {
    var stage = await RequestInterface._makeRequest("GET", "/voyages/stages/$_portCode");
    return Stage.fromMap(stage);
  }
}

class BerthInterface with RequestInterface {
  static List<Berth>? _berths;

  static Future<List<Berth>> getBerths([bool forceReload = false]) async {
    return (_berths == null || forceReload)
        ? Future.value(_berths = ((await RequestInterface._makeRequest("GET", "/ports/BRSSZ/berths")) as List)
            .map((dynamic v) => Berth.fromMap(v))
            .toList())
        : Future.value(_berths);
  }

  // static Future<Berth> getBerthByFenceId(int fenceId) async {
  //   var berths = await RequestInterface._makeRequest("GET", "/ports/BRSSZ/berths");
  //   return (berths as List).map<Berth>((dynamic v) => Berth.fromMap(v)).firstWhere((e) => e.fence_id == fenceId);
  // }
}

class DockingsInterface with RequestInterface {
  static Future<dynamic> postDrafting(Map<String, dynamic> data) async {
    return RequestInterface._makeRequest("POST", "/voyages/draftings", jsonEncode(data));
  }

  static Future<dynamic> deleteDrafting(int draftingId) async {
    return RequestInterface._makeRequest("DELETE", "/voyages/draftings/$draftingId");
  }

  static Future<Mooring> postMooring(Map<String, dynamic> data) async {
    var mooring = await RequestInterface._makeRequest("POST", "/voyages/moorings", jsonEncode(data));
    return Mooring.fromMap(mooring);
  }

  // static Future<dynamic> postMooring(int stageId, Map<String, dynamic> data) async {
  //   final mooring = await RequestInterface._makeRequest(
  //       "POST",
  //       "/voyages/moorings",
  //       jsonEncode({
  //         "stage_id": stageId,
  //         "tethers": [data]
  //       }));
  //   return mooring;
  // }

  static Future<dynamic> patchMooring(int mooringId, Map<String, dynamic> data) async {
    return RequestInterface._makeRequest("PATCH", "/voyages/moorings/$mooringId", jsonEncode(data));
  }

  static Future<dynamic> deleteMooring(int mooringId) async {
    return RequestInterface._makeRequest("DELETE", "/voyages/moorings/$mooringId");
  }

  static Future<dynamic> postTether(Map<String, dynamic> data) async {
    return RequestInterface._makeRequest("POST", "/voyages/tethers", jsonEncode(data));
  }

  static Future<dynamic> patchTether(int tetherId, Map<String, dynamic> data) async {
    final tether = await RequestInterface._makeRequest(
      "PATCH",
      "/voyages/tethers/$tetherId",
      jsonEncode(data..omit(["tether_id", "mooring_id", "hawser_id", "bollard_id"])),
    );
    return tether;
  }

  static Future<dynamic> deleteTether(int tetherId) async {
    return RequestInterface._makeRequest("DELETE", "/voyages/tethers/$tetherId");
  }

  static Future<dynamic> bindTether(
      int mooringId, int tetherId, Map<String, dynamic> mooringData, Map<String, dynamic> tetherData) async {
    await DockingsInterface.patchMooring(
      mooringId,
      mooringData.omit(["mooring_id", "tstamp", "tethers", "stage_id"]),
    );
    return DockingsInterface.patchTether(
      tetherId,
      tetherData.omit(["tether_id", "mooring_id", "hawser_id", "bollard_id"]),
    );
  }
}

class HawsersInterface with RequestInterface {
  static Future<List<Hawser>> getHawsers() async {
    var hawsers = await RequestInterface._makeRequest("GET", "/model/hawsers");
    return (hawsers as List).map((dynamic v) => Hawser.fromMap(v)).toList();
  }
}

class AuthInterface {
  // static dynamic userData;

  static Future<dynamic> signInWithWebUI() async {
    await logOut();
    try {
      // SignInResult res = await Amplify.Auth.signInWithWebUI();
      if (await isSignedIn()) {
        // var userData = await getUserInfo();
        return {"status": true};
      }
      return {"status": false};
    } catch (e) {
      return {"status": false, "message": e};
    }
  }

  static Future<dynamic> signIn(String username, String password) async {
    await logOut();
    try {
      await Amplify.Auth.signIn(username: username, password: password);
      if (await isSignedIn()) {
        // var userData = await getUserInfo();
        return {"status": true};
      }
      return {"status": false};
    } on NotAuthorizedException {
      return {"status": false, "message": "E-mail ou senha incorreto."};
    } catch (e) {
      return {"status": false, "message": e.toString()};
    }
  }

  static Future<void> logOut() async {
    try {
      if (await isSignedIn()) {
        await Amplify.Auth.signOut();
      }
    } catch (e) {
      // print(e);
    }
  }

  static Future<dynamic> getUserInfo() async {
    var result = await Amplify.Auth.fetchUserAttributes();
    // print(result);
    return result;
  }

  static Future<bool> isSignedIn() async {
    AuthSession session = await Amplify.Auth.fetchAuthSession();
    // userData = await getUserInfo();
    return session.isSignedIn;
  }
}
