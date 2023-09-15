import 'package:flutter/material.dart';
import 'package:mdns_demo/mdns_device_model.dart';

class LocalGatewayTile extends StatefulWidget {
  const LocalGatewayTile(
      {Key? key, required this.mDnsDevice, required this.onTap})
      : super(key: key);
  final MdnsDevice mDnsDevice;
  final Function() onTap;

  @override
  _LocalGatewayTileState createState() => _LocalGatewayTileState();
}

class _LocalGatewayTileState extends State<LocalGatewayTile> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: InkWell(
            onTap: () async {
              _isLoading = true;
              if (mounted) setState(() {});

              await widget.onTap();

              _isLoading = false;
              if (mounted) setState(() {});
            },
            child: ListTile(
              leading: const Icon(Icons.wifi),
              title: Text(
                widget.mDnsDevice.name.replaceAll("Gateway_", "").toUpperCase(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              subtitle: Text(widget.mDnsDevice.ip),
            ),
          ),
        ),
        const Divider(
          thickness: 1,
        )
      ],
    );
  }

  Widget buildTrailing() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }
    if (widget.mDnsDevice.isLocked) {
      return const Icon(Icons.lock);
    }
    return const Text(
      "online" ??
          "",
    );
  }
}
