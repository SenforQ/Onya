class FigureModel {
  final String figureName;
  final String userIcon;
  final List<String> showPhotoArray;
  final String showMotto;
  final int showFollowNum;
  final int showLike;
  final String showSayhi;
  final List<String> likeMusicStyleArray;

  FigureModel({
    required this.figureName,
    required this.userIcon,
    required this.showPhotoArray,
    required this.showMotto,
    required this.showFollowNum,
    required this.showLike,
    required this.showSayhi,
    required this.likeMusicStyleArray,
  });

  factory FigureModel.fromJson(Map<String, dynamic> json) {
    return FigureModel(
      figureName: json['OnyaFigureName'] as String,
      userIcon: json['OnyaUserIcon'] as String,
      showPhotoArray: (json['OnyaShowPhotoArray'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      showMotto: json['OnyaShowMotto'] as String,
      showFollowNum: json['OnyaShowFollowNum'] as int,
      showLike: json['OnyaShowLike'] as int,
      showSayhi: json['OnyaShowSayhi'] as String,
      likeMusicStyleArray: (json['OnyaLikeMusicStyleArray'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

