import 'package:flutter/material.dart';
import 'package:flutter_app_hyuabot_v2/Config/GlobalVars.dart';
import 'package:flutter_app_hyuabot_v2/Model/FoodMenu.dart';
import 'package:flutter_app_hyuabot_v2/UI/CustomScrollPhysics.dart';
import 'package:easy_localization/easy_localization.dart';

class FoodPage extends StatelessWidget {
  final  DateTime _now = DateTime.now();
  final Map<String, String> _cafeteriaList = {"학생식당": "student_erica", "교직원식당": "teacher_erica", "푸드코트": "food_court_erica", "창업보육센터": "changbo_erica", "창의인재원식당": "dorm_erica"};

  Widget _foodItem(BuildContext context, String menu, String price){
    String _priceString;
    if(prefManager!.getString("localeCode") == "ko_KR"){
      _priceString = '$price 원';
    } else {
      _priceString = '₩ $price';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(menu, style: TextStyle(color: Theme.of(context).backgroundColor == Colors.white? Colors.black : Colors.white,), textAlign: TextAlign.left,),
          SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_priceString, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).backgroundColor == Colors.white ? Color.fromARGB(255, 20, 75, 170) : Colors.lightBlue),),
            ],
          )
        ],
      ),
    );
  }

  Widget _cafeteriaCard(BuildContext context, Map<String, List<FoodMenu>> data, String name, int cardIndex){
    String kind = "lunch".tr();
    List<FoodMenu> currentFood = [];
    bool hasManyMenu = false;
    if(_now.hour < 11 && data['breakfast']!.isNotEmpty){
      currentFood = data['breakfast']!;
      kind = "breakfast".tr();
    } else if (_now.hour > 15 && data['dinner']!.isNotEmpty){
      currentFood = data['dinner']!;
      kind = "dinner".tr();
    } else if (data['lunch']!.isNotEmpty){
      currentFood = data['lunch']!;
    } else {
      currentFood = [];
    }

    List<Widget> currentFoodWidget;
    if(currentFood.isNotEmpty){
      currentFoodWidget = currentFood.map((e) => _foodItem(context, e.menu, e.price)).toList();
    } else {
      currentFoodWidget = [
        SizedBox(height: 10,),
        Container(child: Center(child: Text("menu_not_uploaded".tr(), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey),),),)
      ];
    }

    List<Widget> allFoodWidget = [];
    if(data['breakfast']!.isNotEmpty){
      hasManyMenu = true;
      allFoodWidget.addAll([
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("breakfast".tr(), style: TextStyle(color: Theme.of(context).backgroundColor == Colors.white? Colors.black : Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
            ],
          ),
        )
      ]);
      allFoodWidget.addAll(data['breakfast']!.map((e) => _foodItem(context, e.menu, e.price)).toList());
      allFoodWidget.add(Divider());
    }

    if(data['lunch']!.isNotEmpty){
      allFoodWidget.addAll([
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("lunch".tr(), style: TextStyle(color: Theme.of(context).backgroundColor == Colors.white? Colors.black : Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
            ],
          ),
        )
      ]);
      allFoodWidget.addAll(data['lunch']!.map((e) => _foodItem(context, e.menu, e.price)).toList());
      allFoodWidget.add(Divider());
    }

    if(data['dinner']!.isNotEmpty){
      hasManyMenu = true;
      allFoodWidget.addAll([
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("dinner".tr(), style: TextStyle(color: Theme.of(context).backgroundColor == Colors.white? Colors.black : Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
            ],
          ),
        )
      ]);
      allFoodWidget.addAll(data['dinner']!.map((e) => _foodItem(context, e.menu, e.price)).toList());
    }

    if(allFoodWidget.isNotEmpty && allFoodWidget[allFoodWidget.length - 1].runtimeType == Divider){
      allFoodWidget.removeLast();
    }

    if(allFoodWidget.isEmpty){
      allFoodWidget = [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("lunch".tr(), style: TextStyle(color: Theme.of(context).backgroundColor == Colors.white? Colors.black : Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Container(child: Center(child: Text("menu_not_uploaded".tr(), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey),),),)
      ];
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Card(
            elevation: 3,
            color: Theme.of(context).backgroundColor == Colors.black ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: allFoodWidget,
              ),
            )
        ),
      );
    } else if(!hasManyMenu){
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Card(
            elevation: 3,
            color: Theme.of(context).backgroundColor == Colors.black ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: allFoodWidget
              ),
            )
        ),
      );
    } else {
      return StreamBuilder(
        stream: foodInfoController.expandInfo,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(!snapshot.hasData || snapshot.hasError){
            return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Card(
                elevation: 3,
                color: Theme.of(context).backgroundColor == Colors.black ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                child: Container(child: CircularProgressIndicator()),)
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Card(
                elevation: 3,
                color: Theme.of(context).backgroundColor == Colors.black ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedCrossFade(
                          crossFadeState: !snapshot.data[cardIndex] ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          duration: kThemeAnimationDuration,
                          firstChild: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10, top: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(kind, style: TextStyle(color: Theme.of(context).backgroundColor == Colors.white? Colors.black : Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: currentFoodWidget,
                              ),
                            ],
                          ),
                          secondChild: Column(children: allFoodWidget,)
                      ),
                      InkWell(
                        onTap: (){foodInfoController.expandCard(cardIndex);},
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(icon: snapshot.data[cardIndex] ?? false ? Icon(Icons.keyboard_arrow_up_rounded):Icon(Icons.keyboard_arrow_down_rounded), onPressed: (){foodInfoController.expandCard(cardIndex);}),
                          ],
                        ),
                      )
                    ],
                  ),
                )
            ),
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle _theme1 = Theme.of(context).textTheme.bodyText2!;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: StreamBuilder(
          stream: foodInfoController.menuInfo,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if(snapshot.hasError){
              return Container(child: Center(child: Text("loading_error".tr()),), height: 50,);
            }
            if(!snapshot.hasData){
              return Container(child: Center(child: CircularProgressIndicator()), height: 50,);
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).textTheme.bodyText2!.color,), onPressed: (){Navigator.of(context).pop();}, alignment: Alignment.centerLeft,),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: CustomScrollPhysics(),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("student_cafeteria".tr(), style: TextStyle(color: _theme1.color, fontSize: 20), textAlign: TextAlign.center,)
                              ],
                            ),
                            _cafeteriaCard(context, snapshot.data[_cafeteriaList['학생식당']], _cafeteriaList['학생식당']!, 0),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("teacher_cafeteria".tr(), style: TextStyle(color: _theme1.color, fontSize: 20), textAlign: TextAlign.center,)
                              ],
                            ),
                            _cafeteriaCard(context, snapshot.data[_cafeteriaList['교직원식당']], _cafeteriaList['교직원식당']!, 1),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("food_court".tr(), style: TextStyle(color: _theme1.color, fontSize: 20), textAlign: TextAlign.center,)
                              ],
                            ),
                            _cafeteriaCard(context, snapshot.data[_cafeteriaList['푸드코트']], _cafeteriaList['푸드코트']!, 2),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("changbo_cafeteria".tr(), style: TextStyle(color: _theme1.color, fontSize: 20), textAlign: TextAlign.center,)
                              ],
                            ),
                            _cafeteriaCard(context, snapshot.data[_cafeteriaList['창업보육센터']], _cafeteriaList['창업보육센터']!, 3),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("dorm_cafeteria".tr(), style: TextStyle(color: _theme1.color, fontSize: 20), textAlign: TextAlign.center,)
                              ],
                            ),
                            _cafeteriaCard(context, snapshot.data[_cafeteriaList['창의인재원식당']], _cafeteriaList['창의인재원식당']!, 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        )
      ),
    );
  }
}
