class Apis {
  /// Codes for common errors and successes:

  /// Common errors:
  ///- 500: External server error
  ///- 401: Unauthorized
  ///- 404: Not found
  ///- 405: Method not allowed
  ///- 400: Validation error

  /// Success codes:
  ///- 200: Ok
  ///- 204: No content

  static int successCode = 200;

  static final String baseUrl = 'http://192.168.1.10:8000';
  static final String accessKey = '-';
  // ---- Auth ----

  // Login
  static final Uri login = Uri.parse('$baseUrl/api/login');

  static final Uri register = Uri.parse('$baseUrl/api/register');

  // ---- Users ----
  static Uri userById(int id) => Uri.parse('$baseUrl/api/users/$id');
  static final Uri userMe = Uri.parse('$baseUrl/api/users/me');
  static final Uri userMeProfilePhoto = Uri.parse(
    '$baseUrl/api/users/me/profile-photo',
  );

  // ---- Freelancer Professional Profile ----
  static final Uri profiles = Uri.parse('$baseUrl/api/profiles');

  static Uri profileById(int id) => Uri.parse('$baseUrl/api/profiles/$id');

  static Uri profileByUserId(int userId) =>
      Uri.parse('$baseUrl/api/profiles/user/$userId');

  // ---- Freelancer Portfolio (Briefcases) ----
  static final Uri briefcases = Uri.parse('$baseUrl/api/briefcases');
  static final Uri briefcasesMe = Uri.parse('$baseUrl/api/briefcases/me');
  static Uri briefcasesByFreelancerId(int freelancerId) =>
      Uri.parse('$baseUrl/api/briefcases/freelancer/$freelancerId');

  static Uri briefcaseById(int id) => Uri.parse('$baseUrl/api/briefcases/$id');
  static Uri briefcaseImageById(int id) =>
      Uri.parse('$baseUrl/api/briefcases/$id/image');

  // ---- Freelancer Services ----
  static final Uri services = Uri.parse('$baseUrl/api/services');

  static Uri servicesByFreelancerId(int freelancerId) =>
      Uri.parse('$baseUrl/api/services/freelancer/$freelancerId');

  static Uri serviceById(int id) => Uri.parse('$baseUrl/api/services/$id');

  // ---- Freelancer Availability ----
  static final Uri availabilities = Uri.parse('$baseUrl/api/availabilities');

  static Uri availabilityById(int id) =>
      Uri.parse('$baseUrl/api/availabilities/$id');

  // ---- Public Legal Documents ----
  static final Uri publicTermsAndConditions = Uri.parse(
    '$baseUrl/api/public/legal/terms-and-conditions',
  );
  static final Uri publicTermsAndConditionsPdf = Uri.parse(
    '$baseUrl/api/public/legal/terms-and-conditions/pdf',
  );
}
