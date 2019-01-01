import 'package:flutter/material.dart';
import 'rants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:pinch_zoom_image/pinch_zoom_image.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'userGram.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

//top one is dark theme
//bottom one is light theme
ThemeData _buildTheme(Brightness brightness) {
  return brightness == Brightness.dark
      ? ThemeData.dark().copyWith(
          primaryColor: Colors.black,
          accentColor: Colors.yellowAccent,
          textTheme: ThemeData.dark().textTheme.apply(
                fontFamily: 'Product Sans',
                bodyColor: Colors.grey,
              ),
          backgroundColor: Colors.black)
      : ThemeData.light().copyWith(
          primaryColor: Colors.white,
          accentColor: Colors.redAccent,
          textTheme: ThemeData.light().textTheme.apply(
                fontFamily: 'Product Sans',
              ),
          backgroundColor: Colors.white);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (brightness) => _buildTheme(brightness),
      themedWidgetBuilder: (context, theme) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'devRant',
            theme: theme,
            home: Rant(),
          ),
    );
  }
}

class Rant extends StatefulWidget {
  @override
  State createState() => new RantList();
}

class RantList extends State<Rant> {
  DevRant devRant;
  List<Rants> rantList;

  final String _kSortOrderPrefs = "recent";
  final String _kTagToggle = "true";
  final String _kFontValue = "16.0";
  String _algo = "recent";
  double _fontSize = 16.0;
  bool _showTags = true;

