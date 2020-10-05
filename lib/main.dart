import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_scraper/web_scraper.dart';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Dictionnaire',
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _formKey = GlobalKey<FormState>();
  var _wordController = TextEditingController();
  StreamController _streamController;
  Stream _stream;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
    _initChaptersTitleScrap('bienvenue');
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.grey[200]))),
                        child: TextFormField(
                          controller: _wordController,
                          decoration: InputDecoration(
                              labelText: "Mot",
                              errorStyle: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                              hintText: "Mot",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return "Le mot est obligatoire";
                            } else if (value
                                .contains(new RegExp(r"[0-9]|@|\+|-|\/|\*"))) {
                              return "Le mot doit contenir seuelement des alphabets";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.search),
                      color: Colors.green,
                      onPressed: () async {
                        _formKey.currentState.validate();
                        await _initChaptersTitleScrap(_wordController.text);
                      },
                    ),
                  ),
                ),
              ],
            ),
            //Don't forget to add title aller, verbe transsitif
            StreamBuilder(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length == 0) {
                      return Center(
                        child: Text(
                          'Ce mot est introuvable',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.red,
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            if (snapshot.data[index]['title']
                                    .substring(0, "aller".length) ==
                                snapshot.data[0]['title']
                                    .substring(0, "aller".length)) {
                              return Center(
                                  child: Text(
                                snapshot.data[index]['title'].trim(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ));
                            } else {
                              return snapshot.data[index]['title']
                                      .replaceAll(new RegExp(r"\s+"), "")
                                      .contains('Sens')
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Card(
                                        elevation: 10,
                                        child: ListTile(
                                          title: Text(
                                            snapshot.data[index]['title']
                                                .replaceAll(
                                                    new RegExp(r"\s+"), " ")
                                                .trim(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            snapshot.data[index + 1]['title']
                                                .replaceAll(
                                                    new RegExp(r"^\ "), "")
                                                .replaceAll(
                                                    new RegExp(r"\s+"), " ")
                                                .replaceAll(
                                                    new RegExp(r" Synonyme"),
                                                    "\nSynonyme")
                                                .replaceAll(
                                                    new RegExp(r" Exemple"),
                                                    "\nExemple")
                                                .replaceAll(
                                                    new RegExp(r" Traduction"),
                                                    "\nTraduction")
                                                .trim(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text('');
                            }
                          });
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }

  _initChaptersTitleScrap(word) async {
    List<Map<String, dynamic>> firstElt = null;
    final webScraper = WebScraper('https://www.linternaute.fr');
    if (await webScraper.loadWebPage('/dictionnaire/fr/definition/${word}')) {
      firstElt = webScraper.getElement(
          'section.dico_definition > .dico_title_2, section.dico_definition > .dico_liste > li > .grid_line > .grid_left, .dico_definition > .dico_liste > li > .grid_line > .grid_last',
          []);
      _streamController.add(firstElt);
    } else {
      print('Cannot load url');
    }
  }
}
