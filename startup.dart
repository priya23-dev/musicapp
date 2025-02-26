import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:musicapp/handlers/ihandler_dart.dart';
import 'package:musicapp/handlers/jellyfin_handler.dart';
import 'package:musicapp/handlers/panaudio_handler.dart';

startup()async{
  var serverType = GetStorage().read('ServerType') ?? "Jellyfin";

  GetIt.I.registerSingleton<IHandler>(
    JellyfinHandler(),
    instanceName: 'Jellyfin',
  );

  GetIt.I.registerSingleton<IHandler>(
    PanaudioHandler(),
    instanceName: 'PanAudio',
  );

  GetIt.I.registerFactory<IHandler>(() {
    return GetIt.I.get<IHandler>(instanceName: serverType);
  });

}