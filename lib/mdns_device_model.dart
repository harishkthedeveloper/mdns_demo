library local_wifi_manager_old;

/// @Author: BRIJESH SAKARIYA
/// @Email: brijesh.sakariya@uleeco.com
/// @Created On: 28,July,2023

import 'package:nsd_platform_interface/src/nsd_platform_interface.dart';

class MdnsDevice {
  MdnsDevice({
    required this.name,
    required this.ip,
    required this.isLocked,
    this.isLoading = false,
  });

  String name;
  String ip;
  bool isLocked;
  bool isLoading = false;

  factory MdnsDevice.fromJson(Map<String, dynamic> json) => MdnsDevice(
        name: json["name"] == null ? "" : json["name"] as String,
        ip: json["ip"] == null ? "" : json["ip"] as String,
        isLocked: json["isLocked"] == null ? true : json["isLocked"] as bool,
      );

  Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "ip": ip == null ? null : ip,
        "isLocked": isLocked == null ? null : isLocked,
      };

  static MdnsDevice fromService({required Service service}) {
    return MdnsDevice(
        name: service.name ?? "",
        ip: service.addresses?.first.address ?? service.host ?? "",
        isLocked: isLockedGateway(
            ip: service.addresses?.first.address ?? service.host ?? ""));
  }

  static bool isLockedGateway({required String ip}) {
    return true;
  }
}
