class Club {
  final String id;
  final String name;
  final String description;
  final String category;
  final String presidentId;
  final String presidentName;
  final int memberCount;
  final String? logoUrl;
  final String? socialLinks;
  final String status;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.presidentId,
    required this.presidentName,
    required this.memberCount,
    this.logoUrl,
    this.socialLinks,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'president_id': presidentId,
      'president_name': presidentName,
      'member_count': memberCount,
      'logo_url': logoUrl,
      'social_links': socialLinks,
      'status': status,
    };
  }

  factory Club.fromMap(Map<String, dynamic> map) {
    return Club(
      id: map['id'].toString(),
      name: map['name'].toString(),
      description: map['description'].toString(),
      category: map['category'].toString(),
      presidentId: map['president_id'].toString(),
      presidentName: map['president_name'].toString(),
      memberCount: map['member_count'] as int,
      logoUrl: map['logo_url']?.toString(),
      socialLinks: map['social_links']?.toString(),
      status: map['status']?.toString() ?? 'active',
    );
  }

  Club copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? presidentId,
    String? presidentName,
    int? memberCount,
    String? logoUrl,
    String? socialLinks,
    String? status,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      presidentId: presidentId ?? this.presidentId,
      presidentName: presidentName ?? this.presidentName,
      memberCount: memberCount ?? this.memberCount,
      logoUrl: logoUrl ?? this.logoUrl,
      socialLinks: socialLinks ?? this.socialLinks,
      status: status ?? this.status,
    );
  }
}