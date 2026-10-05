import 'package:equatable/equatable.dart';

class WorkspaceModel extends Equatable {
  final int id;
  final String tenantId;
  final String name;
  final String slug;
  final int memberCount;
  final String myRole;
  final String? teamSize;
  final String? industry;
  final String? description;
  final String? location;

  const WorkspaceModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.slug,
    this.memberCount = 1,
    this.myRole = 'employee',
    this.teamSize,
    this.industry,
    this.description,
    this.location,
  });

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>?;
    return WorkspaceModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      tenantId: json['tenant_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Workspace',
      slug: json['slug'] as String? ?? '',
      memberCount: json['member_count'] is int
          ? json['member_count'] as int
          : int.tryParse(json['member_count']?.toString() ?? '1') ?? 1,
      myRole: json['my_role'] as String? ?? 'employee',
      teamSize: info?['team_size']?.toString(),
      industry: info?['industry'] as String?,
      description: info?['description'] as String?,
      location: info?['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'slug': slug,
      'member_count': memberCount,
      'my_role': myRole,
    };
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        name,
        slug,
        memberCount,
        myRole,
        teamSize,
        industry,
        description,
        location,
      ];
}
