import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:podcasts_app/providers/analytics_provider.dart';
import 'package:podcasts_app/providers/auth_provider.dart';
import 'package:podcasts_app/providers/home_provider.dart';
import 'package:podcasts_app/providers/network_data_provider.dart';
import 'package:podcasts_app/providers/users_provider.dart';
import 'package:podcasts_app/splash_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await initializeDependencies();
  runApp(PodcastApp());
}

class PodcastApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        Provider<AnalyticsProvider>(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider()),
        ChangeNotifierProvider<NetworkDataProvider>(create: (_) => NetworkDataProvider()..init()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider(_auth, _storage)),
        ChangeNotifierProxyProvider<AuthProvider, UsersProvider>(
          create: (_) => UsersProvider(_storage),
          update: (context, auth, users) => users!
            ..updateAuth(auth)
            ..init(),
        ),
      ],
      child:MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.blue,
            accentColor: Color(0xffF0074D),
            backgroundColor: Color(0xffF0F0F0),
            fontFamily: "Nunito",
          ),
          builder: BotToastInit(),
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        ),
    );
  }
}

Future<void> initializeDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  await Hive.initFlutter();
  await Firebase.initializeApp();
}
