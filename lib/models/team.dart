class Team {
  final String name;
  final String nickname;
  final String city;
  final String category;

  Team({
    required this.name,
    required this.nickname,
    required this.city,
    required this.category,
  });

  Team copyWith({
    String? name,
    String? nickname,
    String? city,
    String? category,
  }) {
    return Team(
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      city: city ?? this.city,
      category: category ?? this.category,
    );
  }
}