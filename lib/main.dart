import 'package:flutter/material.dart';
import 'base_sqlite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDB();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';

  void _login() async {
    if (_formKey.currentState!.validate()) {
      bool isValid = await DBHelper.validateUser(username, password);
      if (isValid) {
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(username: username)),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos')),
        );
      }
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      bool success = await DBHelper.registerUser(username, password);
      if (success) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado exitosamente')),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El usuario ya existe')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese su usuario' : null,
                onChanged: (value) => username = value,
              ),
              const SizedBox(height: 25),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese su contraseña' : null,
                onChanged: (value) => password = value,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 222, 234, 245),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 47, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 222, 234, 245),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String username;

  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido')),
      body: Center(
        child: Text('Hola, $username', style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
