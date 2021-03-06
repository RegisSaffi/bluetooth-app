import 'dart:async';

import 'package:bluetooth_app/views/device_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue/flutter_blue.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription scanSubscription;
  bool supported = false;
  List<ScanResult> devices = [];

  @override
  void initState() {
    checkAvailability();
    super.initState();
  }

  startScan() async {
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text("Start scanning...")));

    await flutterBlue
        .startScan(
            allowDuplicates: false,
            scanMode: ScanMode.lowLatency,
            timeout: Duration.zero)
        .whenComplete(() {
      listenDevices();
    });
  }

  listenDevices() async {
    print("Listening...");
    scanSubscription = flutterBlue
        .scan(
      allowDuplicates: false,
      scanMode: ScanMode.lowLatency,
    )
        .listen((event) {
     // print(event);

      if (devices.isNotEmpty) {
        if (devices.singleWhere(
                (element) => element.device.id == event.device.id,
                orElse: () => null) ==
            null) {
          setState(() {
            devices.add(event);
          });
        }
      } else {
        setState(() {
          devices.add(event);
        });
      }
    });
  }

  checkAvailability() async {
    var av = await flutterBlue.isAvailable;

    setState(() {
      supported = av;
    });

    if (av) startScan();
  }

  @override
  void dispose() {
    scanSubscription.cancel();
    flutterBlue.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _getMessage(
      String msg, {
      IconData icon = Icons.privacy_tip_rounded,
    }) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.red.shade200,
            size: 35,
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15, left: 15, top: 7),
            child: Text("$msg",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 17)),
          ),
        ],
      );
    }

    return Scaffold(
      body: SizedBox.expand(
          child: NestedScrollView(
              controller: ScrollController(keepScrollOffset: false),
              physics: BouncingScrollPhysics(),
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    centerTitle: false,
                    pinned: true,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 10, top: 2),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.withOpacity(.0),
                        child: Icon(Icons.bluetooth_rounded),
                      ),
                    ),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    title: Text(
                      "Bluetooth app",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size(5, 5),
                      child: Container(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 10),
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(22)),
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: "Search device",
                            icon: Icon(Icons.search),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16, bottom: 16, right: 16, top: 10),
                          child: Text(
                            "Bluetooth devices",
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        supported
                            ? StreamBuilder<bool>(
                                stream: flutterBlue.isScanning,
                                initialData: false,
                                builder: (context, snapshot) {
                                  return snapshot.data
                                      ? Container(
                                          height: 15,
                                          width: 15,
                                          margin: EdgeInsets.only(right: 15),
                                          child: CircularProgressIndicator
                                              .adaptive())
                                      : IconButton(
                                          onPressed: () async {

                                            await flutterBlue.stopScan();

                                            setState(() {
                                              devices=[];
                                            });

                                            startScan();

                                          },
                                          icon: Icon(Icons.refresh_rounded),
                                          color: Colors.green,
                                        );
                                })
                            : Container()
                      ],
                    ),
                  ),
                ];
              },
              body: Builder(builder: (context1) {
                return Center(
                    child: StreamBuilder<BluetoothState>(
                        stream: flutterBlue.state,
                        initialData: BluetoothState.off,
                        builder: (context, snapshot) {
                          if (snapshot.data == BluetoothState.off) {
                            flutterBlue.stopScan();
                            return _getMessage(
                                "Turn on your bluetooth for the application to function.");
                          } else if (snapshot.data ==
                              BluetoothState.unavailable) {
                            return _getMessage(
                                "Your device does not support bluetooth,this app can't help you anything.");
                          } else if (snapshot.data ==
                                  BluetoothState.turningOff ||
                              snapshot.data == BluetoothState.turningOn) {
                            return _getMessage(
                                "Your device does not support bluetooth,this app can't help you anything.");
                          } else if (snapshot.data == BluetoothState.on) {
                            if (devices.length == 0) {
                              return Center(
                                  child: _getMessage(
                                      "No bluetooth device found at the moment",
                                      icon: Icons.devices_other_rounded));
                            }

                            return ListView.builder(
                              itemBuilder: (context, i) {
                                return ListTile(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(
                                            builder: (_) => DeviceDetails(
                                                  device: devices[i].device,
                                                  data: devices[i]
                                                      .advertisementData,
                                                )));
                                  },
                                  leading: CircleAvatar(
                                    child: Text(
                                      "${i + 1}",
                                      style: TextStyle(
                                          color: i % 2 == 0
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  trailing: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.orange.shade100,
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                      "${devices[i].device.name == "" ? "Unnamed device" : devices[i].device.name}"),
                                  subtitle: Text("RSSI: ${devices[i].rssi}"),
                                );
                              },
                              itemCount: devices.length,
                              controller: PrimaryScrollController.of(context1),
                              padding: EdgeInsets.only(top: 0),
                            );

                          } else if (snapshot.data ==
                                  BluetoothState.turningOff ||
                              snapshot.data == BluetoothState.turningOn) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    height: 20,
                                    width: 20,
                                    child:
                                        CircularProgressIndicator.adaptive()),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    snapshot.data == BluetoothState.turningOn
                                        ? "Turning on Bluetooth..."
                                        : "Turning off Bluetooth...",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 17)),
                              ],
                            );
                          } else {
                            return _getMessage(
                                "Unknown error occurred, check if your device's bluetooth service is functioning properly.}.");
                          }
                        }));
              }))),
    );
  }
}
