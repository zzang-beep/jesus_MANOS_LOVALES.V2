class ChatContact {
  final String userId;
  final String name;
  final String photoUrl;
  final String bio;
  final String zone;

  const ChatContact({
    required this.userId,
    required this.name,
    this.photoUrl = '',
    this.zone = '',
    this.bio = '',
  });

  factory ChatContact.fromMap(Map<String, dynamic> map) {
    return ChatContact(
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      zone: map['zone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'photoUrl': photoUrl,
      'bio': bio,
      'zone': zone,
    };
  }
}
