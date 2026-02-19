class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.role = 'USER',
    required this.preferences,
  });

  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String role;
  final UserPreferences preferences;

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  UserProfile copyWith({
    String? name,
    String? phone,
    UserPreferences? preferences,
  }) {
    return UserProfile(
      id: id,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role,
      preferences: preferences ?? this.preferences,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'USER',
      preferences: UserPreferences.fromJson(
        json['preferences'] is Map<String, dynamic>
            ? json['preferences'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
    );
  }
}

class UserPreferences {
  UserPreferences({
    required this.genres,
    required this.languages,
    required this.moods,
  });

  final List<String> genres;
  final List<String> languages;
  final List<String> moods;

  bool get isEmpty => genres.isEmpty && languages.isEmpty && moods.isEmpty;

  factory UserPreferences.empty() =>
      UserPreferences(genres: [], languages: [], moods: []);

  UserPreferences copyWith({
    List<String>? genres,
    List<String>? languages,
    List<String>? moods,
  }) {
    return UserPreferences(
      genres: genres ?? this.genres,
      languages: languages ?? this.languages,
      moods: moods ?? this.moods,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genres': genres,
      'languages': languages,
      'moods': moods,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    List<String> parseList(String key) {
      final value = json[key];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return <String>[];
    }

    return UserPreferences(
      genres: parseList('genres'),
      languages: parseList('languages'),
      moods: parseList('moods'),
    );
  }
}
