import '../../models/vpn_model.dart';
import 'package:flutter/material.dart';
import '/generated/l10n.dart';
import 'package:provider/provider.dart';

class ConnectionModePage extends StatefulWidget {
  const ConnectionModePage({Key? key}) : super(key: key);

  @override
  _ConnectionModeState createState() => _ConnectionModeState();
}

class VpnProtocolModel {
  VpnProtocolModel(this.name, this.description, this.mode);

  String name;
  String description;
  VpnProtocol mode;
}

class _ConnectionModeState extends State<ConnectionModePage> {
  List<VpnProtocolModel> protocols = List.empty(growable: true);

  void loadVpnProtocols() {
    protocols.clear();

    protocols.add(VpnProtocolModel(
        S.of(context).auto, S.of(context).auto_description, VpnProtocol.auto));
    protocols.add(VpnProtocolModel(S.of(context).fastway_udp,
        S.of(context).fastway_udp_description, VpnProtocol.udp));

    protocols.add(VpnProtocolModel(S.of(context).fastway_tcp,
        S.of(context).fastway_tcp_description, VpnProtocol.tcp));

    protocols.add(VpnProtocolModel(S.of(context).fastway_dtls,
        S.of(context).fastway_dtls_description, VpnProtocol.dtls));
    protocols.add(VpnProtocolModel(S.of(context).fastway_tls,
        S.of(context).fastway_tls_description, VpnProtocol.tls));
  }

  @override
  Widget build(BuildContext context) {
    loadVpnProtocols();

    return Consumer<VpnModel>(
      builder: (context, vpnModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).connection_mode),
          ),
          body: SafeArea(
              child: Column(
            children: [
              const Divider(
                height: 1,
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.separated(
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: protocols.length,
                    itemBuilder: (ctx, index) {
                      final protocol = protocols[index];
                      return ListTile(
                        title: Text(protocol.name),
                        subtitle: Text(protocol.description),
                        trailing: null,
                        selected: Provider.of<VpnModel>(context, listen: false)
                                .protocol ==
                            protocol.mode,
                        onTap: () =>
                            Provider.of<VpnModel>(context, listen: false)
                                .changeProtocol(protocol.mode),
                      );
                    }),
              )
            ],
          )),
        );
      },
    );
  }
}
