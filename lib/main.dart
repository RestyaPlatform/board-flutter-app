import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/validator.dart';

String _url = '';

void main() => runApp(new RestyaboardApp());

class RestyaboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Restyaboard',
        //debugShowCheckedModeBanner: false,
        theme: new ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: const Color(0xFFf47564),
            accentColor: const Color(0xFFf47564)),
        home: new MyHomePage(title: 'Restyaboard'));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final formKey = GlobalKey<FormState>();

  // Obtain shared preferences
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Set URL in shared preferences
  Future<Null> _setRestyaboardUrl(url) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      prefs.setString('restyaboardUrl', url);
    });
  }

  // Get URL from shared preferences
  Future<String> _getRestyaboardUrl() async {
    final SharedPreferences prefs = await _prefs;
    //prefs.clear();
    String url = prefs.getString('restyaboardUrl');
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<String>(
        initialData: 'getUrl',
        future: _getRestyaboardUrl(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.data != 'getUrl') {
            if (snapshot.data != null) {
              _url = snapshot.data;
              return customBuildWithUrl(context, snapshot.data);
            } else {
              return customBuildToGetUrl(context);
            }
          }
          return new CircularProgressIndicator();
        });
  }

  Widget customBuildWithUrl(BuildContext context, url) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Container(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              new WebviewScaffold(
                  url: url,
                  bottomNavigationBar: customBottomNavigationBar(context, 0))
            ])),
        bottomNavigationBar: customBottomNavigationBar(context, 0));
  }

  Widget customBuildToGetUrl(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Form(
                key: formKey,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new TextFormField(
                      keyboardType: TextInputType.url,
                      validator: (val) =>
                          !isURL(val) ? 'Not a valid URL.' : null,
                      onSaved: (val) => _url = val,
                      decoration: new InputDecoration(
                        labelText: 'Restyaboard URL',
                        hintText: 'Restyaboard URL',
                      ),
                    ),
                    new RaisedButton(
                      onPressed: () {
                        final form = formKey.currentState;
                        if (form.validate()) {
                          form.save();
                          _setRestyaboardUrl(_url);
                          Navigator.pushReplacement(context,
                              new MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return customBuildWithUrl(context, _url);
                            },
                          ));
                        }
                      },
                      child: new Text('Submit'),
                    ),
                  ],
                ))),
        bottomNavigationBar: customBottomNavigationBar(context, 1));
  }

  Widget customBottomNavigationBar(BuildContext context, index) {
    return new BottomNavigationBar(
        currentIndex: index,
        onTap: (value) {
          if (_url != '') {
            Navigator.pushReplacement(context, new MaterialPageRoute<void>(
              builder: (BuildContext context) {
                if (value == 0) {
                  return customBuildWithUrl(context, _url);
                } else {
                  return customBuildToGetUrl(context);
                }
              },
            ));
          }
        },
        items: [
          new BottomNavigationBarItem(
              icon: const Icon(Icons.home), title: new Text('Home')),
          new BottomNavigationBarItem(
              icon: const Icon(Icons.settings), title: new Text('Settings'))
        ]);
  }
}
