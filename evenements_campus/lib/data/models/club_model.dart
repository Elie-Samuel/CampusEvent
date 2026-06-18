import '../../domain/entities/club.dart';

class ClubModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String presidentId;
  final String presidentName;
  final int memberCount;
  final String? logoUrl;
  final String? socialLinks;

  ClubModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.presidentId,
    required this.presidentName,
    required this.memberCount,
    this.logoUrl,
    this.socialLinks,
  });

  factory ClubModel.fromMap(Map<String, dynamic> map) {
    return ClubModel(
      id: map['id'].toString(),
      name: map['name'].toString(),
      description: map['description'].toString(),
      category: map['category'].toString(),
      presidentId: map['president_id'].toString(),
      presidentName: map['president_name'].toString(),
      memberCount: map['member_count'] as int,
      logoUrl: map['logo_url']?.toString(),
      socialLinks: map['social_links']?.toString(),
    );
  }

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
    };
  }

  Club toDomain() {
    return Club(
      id: id,
      name: name,
      description: description,
      category: category,
      presidentId: presidentId,
      presidentName: presidentName,
      memberCount: memberCount,
      logoUrl: logoUrl,
      socialLinks: socialLinks,
    );
  }

  factory ClubModel.fromDomain(Club club) {
    return ClubModel(
      id: club.id,
      name: club.name,
      description: club.description,
      category: club.category,
      presidentId: club.presidentId,
      presidentName: club.presidentName,
      memberCount: club.memberCount,
      logoUrl: club.logoUrl,
      socialLinks: club.socialLinks,
    );
  }
}