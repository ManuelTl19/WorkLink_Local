class UserModel {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String tipoCuenta;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.tipoCuenta,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id'] ?? 0,
        nombre: json['nombre'] ?? '',
        apellido: json['apellido'] ?? '',
        email: json['email'] ?? '',
        tipoCuenta: json['tipo_cuenta'] ?? '',
        roles:
            (json['roles'] as List?)
                ?.map((role) => role['nombre'].toString())
                .toList() ??
            [],
      );
    } catch (e) {
      throw Exception('Error parsing UserModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'tipo_cuenta': tipoCuenta,
      'roles': roles,
    };
  }
}
