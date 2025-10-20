import 'package:equatable/equatable.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/data/model/player_icon_model.dart';

class OnboardingState extends Equatable {
  final BaseCubitState cubitState;
  final List<PlayerIconModel> playerIcons;
  final String nickname;
  final PlayerIconModel? selectedPlayerIcon;
  final List<Language> langauges;
  final List<Language>? selectedLanguage;
  final bool canProceed;

  const OnboardingState({
    required this.cubitState,
    required this.playerIcons,
    this.nickname = '',
    this.selectedPlayerIcon,
    required this.langauges,
    this.selectedLanguage,
    this.canProceed = false,
  });

  OnboardingState copyWith({
    BaseCubitState? cubitState,
    List<PlayerIconModel>? playerIcons,
    PlayerIconModel? selectedPlayerIcon,
    List<Language>? langauges,
    List<Language>? selectedLanguage,
    String? nickname,
    bool? canProceed,
  }) {
    return OnboardingState(
      cubitState: cubitState ?? this.cubitState,
      playerIcons: playerIcons ?? this.playerIcons,
      selectedPlayerIcon: selectedPlayerIcon ?? this.selectedPlayerIcon,
      langauges: langauges ?? this.langauges,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      nickname: nickname ?? this.nickname,
      canProceed: canProceed ?? this.canProceed,
    );
  }

  @override
  List<Object?> get props => [
    cubitState,
    playerIcons,
    selectedPlayerIcon,
    langauges,
    selectedLanguage,
    nickname,
    canProceed,
  ];
}

class Language {
  final int id;
  final String name;

  Language({required this.id, required this.name});

  static List<Language> getAllLanguages() {
    return [
      Language(id: 1, name: 'English'),
      Language(id: 2, name: 'chiShona'),
      Language(id: 3, name: 'isiNdebele'),
    ];
  }
}
