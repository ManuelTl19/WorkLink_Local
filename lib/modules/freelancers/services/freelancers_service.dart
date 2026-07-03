import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';

class FreelancersService {
  static const List<FreelancerModel> _mockFreelancers = [
    FreelancerModel(
      id: 1,
      fullName: 'Juan Pérez',
      specialty: 'Flutter Developer',
      rating: 4.8,
      availability: 'Disponible',
      shortDescription: 'Desarrollador móvil especializado en Flutter y Firebase.',
      location: 'Monterrey, México',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
    ),
    FreelancerModel(
      id: 2,
      fullName: 'Mariana López',
      specialty: 'UI/UX Designer',
      rating: 4.9,
      availability: 'Disponible',
      shortDescription: 'Diseño de productos digitales con enfoque en conversión y detalle visual.',
      location: 'Bogotá, Colombia',
      avatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=600&q=80',
    ),
    FreelancerModel(
      id: 3,
      fullName: 'Carlos Medina',
      specialty: 'Node.js Backend',
      rating: 4.7,
      availability: 'Ocupado',
      shortDescription: 'Backend escalable para APIs, automatización y bases de datos relacionales.',
      location: 'Madrid, España',
      avatarUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=600&q=80',
    ),
  ];

  Future<List<FreelancerModel>> getFreelancers() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return List<FreelancerModel>.unmodifiable(_mockFreelancers);
  }

  FreelancerModel? getFreelancerById(int id) {
    for (final freelancer in _mockFreelancers) {
      if (freelancer.id == id) return freelancer;
    }
    return null;
  }
}