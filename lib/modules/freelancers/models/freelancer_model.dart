class FreelancerModel {
  final int id;
  final String fullName;
  final String specialty;
  final double rating;
  final String availability;
  final String shortDescription;
  final String location;
  final String avatarUrl;

  const FreelancerModel({
    required this.id,
    required this.fullName,
    required this.specialty,
    required this.rating,
    required this.availability,
    required this.shortDescription,
    required this.location,
    required this.avatarUrl,
  });
}