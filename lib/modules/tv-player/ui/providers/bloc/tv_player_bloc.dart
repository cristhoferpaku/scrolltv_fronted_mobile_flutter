import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tv_player_bloc.freezed.dart';
part 'tv_player_event.dart';
part 'tv_player_state.dart';

class TvPlayerBloc extends Bloc<TvPlayerEvent, TvPlayerState> {
  TvPlayerBloc() : super(TvPlayerState(status: TVPlayerStatus.initial, channels: [], selectedChannelIndex: 0)) {
    final List<Map<String, String>> channels = [
      {'name': 'BBC NEWS', 'subtitle': 'Noticias internacionales'},
      {'name': 'ESPN', 'subtitle': 'Deportes en vivo'},
      {'name': 'CNN', 'subtitle': 'Noticias 24/7'},
      {'name': 'Televisa', 'subtitle': 'Entretenimiento'},
      {'name': 'Discovery', 'subtitle': 'Documentales'},
      {'name': 'National Geographic', 'subtitle': 'Naturaleza'},
      {'name': 'HBO', 'subtitle': 'Películas y series'},
      {'name': 'Disney Channel', 'subtitle': 'Entretenimiento familiar'},
      {'name': 'MTV', 'subtitle': 'Música y entretenimiento'},
      {'name': 'History Channel', 'subtitle': 'Historia y documentales'},
      {'name': 'Cartoon Network', 'subtitle': 'Animación'},
      {'name': 'Fox Sports', 'subtitle': 'Deportes'},
      {'name': 'Animal Planet', 'subtitle': 'Mundo animal'},
      {'name': 'AXN', 'subtitle': 'Series y películas'},
      {'name': 'Nickelodeon', 'subtitle': 'Infantil'},
      {'name': 'Warner Channel', 'subtitle': 'Series y películas'},
      {'name': 'Food Network', 'subtitle': 'Cocina y gastronomía'},
      {'name': 'Comedy Central', 'subtitle': 'Comedia'},
      {'name': 'Universal Channel', 'subtitle': 'Entretenimiento variado'},
      {'name': 'Sony Channel', 'subtitle': 'Series y películas'},
      {'name': 'Space', 'subtitle': 'Ciencia ficción'},
      {'name': 'TNT', 'subtitle': 'Películas'},
      {'name': 'Cinemax', 'subtitle': 'Cine'},
      {'name': 'TCM', 'subtitle': 'Cine clásico'},
      {'name': 'Syfy', 'subtitle': 'Ciencia ficción'},
      {'name': 'Paramount Channel', 'subtitle': 'Películas'},
      {'name': 'BBC NEWS', 'subtitle': 'Noticias internacionales'},
      {'name': 'ESPN', 'subtitle': 'Deportes en vivo'},
      {'name': 'CNN', 'subtitle': 'Noticias 24/7'},
      {'name': 'Televisa', 'subtitle': 'Entretenimiento'},
      {'name': 'Discovery', 'subtitle': 'Documentales'},
      {'name': 'National Geographic', 'subtitle': 'Naturaleza'},
      {'name': 'HBO', 'subtitle': 'Películas y series'},
      {'name': 'Disney Channel', 'subtitle': 'Entretenimiento familiar'},
      {'name': 'MTV', 'subtitle': 'Música y entretenimiento'},
      {'name': 'History Channel', 'subtitle': 'Historia y documentales'},
      {'name': 'Cartoon Network', 'subtitle': 'Animación'},
      {'name': 'Fox Sports', 'subtitle': 'Deportes'},
      {'name': 'Animal Planet', 'subtitle': 'Mundo animal'},
      {'name': 'AXN', 'subtitle': 'Series y películas'},
      {'name': 'Nickelodeon', 'subtitle': 'Infantil'},
      {'name': 'Warner Channel', 'subtitle': 'Series y películas'},
      {'name': 'Food Network', 'subtitle': 'Cocina y gastronomía'},
      {'name': 'Comedy Central', 'subtitle': 'Comedia'},
      {'name': 'Universal Channel', 'subtitle': 'Entretenimiento variado'},
      {'name': 'Sony Channel', 'subtitle': 'Series y películas'},
      {'name': 'Space', 'subtitle': 'Ciencia ficción'},
      {'name': 'TNT', 'subtitle': 'Películas'},
      {'name': 'Cinemax', 'subtitle': 'Cine'},
      {'name': 'TCM', 'subtitle': 'Cine clásico'},
      {'name': 'Syfy', 'subtitle': 'Ciencia ficción'},
      {'name': 'Paramount Channel', 'subtitle': 'Películas'}
    ];

    int selectedChannelIndex = 0;
    on<TvPlayerEvent>((event, emit) {});
    on<_TVPlayerEventStarted>((event, emit) {
      emit(state.copyWith(status: TVPlayerStatus.loading, channels: channels, selectedChannelIndex: selectedChannelIndex));
    });
    on<_TVPlayerEventChangeChannel>((event, emit) {
      selectedChannelIndex = event.channelIndex;
      emit(state.copyWith(selectedChannelIndex: selectedChannelIndex));
    });
  }
}
