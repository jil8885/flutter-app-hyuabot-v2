import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_app_hyuabot_v2/Config/Networking.dart' as conf;
import 'package:flutter_app_hyuabot_v2/Model/Bus.dart';


class BusDepartureController extends GetxController{
  var departureInfo = Map<String, dynamic>().obs;
  var isLoading = true.obs;

  @override
  void onInit(){
    queryDepartureInfo();
    super.onInit();
  }

  queryDepartureInfo() async {
    try{
      isLoading(true);
      var data = await fetchDepartureInfo();
      if(data != null){
        departureInfo.assignAll(data);
      }
    } finally {
      isLoading(false);
      refresh();
    }
    Timer.periodic(Duration(minutes: 1), (timer) async {
      try{
        isLoading(true);
        var data = await fetchDepartureInfo();
        if(data != null){
          departureInfo.assignAll(data);
        }
      } finally {
        isLoading(false);
        refresh();
      }
    });
  }

  Future<Map<String, dynamic>> fetchDepartureInfo() async{

    final url = Uri.encodeFull(conf.getAPIServer() + "/app/bus");
    http.Response response = await http.post(url, headers: {"Accept": "application/json"}, body: jsonEncode({"campus": "ERICA"}));
    Map<String, dynamic> responseJson = jsonDecode(utf8.decode(response.bodyBytes));

    Map<String, dynamic> data = {"10-1":{"realtime": List<BusInfoRealtime>(), "timetable": List<BusInfoTimetable>()}, "3102": {"realtime": List<BusInfoRealtime>(), "timetable": List<BusInfoTimetable>()}, "707-1": {"realtime": List<BusInfoRealtime>(), "timetable": List<BusInfoTimetable>()}};

    for(String key in (responseJson["realtime"] as Map<String, dynamic>).keys){
      List realtimeInfo = responseJson["realtime"][key];
      if(realtimeInfo.isNotEmpty) {
        data[key]["realtime"] =
            realtimeInfo.map((e) => BusInfoRealtime.fromJson(e)).toList();
      } else {
        data[key]["realtime"] = new List<BusInfoRealtime>();
      }
    }

    for(String key in (responseJson["timetable"] as Map<String, dynamic>).keys){
      List timetableInfo = responseJson["timetable"][key];
      if(timetableInfo.isNotEmpty) {
        data[key]["timetable"] =
            timetableInfo.map((e) => BusInfoTimetable.fromJson(e)).toList();
      }else{
        data[key]["timetable"] = new List<BusInfoTimetable>();
      }
    }
    return data;
  }
}

class BusTimetableController extends GetxController{
  RxMap<String, dynamic> timetableInfo = Map<String, dynamic>().obs;
  var isLoading = true.obs;

  final String route;

  BusTimetableController(this.route);

  @override
  void onInit(){
    updateTimetable(route);
    super.onInit();
  }

  updateTimetable(String route) async {
    try{
      isLoading(true);
      var data = await fetchTimeTable(route);
      if(data != null){
        timetableInfo.assignAll(data);
      }
    } finally {
      isLoading(false);
      refresh();
    }
  }

  fetchTimeTable(String route) async{
    final url = Uri.encodeFull(conf.getAPIServer() + "/app/bus/timetable");
    http.Response response = await http.post(url, headers: {"Accept": "application/json"}, body: jsonEncode({"campus": "ERICA", "route": route}));
    Map<String, dynamic> responseJson = jsonDecode(utf8.decode(response.bodyBytes));
    Map<String, dynamic> data = {"day": responseJson["day"], "weekdays": responseJson["weekdays"], "saturday": responseJson["saturday"], "sunday": responseJson["sunday"]};
    return data;
  }
}