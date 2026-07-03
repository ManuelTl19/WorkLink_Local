import 'package:worklink_local/modules/freelancers/models/freelancer_model.dart';
import 'package:worklink_local/modules/freelancers/services/freelancers_service.dart';
import 'package:worklink_local/modules/portfolio/models/portfolio_model.dart';
import 'package:worklink_local/modules/portfolio/models/project_model.dart';

class PortfolioService {
  static const List<String> _sharedSkills = [
    'Flutter',
    'Dart',
    'Firebase',
    'Node.js',
    'MySQL',
    'REST APIs',
    'Clean Architecture',
    'State Management',
  ];

  static final Map<int, PortfolioModel> _mockPortfolios = {
    1: PortfolioModel(
      freelancerId: 1,
      about:
          'Especialista en desarrollo móvil con enfoque en arquitectura modular, UI de alto rendimiento y entrega continua. Trabaja productos para startups y empresas, priorizando calidad, mantenibilidad y experiencia de usuario.',
      skills: _sharedSkills,
      hourlyRate: r'$45/h',
      experience: '6+ años en desarrollo de producto digital',
      availabilityNote: 'Disponible para proyectos nuevos y contratos a mediano plazo.',
      projects: const [
        ProjectModel(
          id: 101,
          title: 'WorkLink Services',
          description: 'Marketplace para conectar freelancers y clientes.',
          imageUrl:
              'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=900&q=80',
          dateLabel: 'Mar 2026',
          fullDescription:
              'Aplicación móvil con onboarding, catálogo de servicios, publicaciones y solicitudes en tiempo real.',
          technologies: ['Flutter', 'Firebase', 'Dart'],
        ),
        ProjectModel(
          id: 102,
          title: 'Analytics Dashboard',
          description: 'Panel de indicadores para equipos comerciales.',
          imageUrl:
              'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=900&q=80',
          dateLabel: 'Dic 2025',
          fullDescription:
              'Dashboard administrativo con métricas clave, filtros y vistas optimizadas para la toma de decisiones.',
          technologies: ['Node.js', 'MySQL', 'Charts'],
        ),
        ProjectModel(
          id: 103,
          title: 'Booking Flow Mobile',
          description: 'Flujo de reservas con confirmación y pagos.',
          imageUrl:
              'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=900&q=80',
          dateLabel: 'Ago 2025',
          fullDescription:
              'Experiencia de reserva con autenticación, pagos, validación y notificaciones integradas.',
          technologies: ['Flutter', 'Payments', 'Notifications'],
        ),
      ],
    ),
    2: PortfolioModel(
      freelancerId: 2,
      about:
          'Diseñadora de producto enfocada en interfaces claras, consistentes y orientadas a conversión. Combina investigación rápida, sistemas de diseño y validación visual.',
      skills: const [
        'Figma',
        'UI/UX',
        'Design Systems',
        'Prototyping',
        'User Research',
        'Accessibility',
      ],
      hourlyRate: r'$38/h',
      experience: '5+ años en diseño de productos',
      availabilityNote: 'Disponible para nuevas interfaces y rediseño de productos.',
      projects: const [
        ProjectModel(
          id: 201,
          title: 'Brand Refresh App',
          description: 'Rediseño de identidad y experiencia móvil.',
          imageUrl:
              'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=900&q=80',
          dateLabel: 'Feb 2026',
          fullDescription:
              'Actualización completa de interfaz, jerarquía visual y componentes para una app financiera.',
          technologies: ['Figma', 'Design System', 'UX'],
        ),
      ],
    ),
    3: PortfolioModel(
      freelancerId: 3,
      about:
          'Ingeniero backend orientado a APIs robustas, integraciones limpias y persistencia confiable. Diseña estructuras escalables y prepara bases para crecimiento continuo.',
      skills: const ['Node.js', 'Express', 'MySQL', 'REST APIs', 'Docker'],
      hourlyRate: r'$42/h',
      experience: '7+ años en backend y servicios',
      availabilityNote: 'Disponibilidad parcial para integraciones y automatización.',
      projects: const [
        ProjectModel(
          id: 301,
          title: 'Service API Suite',
          description: 'API multirol para operaciones internas.',
          imageUrl:
              'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=900&q=80',
          dateLabel: 'Nov 2025',
          fullDescription:
              'Servicios REST con autenticación, reportes y integración de procesos internos.',
          technologies: ['Node.js', 'MySQL', 'JWT'],
        ),
      ],
    ),
  };

  Future<PortfolioModel> getPortfolioByFreelancerId(int freelancerId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _mockPortfolios[freelancerId] ?? _mockPortfolios[1]!;
  }

  Future<FreelancerModel> getFreelancerById(int freelancerId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return FreelancersService().getFreelancerById(freelancerId) ??
        const FreelancerModel(
          id: 1,
          fullName: 'Juan Pérez',
          specialty: 'Flutter Developer',
          rating: 4.8,
          availability: 'Disponible',
          shortDescription: 'Desarrollador móvil especializado en Flutter y Firebase.',
          location: 'Monterrey, México',
          avatarUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
        );
  }
}