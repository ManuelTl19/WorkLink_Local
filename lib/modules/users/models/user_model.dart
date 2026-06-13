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
      final rawRoles = (json['roles'] as List?) ?? [];

      return UserModel(
        id: json['id'] ?? 0,
        nombre: json['nombre'] ?? '',
        apellidoP: json['apellidoP'] ?? '',
        apellidoM: json['apellidoM'] ?? '',
        correo: json['correo'] ?? '',
        tipoCuenta: json['tipo_cuenta'] ?? '',
        cargo: json['cargo'] ?? json['puesto'] ?? '',
        departamento: json['departamento'] ?? json['department'] ?? '',
        roles: rawRoles
            .map((role) {
              if (role is Map<String, dynamic>) {
                return role['nombre']?.toString() ?? '';
              }
              return role.toString();
            })
            .where((role) => role.trim().isNotEmpty)
            .toList(),
        fotoPerfil: json['foto_perfil'] ?? '',
        telefono: json['telefono'] ?? '',
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