  //get Sorting order
  Future<String> getSortingOrder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _algo = prefs.getString(_kSortOrderPrefs);
    return prefs.getString(_kSortOrderPrefs);
  }

  //set Sorting order
  Future<bool> setSortingOrder(String order) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_kSortOrderPrefs, order);
  }

  //get tag toggle
  Future<bool> getTagToggle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _showTags = prefs.getBool(_kTagToggle) ?? true;
    return prefs.getBool(_kTagToggle);
  }

  //set tag toggle
  Future<bool> setTagToggle(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_kTagToggle, value);
  }

  //get Font Size
  Future<double> getFontSize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(_kFontValue) ?? 16.0;
    return prefs.getDouble(_kFontValue);
  }

  //set font Size
  Future<bool> setFontSize(double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble(_kFontValue, value);
  }

  @override
  void initState() {
    getSortingOrder();
    getTagToggle();
    getFontSize();
    super.initState();
  }

  Future<void> fetchRants() async {
    var url = 'https://devrant.com/api/devrant/rants?app=3&sort=' +
        _algo +
        '&limit=50';
    var result = await http.get(url);
    var decodedResult = jsonDecode(result.body);
    devRant = DevRant.fromJson(decodedResult);
    rantList = devRant.rants;
  }

  @override
  Widget build(BuildContext context) {
    var whiteIfDark = (Theme.of(context).brightness == Brightness.dark)
        ? Colors.white
        : Colors.black;

    var blackIfDark = (Theme.of(context).brightness == Brightness.dark)
        ? Colors.black
        : Colors.white;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: (Theme.of(context).brightness == Brightness.dark)
                ? Colors.white
                : Colors.black),
        title: Text('Mnml devRant',
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark)
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: (Theme.of(context).brightness == Brightness.dark)
            ? Colors.black
            : Colors.white,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
              tooltip: 'Refresh',
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {});
              }),
          IconButton(
              tooltip: 'Settings',
              icon: Icon(Icons.settings),
              onPressed: () {
                getFontSize();
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 8.0),
                          ListTile(
                              leading: Container(
                                  width: 50.0,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: NetworkImage(
                                              'https://avatars.devrant.com/v-21_c-3_b-5_g-m_9-1_1-2_16-8_3-1_8-4_7-4_5-1_12-2_6-2_10-7_2-37_22-7_11-3_18-1_19-3_4-1_20-2.png')))),
                              title: Text("developed with ❤️ by d02d33pak")),
                          ListTile(title: Text('Settings'), onTap: () {}),
                          Row(
                            children: <Widget>[
                              SizedBox(width: 16.0),
                              OutlineButton(
                                child: Text("-"),
                                onPressed: () {
                                  getFontSize();

                                  if (_fontSize > 16) {
                                    setFontSize(_fontSize - 1);
                                    setState(() {
                                      getFontSize();
                                    });
                                    // Navigator.pop(context);
                                  }
                                },
                              ),
                              Expanded(
                                  child: Center(
                                      child: Text("Font Size : " +
                                          _fontSize.toString()))),
                              OutlineButton(
                                child: Text("+"),
                                onPressed: () {
                                  getFontSize();
                                  if (_fontSize < 20) {
                                    setFontSize(_fontSize + 1);
                                    setState(() {
                                      getFontSize();
                                    });
                                    // Navigator.pop(context);
                                  }
                                },
                              ),
                              SizedBox(width: 16.0),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                OutlineButton(
                                  child: Text("Toggle Theme"),
                                  onPressed: () {
                                    DynamicTheme.of(context).setBrightness(
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Brightness.light
                                            : Brightness.dark);
                                  },
                                ),
                                OutlineButton(
                                  child: Text("Sort : " +
                                      _algo[0].toUpperCase() +
                                      _algo.substring(1)),
                                  onPressed: () {
                                    (_algo == "recent")
                                        ? setSortingOrder("best")
                                        : setSortingOrder("recent");
                                    setState(() {
                                      getSortingOrder();
                                    });
                                  },
                                ),
                                OutlineButton(
                                  child: Text("Toggle Tags"),
                                  onPressed: () {
                                    getTagToggle();
                                    (_showTags == true
                                        ? setTagToggle(false)
                                        : setTagToggle(true));

                                    setState(() {
                                      getTagToggle();
                                    });
                                  },
                                ),
                              ]),
                          SizedBox(
                            height: 16.0,
                          ),
                        ],
                      );
                    });
              }),
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: (Theme.of(context).brightness == Brightness.dark)
            ? Colors.black
            : Colors.white,
        onRefresh: fetchRants,
        child: FutureBuilder(
            future: fetchRants(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('Press Button to Start.');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.done:
                  if (snapshot.hasError)
                    return Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                            'Following Error Occured :\n' +
                                snapshot.error.toString(),
                            style: TextStyle(fontSize: 16.0)));
                  return rantLister(_fontSize);
              }
              return null;
            }),
      ),
    );
  }

  ListView rantLister(_fontSize) {
    List<Widget> _fetchTags(oneRant) {
      List<Widget> tags = new List();
      getTagToggle();

      if (_showTags) {
        for (var i = 0; i < oneRant.tags.length; i++) {
          if (oneRant.tags[i] != 'undefined') {
            tags.add(Transform(
                transform: Matrix4.identity()..scale(0.8),
                child: Chip(
                  label: Text(oneRant.tags[i]),
                  backgroundColor: Colors.transparent,
                  shape: StadiumBorder(side: BorderSide(color: Colors.grey)),
                )));
          }
        }
      }
      return tags;
    }

    return ListView.builder(
      itemCount: (rantList.length),
      itemBuilder: (context, index) => Container(
            color: (Theme.of(context).brightness == Brightness.dark)
                ? Colors.black
                : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 16.0,
                ),
                ListTile(
                  onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        UserGram userGram;
                        var userNo = rantList[index].userId.toString();
                        var userUrl = 'https://devrant.com/api/users/' +
                            userNo +
                            '?app=3&content=favorites&skip=0';

                        Future<void> fetchUser() async {
                          var res = await http.get(userUrl);
                          var decodedRes = jsonDecode(res.body);
                          userGram = UserGram.fromJson(decodedRes);
                          print(userGram.profile.about);
                        }

                        fetchUser();

                        return Dialog(
                            child: Container(
                                height: 256.0,
                                child: Center(child: Text('//TODO'))));
                      }),
                  leading: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  'https://avatars.devrant.com/' +
                                      rantList[index]
                                          .userAvatar
                                          .i
                                          .toString())))),
                  title: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(rantList[index].userUsername,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                      Container(
                          margin: EdgeInsets.only(right: 0.0),
                          child: Text(
                            DateFormat('hh:mmaaa  dd-LLL-yy').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    rantList[index].createdTime * 1000)),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          )),
                    ],
                  ),
                  subtitle: Text('++' + rantList[index].userScore.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      children: _fetchTags(rantList[index]),
                      spacing: -4.0,
                      runSpacing: -12.0,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      runAlignment: WrapAlignment.start,
                    )),
                (_showTags
                    ? SizedBox()
                    : SizedBox(
                        height: 24.0,
                      )),
                Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 0.0),
                    child: Text(
                      rantList[index].text,
                      style: TextStyle(
                        fontSize: _fontSize,
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: PinchZoomImage(
                    image: (rantList[index].image)
                        ? FadeInImage.memoryNetwork(
                            fadeInDuration: Duration(milliseconds: 700),
                            placeholder: kTransparentImage,
                            image: (rantList[index].image
                                ? rantList[index].attachedImage.url
                                : ''),
                          )
                        : SizedBox(),
                  ),
                ),
                Transform(
                    transform: Matrix4.identity()..scale(0.8),
                    alignment: Alignment(0.8, 0),
                    child: ButtonTheme.bar(
                      child: ButtonBar(
                        children: <Widget>[
                          FlatButton.icon(
                            icon: Icon(Icons.favorite_border),
                            label: Text(rantList[index].score.toString()),
                            onPressed: () {},
                          ),
                          FlatButton.icon(
                            icon: Icon(Icons.chat_bubble_outline),
                            label: Text(rantList[index].numComments.toString()),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    )),
                Center(
                    child: Container(
                  height: 3.0,
                  width: 128.0,
                  color: Colors.black12,
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                ))
              ],
            ),
          ),
    );
  }
}
