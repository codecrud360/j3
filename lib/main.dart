import 'package:background_fetch/background_fetch.dart';
import 'package:j3enterprise/src/resources/services/background_fetch_service.dart';
import 'dart:io' show Platform;
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:j3enterprise/src/resources/services/firebase_message_wrapper.dart';
import 'package:j3enterprise/src/resources/services/init_services.dart';
import 'package:j3enterprise/src/resources/shared/lang/appLocalization.dart';
import 'package:j3enterprise/src/resources/shared/utils/routes.dart';
import 'package:j3enterprise/src/ui/about/about.dart';
import 'package:j3enterprise/src/ui/background_jobs/backgroundjobs_pages.dart';
import 'package:j3enterprise/src/ui/communication/setup_communication_page.dart';
import 'package:j3enterprise/src/ui/login_offline/offline_login_page.dart';
import 'package:j3enterprise/src/ui/preferences/preferences.dart';
import 'package:j3enterprise/src/ui/splash/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/resources/repositories/user_repository.dart';
import 'src/resources/shared/common/loading_indicator.dart';
import 'src/ui/authentication/authentication_bloc.dart';
import 'src/ui/authentication/authentication_event.dart';
import 'src/ui/authentication/authentication_state.dart';
import 'src/ui/home/home_page.dart';
import 'src/ui/login/login_page.dart';

GetIt getIt = GetIt.I;

void setupLocator() {
  getIt.registerLazySingleton(() => UserRepository());
}

Future<void> main() async {
  setupLocator();
//Important Information
//Don't change the order of InitServiceSetup
//Order of class
//1- InitalServerSetup
//2- setMokInitalValue
//3- setupLoggin

  WidgetsFlutterBinding.ensureInitialized();

  //InitServiceSetup initServiceSetup = new InitServiceSetup();

  if (Platform.isWindows || Platform.isMacOS) {
    SharedPreferences.setMockInitialValues({});
  }
  await systemInitelSetup();
  //await initServiceSetup.setupLogging();

  final userRepository = UserRepository();

  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (context) {
        return AuthenticationBloc()..add(AppStarted());
      },
      child: App(
        userRepository: userRepository,
      ),
    ),
  );
  if (Platform.isAndroid || Platform.isIOS) {
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }
}

class App extends StatefulWidget {
  final UserRepository userRepository;

  App({
    Key key,
    this.userRepository,
  }) : super(key: key);
  static void setLocale(BuildContext context, Locale locale) {
    _AppState state = context.findAncestorStateOfType<_AppState>();
    state.setLocale(locale);
  }

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Locale _locale;
  void setLocale(locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getIt<UserRepository>().getLocale().then((value) {
      setState(() {
        _locale = value;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseMessageWrapper(
      child: MaterialApp(
        builder: BotToastInit(),
        // navigatorObservers: [BotToastNavigatorObserver()],
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is PushNotificationState) {
              print(state.route);
              return getRoute(state.route);
            }
            if (state is AuthenticationCreateMobileHash) {
              return OfflineLoginPage(userRepository: widget.userRepository);
            }
            if (state is AuthenticationAuthenticated) {
              return HomePage();
            }
            if (state is AuthenticationUnauthenticated) {
              return LoginPage();
            }
            if (state is AuthenticationLoading) {
              return LoadingIndicator();
            }
            return SplashPage();
          },
        ),
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        locale: _locale,
        routes: routes,
        supportedLocales: [
          Locale('en', 'US'),
          Locale('es', 'ES'),
          Locale('sk', 'SK'),
        ],
        localizationsDelegates: [
          AppLocalization.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // Check if the current device locale is supported
          if (Platform.isAndroid) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
          } else if (Platform.isIOS) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
          }

          return supportedLocales.first;
        },
      ),
    );
  }

  dynamic getRoute(String route) {
    switch (route) {
      case 'offline_login':
        return OfflineLoginPage();
        break;
      case 'login':
        return LoginPage();
        break;
      case 'BackgroundJobs':
        return BackgroundJobsPage();
        break;
      case 'communication':
        return CommunicationPage();
        break;
      case 'preferences':
        return PreferencesPage();
        break;
      case 'home':
        return HomePage();
        break;
      case 'about':
        return About();
        break;
      default:
        return HomePage();
    }
  }
}
