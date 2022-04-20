import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:podcasts_app/providers/ai_provider.dart';
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
  final FirebaseRemoteConfig _config = FirebaseRemoteConfig.instance;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        Provider<AnalyticsProvider>(
          create: (_) => AnalyticsProvider(),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => HomeProvider(),
        ),
        ChangeNotifierProvider<NetworkDataProvider>(
          create: (_) => NetworkDataProvider()
            ..init(
              _config.getString("API_KEY"),
            ),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(_auth, _storage),
        ),
        ChangeNotifierProvider<AiProvider>(
          create: (_) => AiProvider(_auth, _storage)
            ..init(
              _config.getString("WATSON_API_KEY"),
            ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UsersProvider>(
          create: (_) => UsersProvider(_storage),
          update: (context, auth, users) => users!..updateAuth(auth),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.blue,
          accentColor: Color(0xffF0074D),
          backgroundColor: Color(0xffEEEEEE).withBlue(255),
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
  await Firebase.initializeApp();
  await FirebaseRemoteConfig.instance.fetchAndActivate();
}
