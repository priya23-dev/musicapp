
import 'dart:io';

import 'package:musicapp/hive/classes/artists.dart';
import 'package:musicapp/models/album.dart';
import 'package:musicapp/models/playlists.dart';

abstract class IHandler {
  updateFavouriteStatus(String itemId, bool current);
  updateFavouriteAlbum(String albumId, bool current);
  updateFavouriteArtist(String artistId, bool current);
  Future<List<Album>>  returnLatestAlbums();
  Future<List<Artists>> fetchArtists();
  returnSongs();
  returnSongsFromPlaylist(String playlistId);
  addSongToPlaylist(String songId, String playlistId);
  deleteSongFromPlaylist(String songId, String playlistId);
  Future<List<Playlists>> returnPlaylists();
  returnArtistBio(String artistName);
  startPlaybackReporting(String songId, String userId);
  updatePlaybackProgress(String songId, String userId, bool paused, int ticks);
  stopPlaybackReporting(String songId, String userId);
  tryGetArt(String artist, String album);
  uploadArt(String albumId, File image);
  getPlaybackByDays(DateTime inOldDate, DateTime inCurDate);
  getPlaybackByArtists(DateTime inOldDate, DateTime inCurDate);
  getPlaybackForDay(DateTime day);
}