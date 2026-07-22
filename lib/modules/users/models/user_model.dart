class UserModel {
  final int id;
  final String nombre;
  final String apellidoP;
  final String apellidoM;
  final String correo;
  final String tipoCuenta;
  final String cargo;
  final String departamento;
  final List<String> roles;
  final String fotoPerfil;
  final String telefono;

  UserModel({
    required this.id,
    required this.nombre,
    required this.apellidoP,
    required this.apellidoM,
    required this.correo,
    required this.tipoCuenta,
    required this.cargo,
    required this.departamento,
    required this.roles,
    required this.fotoPerfil,
    required this.telefono,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Procesar rol(es)
      final rawRoles =
          (json['roles'] as List?) ??
          (json['role'] != null ? [json['role']] : <dynamic>[]);

      final roleNames = rawRoles
          .map((role) {
            if (role is Map<String, dynamic>) {
              return role['name']?.toString() ??
                  role['nombre']?.toString() ??
                  '';
            }
            return role.toString();
          })
          .where((role) => role.trim().isNotEmpty)
          .toList();

      // Priorizar profile_photo_url (URL completa del backend)
      final profilePhotoUrl = (json['profile_photo_url'] ?? '').toString().trim().isNotEmpty
          ? json['profile_photo_url'].toString()
          : (json['profile_photo'] ?? '').toString().trim().isNotEmpty
          ? json['profile_photo'].toString()
          : (json['foto_perfil'] ?? '').toString();

      final roleName = roleNames.isNotEmpty
          ? roleNames.first
          : json['role'] is Map<String, dynamic>
          ? (json['role']['name']?.toString() ??
                json['role']['nombre']?.toString() ??
                '')
          : '';

      return UserModel(
        id: json['id'] ?? 0,
        nombre: json['name'] ?? json['nombre'] ?? '',
        apellidoP: json['last_name'] ?? json['apellidoP'] ?? '',
        apellidoM: json['maternal_last_name'] ?? json['apellidoM'] ?? '',
        correo: json['email'] ?? json['correo'] ?? '',
        tipoCuenta: json['tipo_cuenta'] ?? roleName,
        cargo: json['cargo'] ?? json['puesto'] ?? '',
        departamento: json['departamento'] ?? json['department'] ?? '',
        roles: roleNames,
        fotoPerfil: profilePhotoUrl,
        telefono: json['phone']?.toString() ?? json['telefono'] ?? '',
      );
    } catch (e) {
      throw Exception('Error parsing UserModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidoP': apellidoP,
      'apellidoM': apellidoM,
      'correo': correo,
      'tipo_cuenta': tipoCuenta,
      'cargo': cargo,
      'departamento': departamento,
      'roles': roles,
      'foto_perfil': fotoPerfil,
      'telefono': telefono,
    };
  }
}
