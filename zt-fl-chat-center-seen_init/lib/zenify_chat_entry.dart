import 'package:flutter/material.dart';
import 'package:zenify_chat/matrix/matrix_client_service.dart';
import 'package:zenify_chat/ui/rooms/room_screen.dart';

class ZenifyChatEntry extends StatefulWidget {
  final VoidCallback? onLogout;
  const ZenifyChatEntry({super.key, this.onLogout});

  @override
  State<ZenifyChatEntry> createState() => _ZenifyChatEntryState();
}

class _ZenifyChatEntryState extends State<ZenifyChatEntry> {
  late final MatrixClientService matrixClientService;
  late Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();
    matrixClientService = MatrixClientService();
    _initFuture = matrixClientService.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == false) {
          return const Scaffold(
            body: Center(child: Text("❌ Failed to start chat")),
          );
        }

        return RoomsScreen(
          store: matrixClientService.store,
          onLogout: widget.onLogout,
        );
      },
    );
  }
}
