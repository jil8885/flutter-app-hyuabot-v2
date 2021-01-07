import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_hyuabot_v2/Bloc/DatabaseController.dart';
import 'package:flutter_app_hyuabot_v2/Config/GlobalVars.dart';
import 'package:flutter_app_hyuabot_v2/Config/Localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:flutter_picker/flutter_picker.dart';

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapPageState();
}
class _MapPageState extends State<MapPage> {
  final _menus = [
    'korean',
    'japanese',
    'chinese',
    'western',
    'fast_food',
    'chicken',
    'pizza',
    'meat',
    'vietnamese',
    'other_food',
    'bakery',
    'cafe',
    'pub'
  ];
  List<String> _translatedMenus;

  DataBaseController _dataBaseController;
  List<Marker> _markers = [];
  Widget _map;
  bool _isInitial = true;
  FloatingSearchBar _floatingSearchBar;
  FloatingSearchBarController _floatingSearchBarController = FloatingSearchBarController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  _getMarkers(String category) async {
    _dataBaseController.fetchMarkers(category);
  }


  @override
  Widget build(BuildContext context) {
    if(_isInitial){
      Fluttertoast.showToast(
          msg: TranslationManager.of(context).trans("map_start_dialog"));
      _isInitial = false;
    }
    _dataBaseController = DataBaseController(context);
    _dataBaseController.init().whenComplete(() {});
    _translatedMenus = _menus.map((e) => TranslationManager.of(context).trans(e)).toList();
    _map = _naverMap(context);
    _floatingSearchBar = buildFloatingSearchBar();

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.category, color: Colors.white,),
        backgroundColor: Color(0xff2db400),
        onPressed: (){
          Picker(
            itemExtent: 40,
            adapter: PickerDataAdapter<String>(pickerdata: _translatedMenus),
            textAlign: TextAlign.center,
            hideHeader: true,
            onConfirm: (picker, value){
              _markers.clear();
              _getMarkers(_menus[value.elementAt(0)]);
            }
          ).showDialog(context);
          // showPicker(
          //     context: context,
          //     title: "Category",
          //     items: _translatedMenus,
          //     selectedItem: _selectedValue,
          //     onChanged: (value) {
          //       _selectedValue = _menus[_translatedMenus.indexOf(value)];
          //       _markers.clear();
          //       _getMarkers(_selectedValue);
          //     }
          // );
        },),
      body: Stack(
        children: [
          Container(
              padding: EdgeInsets.only(top: MediaQuery
                  .of(context)
                  .padding
                  .top),
              child: Container(child: _map)
          ),
          _floatingSearchBar
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  _naverMap(BuildContext context) {
    return StreamBuilder<List<Marker>>(
      stream: _dataBaseController.mapMarkers,
      builder: (context, snapshot) {
        if(snapshot.hasError || !snapshot.hasData){
          _markers.clear();
        } else {
          _markers = snapshot.data;
        }
        return NaverMap(
          markers: _markers,
          initialCameraPosition: CameraPosition(
              target: LatLng(37.300153, 126.837759), zoom: 17.5),
          mapType: MapType.Basic,
          symbolScale: 0,
          nightModeEnable: Theme
              .of(context)
              .backgroundColor == Colors.black,
          onMapCreated: _onMapCreated,
        );
      }
    );
  }

  void _onMapCreated(NaverMapController controller) {
    mapController = controller;
  }


  Widget buildFloatingSearchBar() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: TranslationManager.of(context).trans("phone_hint_text"),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      maxWidth: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      controller: _floatingSearchBarController,
      onQueryChanged: (query) {
        _dataBaseController.searchStore(query);
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {
              mapController.moveCamera(CameraUpdate.scrollTo(LatLng(37.300153, 126.837759)));
            },
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
          return StreamBuilder<List<StoreSearchInfo>>(
            stream: _dataBaseController.searchStoreStream,
            builder: (context, snapshot){
              if(snapshot.hasError || !snapshot.hasData || snapshot.data.isEmpty){
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Material(
                    color: Colors.white,
                    elevation: 4.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 75,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(TranslationManager.of(context).trans("phone_not_found"), style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color, fontSize: 20),),
                            ],
                          )
                        )],
                    ),
                  ),
                );
              } else{
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Material(
                    color: Colors.white,
                    elevation: 4.0,
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: snapshot.data.map((e) => InkWell(
                    onTap: (){
                      mapController.moveCamera(CameraUpdate.scrollTo(LatLng(e.latitude, e.longitude)));
                      _floatingSearchBar.controller.close();
                      _dataBaseController.addMarker([Marker(markerId: e.name, position: LatLng(e.latitude, e.longitude), infoWindow: e.name)]);
                    },
                      child: Container(
                        height: 75,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${e.name}-${e.menu}", style: Theme.of(context).textTheme.bodyText1, overflow: TextOverflow.ellipsis,),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              );
            }
          });
        }
      );
    }
}
