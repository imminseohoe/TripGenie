class Profile {
  final int id;
  final String name;
  final String language;

  Profile({required this.id, required this.name, required this.language});

  Profile.fromUserInput(String name, String language)
      : this(id: 0, name: name, language: language);

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'language': language};
  }
}
