class CompanyFiltersModel {
  final String query;
  final String industry;
  final String location;

  const CompanyFiltersModel({
    this.query = '',
    this.industry = 'Todas',
    this.location = 'Todas',
  });

  CompanyFiltersModel copyWith({
    String? query,
    String? industry,
    String? location,
  }) {
    return CompanyFiltersModel(
      query: query ?? this.query,
      industry: industry ?? this.industry,
      location: location ?? this.location,
    );
  }
}
