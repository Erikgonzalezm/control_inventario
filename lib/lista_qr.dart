import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'base_sqlite.dart';

class ListaQR extends StatefulWidget {
  const ListaQR({Key? key}) : super(key: key);

  @override
  State<ListaQR> createState() => _ListaQRState();
}

class _ListaQRState extends State<ListaQR> {
  List<Map<String, dynamic>> qrList = [];

  @override
  void initState() {
    super.initState();
    _cargarQR();
  }

  Future<void> _cargarQR() async {
    final list = await DBHelper.obtenerTodosQR();
    setState(() {
      qrList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Guardados')),
      body: ListView.builder(
        itemCount: qrList.length,
        itemBuilder: (context, index) {
          final item = qrList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              title: Text(item['nombre'] ?? 'Sin nombre'),
              subtitle: Text(
                'Descripción: ${item['descripcion'] ?? ''}\nFecha: ${item['fecha'] ?? ''}',
              ),
              trailing: SizedBox(
                width: 70,
                height: 70,
                child: QrImageView(
                  data: item['contenido'] ?? '',
                  version: QrVersions.auto,
                  size: 60,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
