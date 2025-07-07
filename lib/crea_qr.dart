import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'base_sqlite.dart';

class CreaQR extends StatefulWidget {
  const CreaQR({Key? key}) : super(key: key);

  @override
  State<CreaQR> createState() => _CreaQRState();
}

class _CreaQRState extends State<CreaQR> {
  final GlobalKey _qrKey = GlobalKey();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _imagenSeleccionada;

  String qrData = '';

  Future<void> _seleccionarImagen() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Seleccionar desde galería'),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? imagen =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (imagen != null) {
                  setState(() {
                    _imagenSeleccionada = imagen;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar una foto'),
              onTap: () async {
                Navigator.of(context).pop();
                final XFile? foto =
                    await _picker.pickImage(source: ImageSource.camera);
                if (foto != null) {
                  setState(() {
                    _imagenSeleccionada = foto;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarQRComoImagen() async {
    try {
      if (_qrKey.currentContext == null) return;

      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permiso de almacenamiento denegado")),
        );
        return;
      }

      await Future.delayed(const Duration(milliseconds: 100));
      await WidgetsBinding.instance.endOfFrame;

      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      String filePath =
          '${directory.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await GallerySaver.saveImage(file.path);

      await DBHelper.insertarQR(
        _nombreController.text,
        _descripcionController.text,
        _fechaController.text,
        qrData,
        _imagenSeleccionada?.path ?? '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QR guardado en galería y base de datos")),
      );
    } catch (e) {
      print("Error al guardar QR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al guardar QR")),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear QR de Planta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre de planta'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _fechaController,
              decoration: const InputDecoration(labelText: 'Fecha de siembra'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _seleccionarImagen,
              child: const Text('Seleccionar o tomar foto de planta'),
            ),
            const SizedBox(height: 10),
            if (_imagenSeleccionada != null)
              Image.file(
                File(_imagenSeleccionada!.path),
                height: 150,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  qrData =
                      'Nombre: ${_nombreController.text}\nDescripción: ${_descripcionController.text}\nFecha: ${_fechaController.text}';
                });
              },
              child: const Text('Generar QR'),
            ),
            const SizedBox(height: 20),
            if (qrData.isNotEmpty)
              Column(
                children: [
                  RepaintBoundary(
                    key: _qrKey,
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _guardarQRComoImagen,
                    child: const Text('Guardar en galería'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
