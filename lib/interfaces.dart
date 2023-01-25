import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:neptune/types.dart';

const String baseURL = "https://api.navalport.com";
const String _portCode = "BRSSZ";

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

  static Future<dynamic> _makeRequest(String method, String route,
      [String? body]) async {
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
      http.StreamedResponse response =
          await request.send(); //.timeout(const Duration(seconds: 5));
      String data = await response.stream.bytesToString();
      // return Future.error("falha de teste");
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

    var lineup = await RequestInterface._makeRequest(
        "GET", "/smart/ports/$_portCode/lineup");
    // var shortlinup = (lineup as List).length > 5 ? lineup.sublist(0, 5) : lineup;
    return lineup
        .map((e) => ({
              'docking_id': e['docking_id'],
              'eta': e['eta'],
              'mmsi': e['mmsi'],
              'vessel_name': e['vessel_name'],
              'berth_id': e['berth_id'],
              'berth_name': e['berth_name'],
              'boardside_abbr': e['boardside_abbr'],
              'boardside_desc': e['boardside_desc'],
              'boardside_id': e['boardside_id'],
              'port_code': e['port_code']
            }))
        .toList();
  }
}

class DockingInterface with RequestInterface {
  static Future<dynamic> getDocking(int dockingId) async {
    return RequestInterface._makeRequest("GET", "/docking/$dockingId");
  }

  static Future<dynamic> patchDocking(
      int dockingId, Map<String, dynamic> data) async {
    return RequestInterface._makeRequest(
        "PATCH", "/docking/$dockingId", jsonEncode(data));
  }

  static Future<dynamic> postDrafting(
      int dockingId, Map<String, dynamic> data) async {
    return RequestInterface._makeRequest(
        "POST", "/docking/$dockingId/drafting", jsonEncode(data));
  }

  static Future<dynamic> deleteDrafting(int dockingId, int draftingId) async {
    return RequestInterface._makeRequest(
        "DELETE", "/docking/$dockingId/drafting/$draftingId");
  }

  static Future<dynamic> postMooring(
      int dockingId, Map<String, dynamic> data) async {
    return RequestInterface._makeRequest(
        "POST", "/docking/$dockingId/mooring", jsonEncode(data));
  }

  static Future<dynamic> patchMooring(
      int dockingId, int mooringId, Map<String, dynamic> data) async {
    return RequestInterface._makeRequest(
        "PATCH", "/docking/$dockingId/mooring/$mooringId", jsonEncode(data));
  }

  static Future<dynamic> deleteMooring(int dockingId, int mooringId) async {
    return RequestInterface._makeRequest(
        "DELETE", "/docking/$dockingId/mooring/$mooringId");
  }
}

class HawsersInterface with RequestInterface {
  static Future<dynamic> getHawsers() async {
    return RequestInterface._makeRequest("GET", "/model/hawsers");
  }
}

class BollardsInterface with RequestInterface {
  static Future<dynamic> getBollards(int berthId) async {
    return RequestInterface._makeRequest(
        "GET", "/smart/ports/$_portCode/bollards/$berthId");
  }
}

class AuthInterface {
  // static dynamic userData;

  static Future<dynamic> signInWithWebUI() async {
    await logOut();
    try {
      SignInResult res = await Amplify.Auth.signInWithWebUI();
      if (await isSignedIn()) {
        // userData = await getUserInfo();
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
