import 'package:flutter/material.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:core';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IP Logger',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'IP Logger'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Map> getMap() async {
    Directory? dir = await getExternalStorageDirectory();
    String fileName = "iplog.txt";
    File jsonFile = File("${dir!.path}/$fileName");

    if (await jsonFile.exists()) {
      String contents = await jsonFile.readAsString();
      Map<String, dynamic> dict = jsonDecode(contents);
      return dict;
    } else {
      jsonFile.createSync();
      String ipv4 = await Ipify.ipv4();
      String ipv6 = await Ipify.ipv64();
      Map dicto = {DateTime.now().toString(): ipv4};
      jsonFile.writeAsStringSync(json.encode(dicto));
      if (ipv4 != ipv6) {
        writeToFile(DateTime.now.toString(), ipv6, jsonFile);
      }
      String contents = await jsonFile.readAsString();
      Map<String, dynamic> dict = jsonDecode(contents);
      return dict;
    }
  }

  void writeToFile(String key, dynamic value, File jsonFile) {
    Map<String, dynamic> dicto = {key: value};
    Map<String, dynamic> jsonFileContent =
        json.decode(jsonFile.readAsStringSync());
    jsonFileContent.addAll(dicto);
    jsonFile.writeAsStringSync(json.encode(jsonFileContent));
  }

  var subscription = Connectivity()
      .onConnectivityChanged
      .listen((ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        print('Wifi');
        break;
      case ConnectivityResult.mobile:
        print('Mobile');
        break;
      case ConnectivityResult.none:
        print('None');
        break;
      default:
        print('Unknown');
        break;
    }

    void writeToFile(String key, dynamic value, File jsonFile) {
      Map<String, dynamic> dicto = {key: value};
      Map<String, dynamic> jsonFileContent =
          json.decode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(dicto);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    }

    Future<Map> getMap() async {
      Directory? dir = await getExternalStorageDirectory();
      String fileName = "iplog.txt";
      File jsonFile = File("${dir!.path}/$fileName");

      if (await jsonFile.exists()) {
        String contents = await jsonFile.readAsString();
        Map<String, dynamic> dict = jsonDecode(contents);
        return dict;
      } else {
        jsonFile.createSync();
        String ipv4 = await Ipify.ipv4();
        String ipv6 = await Ipify.ipv64();
        Map dicto = {DateTime.now().toString(): ipv4};
        jsonFile.writeAsStringSync(json.encode(dicto));
        if (ipv4 != ipv6) {
          writeToFile(DateTime.now.toString(), ipv6, jsonFile);
        }
        String contents = await jsonFile.readAsString();
        Map<String, dynamic> dict = jsonDecode(contents);
        return dict;
      }
    }

    Directory? dir = await getExternalStorageDirectory();
    String fileName = "iplog.txt";
    File jsonFile = File("${dir!.path}/$fileName");
    bool found4 = true;
    bool found6 = true;
    List<String> temp = [];
    Map dict = await getMap();
    String ipv4 = await Ipify.ipv4();
    String ipv6 = await Ipify.ipv64();
    dict.forEach((key, value) => {temp.add(value)});
    for (String ip in temp) {
      if (ip == ipv4) {
        break;
      } else {
        found4 = false;
      }
    }
    if (found4 == false) {
      writeToFile(DateTime.now().toString(), ipv4, jsonFile);
    }
    for (String ip in temp) {
      if (ip == ipv6) {
        break;
      } else {
        found6 = false;
      }
    }
    if (found6 == false) {
      writeToFile(DateTime.now().toString(), ipv6, jsonFile);
    }
  });
  Future<String> ipv4 = Ipify.ipv4();
  Future<String> ipv6 = Ipify.ipv64();
  bool fileExists = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder(
            future: ipv4,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                  child: Text("IPV4: ${snapshot.data!}"),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          const SizedBox(height: 17),
          FutureBuilder(
              future: ipv6,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: Text("IPV6: ${snapshot.data!}"),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          const SizedBox(height: 25),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  ipv4 = Ipify.ipv4();
                  ipv6 = Ipify.ipv64();
                });
              },
              child: const Text('Refresh')),
          Expanded(
            child: FutureBuilder(
                future: getMap(),
                builder: (context, dict) {
                  if (dict.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return Scaffold(
                      body: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1),
                          itemCount: dict.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Center(
                              child: Text(dict.data!.keys.elementAt(index) +
                                  ":" +
                                  dict.data!.values.elementAt(index)),
                            );
                          }),
                    );
                  }
                }),
          )
        ],
      ),
    );
  }

  //Widget ges(dict) {
  //  List<String> ips = [];
  //  dict.forEach((key, value) {
  //    ips.add(key + ":" + value);
  //  });
  //  return Expanded(
  //    child: GridView.builder(
  //        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //            crossAxisCount: 1),
  //        itemCount: ips.length,
  //        itemBuilder: (BuildContext context, int index) {
  //          return Center(
  //            child: Text(ips[index]),
  //          );
  //        }),
  //  );
//}
}
