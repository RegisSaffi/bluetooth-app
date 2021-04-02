import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceDetails extends StatelessWidget {
  final BluetoothDevice device;
  final AdvertisementData data;
  DeviceDetails({this.device,this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            subtitle: Text("${device.name==""?"Unnamed device":device.name}"),
          ),
          ListTile(
            leading: Icon(Icons.assignment_rounded),
            title: Text("Device ID"),
            subtitle: Text("${device.id}"),
          ),
          ListTile(
            leading: Icon(Icons.info_rounded),
            title: Text("Device type"),
            subtitle: Text("${device.type}"),
          ),
          ListTile(
            leading: Icon(Icons.bluetooth_connected_rounded),
            title: Text("Connectable"),
            subtitle: Text("${data.connectable}"),
          ),
          ListTile(
            leading: Icon(Icons.battery_full_rounded),
            title: Text("Power level"),
            subtitle: Text("${data.txPowerLevel??'Not available'}"),
          ),
        ],
      ),
    );
  }
}
