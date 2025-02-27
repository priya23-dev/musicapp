import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:musicapp/controllers/PlaybackByDaysController.dart';
import 'package:musicapp/controllers/album_controller.dart';
import 'package:musicapp/controllers/all_albums_controller.dart';
import 'package:musicapp/controllers/all_songs_controller.dart';
import 'package:musicapp/controllers/api_controller.dart';
import 'package:musicapp/controllers/artist_controller.dart';
import 'package:musicapp/controllers/download_controller.dart';
import 'package:musicapp/controllers/individual_song_controller.dart';
import 'package:musicapp/controllers/latest_albums_controller.dart';
import 'package:musicapp/controllers/liked_controller.dart';
import 'package:musicapp/controllers/log_box_controller.dart';
import 'package:musicapp/controllers/lyrics_page_controller.dart';
import 'package:musicapp/controllers/most_played_songs_artist_controller.dart';
import 'package:musicapp/controllers/most_played_songs_controller.dart';
import 'package:musicapp/controllers/playback_artists_controller.dart';
import 'package:musicapp/controllers/playback_history_day_list_controller.dart';
import 'package:musicapp/controllers/playlist_controller.dart';
import 'package:musicapp/controllers/playlists_controller.dart';
import 'package:musicapp/controllers/songs_controller.dart';
import 'package:musicapp/controllers/songs_list_item_controller.dart';
import 'package:musicapp/handlers/ihandler_dart.dart';
import 'package:musicapp/handlers/jellyfin_handler.dart';
import 'package:musicapp/handlers/logger_handler.dart';
import 'package:musicapp/handlers/panaudio_handler.dart';
import 'package:musicapp/hive/classes/albums.dart';
import 'package:musicapp/hive/classes/artists.dart';
import 'package:musicapp/hive/classes/log.dart';
import 'package:musicapp/hive/classes/songs.dart';
import 'package:musicapp/hive/helpers/isynchelper.dart';
import 'package:musicapp/hive/helpers/panaudio_sync_helper.dart';
import 'package:musicapp/hive/helpers/sync_helper.dart';
import 'package:musicapp/homepage.dart';
import 'package:musicapp/providers/music_controller_provider.dart';
import 'package:musicapp/repos/jellyfin_repo.dart';
import 'package:musicapp/repos/panaudio_repo.dart';
import 'package:musicapp/repos/subsonic_repo.dart';
import 'package:sizer/sizer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quick_actions/quick_actions.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await GetStorage.init();
  Hive.registerAdapter(SongsAdapter());
  Hive.registerAdapter(ArtistsAdapter());
  Hive.registerAdapter(AlbumsAdapter());
  Hive.registerAdapter(LogAdapter());





  GetIt.I.registerSingleton<LogHandler>(LogHandler());

  //Repos
  GetIt.I.registerSingleton<PanaudioRepo>(PanaudioRepo());
  GetIt.I.registerSingleton<SubsonicRepo>(SubsonicRepo());
  GetIt.I.registerSingleton<JellyfinRepo>(JellyfinRepo());


  //  await startup();
  var serverType = GetStorage().read('ServerType') ?? "Jellyfin";

  //SyncHelpers
  GetIt.I.registerSingleton<ISyncHelper>(
    SyncHelper(),
    instanceName: 'Jellyfin',
  );
  GetIt.I.registerSingleton<ISyncHelper>(
    PanaudioSyncHelper(),
    instanceName: 'PanAudio',
  );

  GetIt.I.registerSingleton<IHandler>(
    JellyfinHandler(),
    instanceName: 'Jellyfin',
  );

  GetIt.I.registerSingleton<IHandler>(
    PanaudioHandler(),
    instanceName: 'PanAudio',
  );

  //Handlers

  GetIt.I.registerSingleton<LogBoxController>(LogBoxController());
  GetIt.I.registerSingleton<ApiController>(ApiController());
  GetIt.I.registerSingleton<AllSongsController>(AllSongsController());
  GetIt.I.registerSingleton<AllAlbumsController>(AllAlbumsController());
  GetIt.I.registerSingleton<LatestAlbumsController>(LatestAlbumsController());
  GetIt.I.registerSingleton<SongsController>(SongsController());
  GetIt.I.registerSingleton<AlbumController>(AlbumController());
  GetIt.I.registerSingleton<ArtistController>(ArtistController());
  GetIt.I.registerSingleton<LikedController>(LikedController());
  GetIt.I.registerSingleton<DownloadController>(DownloadController());
  GetIt.I.registerSingleton<PlaylistsController>(PlaylistsController());
  GetIt.I.registerSingleton<PlaylistController>(PlaylistController());
  GetIt.I.registerSingleton<MostPlayedSongsController>(MostPlayedSongsController());
  GetIt.I.registerSingleton<MostPlayedSongsArtistController>(MostPlayedSongsArtistController());
  GetIt.I.registerSingleton<PlaybackByDaysController>(PlaybackByDaysController());
  GetIt.I.registerSingleton<PlaybackArtistsController>(PlaybackArtistsController());
  GetIt.I.registerSingleton<SongsListItemController>(SongsListItemController());
  GetIt.I.registerSingleton<PlaybackHistoryDayListController>(PlaybackHistoryDayListController());
  GetIt.I.registerSingleton<IndividualSongController>(IndividualSongController());
  GetIt.I.registerSingleton<LyricsPageController>(LyricsPageController());


  const QuickActions quickActions = QuickActions();
  quickActions.setShortcutItems(<ShortcutItem>[
    const ShortcutItem(
      type: 'play_liked_songs',
      localizedTitle: 'Play Liked Songs',
    ),
    const ShortcutItem(
      type: 'play_most_played',
      localizedTitle: 'Play Most Played',
    )
  ]);

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MusicControllerProvider(
    child:MyApp(),
  ));
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 204, 204, 204),
        foregroundColor:  Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Color.fromARGB(255, 204, 204, 204),
        )
    ),
    cardTheme: const CardTheme(color: Color.fromARGB(255, 179, 179, 179)),
    scaffoldBackgroundColor:const Color.fromARGB(255, 204, 204, 204),
    primaryColor: Colors.teal, // Your primary color for dark mode
    canvasColor:const Color.fromARGB(255, 179, 179, 179),
    focusColor: Colors.red,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.grey, // Use your primary color here
      accentColor: const Color.fromARGB(255, 69, 69, 69),
      backgroundColor: const Color.fromARGB(255, 204, 204, 204), // Your secondary color
    ), // Your accent color for dark mode
    popupMenuTheme: const PopupMenuThemeData(
      color: Color.fromARGB(255, 179, 179, 179),
      iconColor: Color.fromARGB(255, 179, 179, 179),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor:  WidgetStateProperty.all<Color>(const Color.fromARGB(255, 179, 179, 179)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
            ),
          ),
        )
    ),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 179, 179, 179)),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
            ),
          ),
        )
    ),
    textTheme: const TextTheme(
        displayLarge: TextStyle(color:Colors.black, fontSize:36, fontWeight: FontWeight.w600,),
        displaySmall: TextStyle(color: Colors.black, fontSize:16, fontWeight: FontWeight.w600),
        labelLarge: TextStyle(color: Colors.black, fontSize:26, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600), // Text color for dark theme
        bodyMedium: TextStyle(color: Colors.black, fontSize: 18),
        bodySmall: TextStyle(color: Colors.black, fontSize: 16),
        labelSmall: TextStyle(color: Colors.black, fontSize: 11)
    ),
    // Add other dark theme properties here
  );



  static ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1B1B),
          foregroundColor:  Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0xFF1C1B1B),
          )
      ),
      cardTheme: const CardTheme(color: Color.fromARGB(255, 37, 37, 37)),
      scaffoldBackgroundColor: const Color(0xFF1C1B1B),
      primaryColor: Colors.teal, // Your primary color for dark mode
      canvasColor:const Color.fromARGB(255, 37, 37, 37),
      focusColor: Colors.red,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.grey, // Use your primary color here
        accentColor: Colors.blueGrey,
        errorColor: Colors.blueGrey,
        backgroundColor: const Color(0xFF1C1B1B), // Your secondary color
      ), // Your accent color for dark mode
      textTheme: const TextTheme(
          displayLarge: TextStyle(color:Colors.black, fontSize:36, fontWeight: FontWeight.w600),
          displaySmall: TextStyle(color: Colors.white, fontSize:16, fontWeight: FontWeight.w600),
          labelLarge: TextStyle(color: Colors.white, fontSize:26, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600), // Text color for dark theme
          bodyMedium: TextStyle(color: Colors.white, fontSize: 18),
          bodySmall: TextStyle(color: Colors.white, fontSize: 16),
          labelSmall: TextStyle(color: Colors.white, fontSize: 11)
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 37, 37, 37)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
              ),
            ),
          )
      ),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 37, 37, 37)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
              ),
            ),
          )
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Color.fromARGB(255, 37, 37, 37),
        iconColor: Color.fromARGB(255, 37, 37, 37),
      ),
      iconTheme: const IconThemeData(color: Colors.blueGrey)
    // Add other dark theme properties here
  );

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return  AdaptiveTheme(
        light: lightTheme,
        dark: darkTheme,
        initial: AdaptiveThemeMode.system,
        builder: (theme, darkTheme) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'panaudio',
          theme: theme,
          darkTheme: darkTheme,
          home: const MyHomePage(),
        ),
      );
    });
  }
}