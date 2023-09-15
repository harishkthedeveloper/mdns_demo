import 'dart:async';
import 'package:nsd/nsd.dart';
class MdnsDiscoveryService {
  factory MdnsDiscoveryService() => instance;

  MdnsDiscoveryService.internal();

  static final MdnsDiscoveryService instance = MdnsDiscoveryService.internal();

  List<Discovery> discoveries = [];
  Discovery currentDiscoveryObj = Discovery("");

  List<Service>? discoveryService = [];

  Completer<bool> isGatewayFound = Completer<bool>();

  Future<Discovery> startMdnsDiscovery({bool withNewDiscovery = false}) async {
    String serviceTypeDiscover = "<add_your_service>._tcp";

    if (withNewDiscovery) {
      if (discoveries.isNotEmpty) {
        try {
          // discoveries.remove(dis);
          discoveries.removeWhere((discovery) => discovery.id == currentDiscoveryObj.id);
          await stopDiscovery(
            currentDiscoveryObj,
          );
          print("[MDNS] MDNS DISCOVERY stopped ${currentDiscoveryObj.id}!! ${discoveries.length}");
        } catch (error, stack) {
          print("[MDNS] ERROR: ID:- ${currentDiscoveryObj.id} $error $stack");
        }
      }
    } else {
      if (discoveries.isNotEmpty) {
        Discovery discovery = discoveries.last;
        print(
            "[MDNS] MDNS DISCOVERY USING OLD STARTED ID:- ${discovery.id}!!");
        print(
            "[MDNS] MDNS SERVICE USING OLD DEVICE DISCOVERED !!:- ${discovery.services.length}");
        if (discovery.services.isNotEmpty) {
          if (isGatewayFound.isCompleted == false) {
            isGatewayFound.complete(true);
          }
        }
        return discovery;
      }
    }
    Discovery discovery = await startDiscovery(serviceTypeDiscover,
        ipLookupType: IpLookupType.v4);
    print("[MDNS] MDNS DISCOVERY STARTED ID:- ${discovery.id}!!");
    currentDiscoveryObj = discovery;
    discoveries.add(discovery);
    return discovery;
  }

  Future<void> stopDiscoveryService(Discovery discovery) async {
    try {
      discoveries?.removeWhere((ele)=>discovery.id==ele.id);
      await stopDiscovery(
        discovery,
      );
      print("[MDNS] MDNS DISCOVERY stopped ${discovery.id}!!");
    } catch (error) {
      print("[MDNS] ERROR: ID:- ${discovery.id} $error");
    }
  }

  Future<bool> discoveryNotifier({bool withNewDiscovery = false}) async {
    isGatewayFound = Completer<bool>();
    await startDiscoveryNotifierAgent(withNewDiscovery: withNewDiscovery);
    return isGatewayFound.future;
  }

  Future<void> startDiscoveryNotifierAgent(
      {bool withNewDiscovery = false}) async {
    Discovery discovery =
    await startMdnsDiscovery(withNewDiscovery: withNewDiscovery);
    discovery.addListener(() {
      print(
          "[MDNS] MDNS SERVICE DEVICE DISCOVERD !!:- ${discovery.services.length}");
      if (discovery.services.isNotEmpty ?? false) {
        if (isGatewayFound.isCompleted == false) {
          isGatewayFound.complete(true);
        }
      }
    });
    Future.delayed(const Duration(seconds: 30)).then(
          (value) {
        if (isGatewayFound.isCompleted == false) {
          discovery.removeListener(() {
            print(
                "[MDNS] MDNS SERVICE DEVICE DISCOVERD !!:- ${discovery.services.length}");
            if (discovery.services.isNotEmpty ?? false) {
              if (isGatewayFound.isCompleted == false) {
                isGatewayFound.complete(true);
              }
            }
          });
          isGatewayFound.completeError(
            TimeoutException("[MDNS] No Device Discovered !!"),
          );
        }
      },
    );
  }
}
