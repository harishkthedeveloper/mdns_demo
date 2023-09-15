
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mdns_demo/device_tile.dart';
import 'package:mdns_demo/mdns_device_model.dart';
import 'package:mdns_demo/nsd_service.dart';
import 'package:nsd/nsd.dart';

//ignore: must_be_immutable
class LocalWifiScanList extends StatefulWidget {
  LocalWifiScanList({
    Key? key,
  }) : super(key: key);

  @override
  _LocalWifiScanListState createState() => _LocalWifiScanListState();
}

class _LocalWifiScanListState extends State<LocalWifiScanList> {
  Timer? _timer;
  Timer? timerForTimeOut;

  // Discovery? discovery;

  // List<Service>? discoveryService;

  @override
  void dispose() {
    _timer?.cancel();
    timerForTimeOut?.cancel();
    if (MdnsDiscoveryService().currentDiscoveryObj != null) {
      MdnsDiscoveryService().currentDiscoveryObj?.removeListener(addServiceListener);
      stopDiscovery(MdnsDiscoveryService().currentDiscoveryObj!);
    }
    MdnsDiscoveryService().stopDiscoveryService(MdnsDiscoveryService().currentDiscoveryObj!);
    super.dispose();
  }

  @override
  void initState() {
    initializeLWM();
    super.initState();
  }

  void initializeLWM() async {
    _timer = Timer.periodic(
      const Duration(seconds: 5),
          (Timer t) => _keepScanning(),
    );
    await initializeDiscovery();
    getServicesFromDiscoveryAndSort();
    if (mounted) setState(() {});
  }

  void startTimeOutTimer() {
      timerForTimeOut = Timer(const Duration(seconds: 30), () {
       timerForTimeOut?.cancel();
      timerForTimeOut = null;
      if ((MdnsDiscoveryService().currentDiscoveryObj?.services.isEmpty ?? true) == true) {
       print(
            "discovery data length:- ${MdnsDiscoveryService().currentDiscoveryObj?.services.length ?? 0} SO Navigating to landing page");

      }
    });
  }

  void stopTimeOutTimer() {
    print("Timeout timer Stopped !!");
    timerForTimeOut?.cancel();
    timerForTimeOut = null;
  }

  Future<void> initializeDiscovery({bool withNewDiscovery = false}) async {
    MdnsDiscoveryService().currentDiscoveryObj = await MdnsDiscoveryService()
        .startMdnsDiscovery(withNewDiscovery: withNewDiscovery);
    MdnsDiscoveryService().currentDiscoveryObj?.addListener(addServiceListener);;
    if (mounted) setState(() {});
  }

  void addServiceListener() {
    print(
        "Discovery LISTENER: CURRENT :- ${MdnsDiscoveryService().discoveryService?.length ?? 0}  NEW LIST:- ${MdnsDiscoveryService().currentDiscoveryObj?.services.length ?? 0} ");

    getServicesFromDiscoveryAndSort();

    // if (discoveryService == null || discoveryService?.isEmpty == true) {
    print(
        "Discovery LISTENER FOUND DEVICES:- ${MdnsDiscoveryService().discoveryService?.length ?? 0} So Stopping the timeout timer");
    stopTimeOutTimer();
    // }
    if (mounted) setState(() {});
  }

  void getServicesFromDiscoveryAndSort() {
    List<Service> sortedDiscovery = <Service>[];

    for (Service service in (MdnsDiscoveryService().currentDiscoveryObj?.services ?? <Service>[])) {
      sortedDiscovery.add(service);
    }

    sortedDiscovery.sort((a, b) => (a.name?.compareTo(b.name ?? "") ?? 0));
    MdnsDiscoveryService().discoveryService = sortedDiscovery;
  }

  @override
  Widget build(BuildContext context) {

    if (MdnsDiscoveryService().discoveryService == null || MdnsDiscoveryService().discoveryService?.isEmpty == true) {
      return  Scaffold(
        appBar: AppBar(
          title: const Text('demo'),
          // Set the leading property to add a back action button
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Define the action to be performed when the back button is pressed.
              Navigator.pop(context); // Typically, this will navigate back to the previous screen.
            },
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('demo'),
        // Set the leading property to add a back action button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Define the action to be performed when the back button is pressed.
            Navigator.pop(context); // Typically, this will navigate back to the previous screen.
          },
        ),
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Service? service = MdnsDiscoveryService().discoveryService?[index];
            if (service != null) {
              MdnsDevice device = MdnsDevice.fromService(service: service);
              return Material(
                child: LocalGatewayTile(
                  onTap: (){},
                  mDnsDevice: device,
                ),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: CircularProgressIndicator(),
              ),
            );
          },
          itemCount: MdnsDiscoveryService().discoveryService?.length ?? 0,
        ),
      ),
    );
  }

  Future<void> _keepScanning() async {
    print("5 Seconds timer triggered !!");

    if (timerForTimeOut == null) {
      print("New Discovery Started");
      await initializeDiscovery(withNewDiscovery: true);
      startTimeOutTimer();
    }
  }

}
