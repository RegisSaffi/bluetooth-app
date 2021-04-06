import 'package:bluetooth_app/views/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceDetails extends StatefulWidget {
  final BluetoothDevice device;
  final AdvertisementData data;
  DeviceDetails({this.device,this.data});

  @override
  _DeviceDetailsState createState() => _DeviceDetailsState();
}

class _DeviceDetailsState extends State<DeviceDetails> {
  Future<bool> onPop()async {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>HomeScreen()));

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onPop,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          iconTheme: Theme.of(context).iconTheme,
          elevation: 0,
          title: Text(
            "Device details",
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Column(
          children: [
            ListTile(
              leading: Icon(Icons.devices_other_rounded),
              title: Text("Device name"),
              subtitle: Text("${widget.device.name==""?"Unnamed device":widget.device.name}"),
            ),
            ListTile(
              leading: Icon(Icons.assignment_rounded),
              title: Text("Device ID"),
              subtitle: Text("${widget.device.id}"),
            ),
            ListTile(
              leading: Icon(Icons.info_rounded),
              title: Text("Device type"),
              subtitle: Text("${widget.device.type}"),
            ),
            ListTile(
              leading: Icon(Icons.bluetooth_connected_rounded),
              title: Text("Connectable"),
              subtitle: Text("${widget.data.connectable}"),
            ),
            ListTile(
              leading: Icon(Icons.battery_full_rounded),
              title: Text("Power level"),
              subtitle: Text("${widget.data.txPowerLevel??'Not available'}"),
            ),
          ],
        ),
      ),
    );
  }
}
