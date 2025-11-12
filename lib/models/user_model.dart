import 'contact_model.dart';

class User {
  String id;
  String name;
  String avatarUrl; 
  List<Contact> contacts;

  User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.contacts,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'contacts': contacts.map((c) => c.toJson()).toList(),
  };
}
