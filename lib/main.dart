import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mealmapper/bloc/authentication/authentication_bloc.dart';
import 'package:mealmapper/bloc/firebase/firebase_bloc.dart';
import 'package:mealmapper/bloc/map/map_bloc.dart';
import 'package:mealmapper/firebase_options.dart';
import 'package:mealmapper/screens/authentication_screen.dart';
import 'package:mealmapper/services/api_service.dart';
import 'package:mealmapper/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Client httpClient;
  late ApiService apiService;
  late FirebaseAuth auth;
  bool _isUserSignedIn = false;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    apiService = ApiService(httpClient);
    auth = FirebaseAuth.instance;
    _isUserSignedIn = auth.currentUser != null;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MapBloc>(create: (context) => MapBloc(apiService)),
        BlocProvider<FirebaseBloc>(
            create: (context) => FirebaseBloc(auth: auth)),
        BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(auth: auth)),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          fontFamily: 'Georgia',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
            bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Hind'),
          ),
        ),
        home:
            _isUserSignedIn ? const MyHomePage() : const AuthenticationScreen(),
      ),
    );
  }
}
