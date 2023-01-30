import 'package:flutter/material.dart';
import 'package:dart_ipify/dart_ipify.dart';

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
  Future<String> ipv4 = Ipify.ipv4();
  Future<String> ipv6 = Ipify.ipv64();
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
        ],
      ),
    );
  }
}
