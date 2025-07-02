import 'package:flutter/material.dart';

class MenuConsultaPage extends StatelessWidget {
  const MenuConsultaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú Consulta')),
      body: const Center(
        child: Text(
          'Aquí va el contenido del menú consulta',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
