class Contact {
  String name;
  String relation;
  String avatarUrl;

  Contact({required this.name, required this.relation, required this.avatarUrl});

  Map<String, dynamic> toJson() => {
    'name': name,
    'relation': relation,
    'avatarUrl': avatarUrl,
  };
}
