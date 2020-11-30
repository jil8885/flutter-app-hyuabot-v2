import 'package:flutter/material.dart';
import 'package:flutter_app_hyuabot_v2/Config/Common.dart';
import 'package:flutter_app_hyuabot_v2/Model/FoodMenu.dart';
import 'package:flutter_app_hyuabot_v2/Model/Shuttle.dart';

class CustomShuttleCard extends StatelessWidget {
  double _width;
  double _height;
  String title;
  List<String> timetable;
  ShuttleStopDepartureInfo data;

  CustomShuttleCard({this.title, this.timetable, this.data});

  @override
  Widget build(BuildContext context) {
    _width= MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    String remainedTimeString = "";
    String thisBusString = "";
    String nextBusString = "";

    Widget _remainedText;

    if(timetable.length >= 2){
      DateTime thisBus = getTimeFromString(timetable.elementAt(0), DateTime.now());
      remainedTimeString = '${thisBus.difference(DateTime.now()).inMinutes}';
      thisBusString = "이번 버스 : ${timetable.elementAt(0)}";
      if(data.shuttleListCycle.contains(timetable.elementAt(0))){
        thisBusString += "(순환)";
      } else if(data.shuttleListStation.contains(timetable.elementAt(0)) || data.shuttleListTerminal.contains(timetable.elementAt(0))){
        thisBusString += "(직행)";
      }
      nextBusString = "다음 버스 : ${timetable.elementAt(1)}";
      if(data.shuttleListCycle.contains(timetable.elementAt(1))){
        nextBusString += "(순환)";
      } else if(data.shuttleListStation.contains(timetable.elementAt(1)) || data.shuttleListTerminal.contains(timetable.elementAt(1))){
        nextBusString += "(직행)";
      }
    } else if(timetable.length == 1){
      DateTime thisBus = getTimeFromString(timetable.elementAt(0), DateTime.now());
      remainedTimeString = '${thisBus.difference(DateTime.now()).inMinutes}';
      thisBusString = "이번 버스 : ${timetable.elementAt(0)}";
      if(data.shuttleListCycle.contains(timetable.elementAt(0))){
        thisBusString += "(순환)";
      } else if(data.shuttleListStation.contains(timetable.elementAt(0)) || data.shuttleListTerminal.contains(timetable.elementAt(0))){
        thisBusString += "(직행)";
      }
      nextBusString = "막차입니다.";
    } else {
      thisBusString = "운영 종료";
    }

    if(timetable.length > 1){
      _remainedText = Flexible(
        child: Container(width: _width / 2.5,
            child: Row(
              children: [
                Text(remainedTimeString, style: TextStyle(fontSize: _height/30, fontFamily: 'Godo', color: Colors.black, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: true,),
                Text("분 후", style: TextStyle(fontSize: _height/45, fontFamily: 'Godo', color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: true,),
              ],
            )),
      );
    } else {
      _remainedText = Flexible(
        child: Container(width: _width / 2.5,
            child: Text(remainedTimeString, style: TextStyle(fontSize: _height/30, fontFamily: 'Godo', color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: true,)),
      );
    }

    return Card(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.only(left: 10, top: 10, right: 5, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontSize: _height/40, fontFamily: 'Godo', color: Colors.black),
                ),
                SizedBox(
                  height: 10,
                ),
                _remainedText,
                SizedBox(height: 25,),
                Container(width: _width / 2.5,
                    child: Text(thisBusString, style: TextStyle(fontSize: _height/50, fontFamily: 'Godo', color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: true,)
                ),
                SizedBox(height: 5),
                Container(width: _width / 2.5,
                    child: Text(nextBusString, style: TextStyle(fontSize: _height/50, fontFamily: 'Godo', color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: true,)),
              ],
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomFoodCard extends StatelessWidget {
  double _width;
  double _height;
  String title;
  String time;
  FoodMenu data;

  CustomFoodCard({this.title, this.time, this.data});

  @override
  Widget build(BuildContext context) {
    _width= MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    String _menu = "메뉴를 준비중입니다";
    String _price = "0";
    if(data == null){
      _menu = "준비된 메뉴가 없습니다";
    } else {
      _menu = data.menu;
      _price = data.price;
    }
    return Card(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.only(left: 10, top: 10, right: 5, bottom: 10),
        width: _width * .75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('$title($time)', style: TextStyle(fontSize: _height/40, fontFamily: 'Godo', color: Colors.black),),
            SizedBox(height: 20,),
            Text(_menu, style: TextStyle(fontSize: _height/60, fontFamily: 'Godo', color: Colors.black),),
            Flexible(child: Container(),),
            Text('$_price 원', style: TextStyle(fontSize: _height/50, fontFamily: 'Godo', color: Theme.of(context).accentColor),)
          ],
        ),
      )
    );
  }
}