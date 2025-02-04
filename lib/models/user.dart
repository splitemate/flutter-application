class User {
  String? get id => _id;
  String? email;
  String? name;
  String? imageUrl;
  String? _id;

  User(
      {
        required this.email,
        required this.name,
        required this.imageUrl
      });

  toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'image_url': imageUrl
  };

  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
        name: json['name'],
        email: json['email'],
        imageUrl: json['image_url'],
    );
    user._id = json['id'];
    return user;
  }

  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
