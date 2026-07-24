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

  // ---- Contract Requests ----
  static final Uri contractRequests = Uri.parse(
    '$baseUrl/api/contract-requests',
  );

  static Uri contractRequestById(int id) =>
      Uri.parse('$baseUrl/api/contract-requests/$id');

  static Uri serviceContractRequestsByServiceId(int id) =>
      Uri.parse('$baseUrl/api/service/contractRequest/$id');

  // ---- Contracts ----
  static final Uri contracts = Uri.parse('$baseUrl/api/contracts');

  static Uri contractById(int id) => Uri.parse('$baseUrl/api/contracts/$id');

  // ---- Reviews ----
  static final Uri reviews = Uri.parse('$baseUrl/api/reviews');

  static Uri reviewById(int id) => Uri.parse('$baseUrl/api/reviews/$id');

  static Uri publicReviewsByUserId(int userId) =>
      Uri.parse('$baseUrl/api/public/reviews/user/$userId');

  static Uri publicReviewsByFreelancerId(int freelancerId) =>
      Uri.parse('$baseUrl/api/public/reviews/freelancer/$freelancerId');

  static Uri publicReviewsByCompanyId(int companyId) =>
      Uri.parse('$baseUrl/api/public/reviews/company/$companyId');

  // ---- Applications ----
  static final Uri applications = Uri.parse('$baseUrl/api/applications');

  static final Uri applicationsMe = Uri.parse('$baseUrl/api/applications/me');

  static Uri applicationsByVacancyId(int vacancyId) =>
      Uri.parse('$baseUrl/api/applications/vacancy/$vacancyId');

  static Uri applicationById(int id) =>
      Uri.parse('$baseUrl/api/applications/$id');

  // ---- Messages ----
  static final Uri messages = Uri.parse('$baseUrl/api/messages');
  static final Uri messageConversations = Uri.parse(
    '$baseUrl/api/messages/conversations',
  );

  static Uri messageConversationByUserId(int userId) =>
      Uri.parse('$baseUrl/api/messages/conversation/$userId');

  static Uri messageReadAllByUserId(int userId) =>
      Uri.parse('$baseUrl/api/messages/read-all/$userId');

  static Uri messageReadById(int id) =>
      Uri.parse('$baseUrl/api/messages/$id/read');

  static Uri messageById(int id) => Uri.parse('$baseUrl/api/messages/$id');

  // ---- Chatbot ----
  static final Uri chatbotMessage = Uri.parse('$baseUrl/api/chatbot/message');

  static final Uri chatbotAuthMessage = Uri.parse(
    '$baseUrl/api/chatbot/auth-message',
  );

  // ---- Notifications ----
  static final Uri notifications = Uri.parse('$baseUrl/api/notifications');

  static final Uri notificationsUnreadCount = Uri.parse(
    '$baseUrl/api/notifications/unread-count',
  );

  static Uri notificationById(int id) =>
      Uri.parse('$baseUrl/api/notifications/$id');

  static Uri notificationReadById(int id) =>
      Uri.parse('$baseUrl/api/notifications/$id/read');

  static final Uri notificationsReadAll = Uri.parse(
    '$baseUrl/api/notifications/read-all',
  );

  // ---- Vacancies ----
  static final Uri publicVacancies = Uri.parse('$baseUrl/api/public/vacancies');

  static Uri publicVacancyById(int id) =>
      Uri.parse('$baseUrl/api/public/vacancies/$id');

  static Uri publicVacanciesByCompanyId(int companyId) =>
      Uri.parse('$baseUrl/api/public/vacancies/company/$companyId');

  static final Uri vacancies = Uri.parse('$baseUrl/api/vacancies');

  static final Uri vacanciesMe = Uri.parse('$baseUrl/api/vacancies/me');

  static Uri vacancyById(int id) => Uri.parse('$baseUrl/api/vacancies/$id');

  // ---- Company Profiles ----
  static final Uri publicCompanyProfiles = Uri.parse(
    '$baseUrl/api/public/company-profiles',
  );

  static Uri publicCompanyProfileById(int id) =>
      Uri.parse('$baseUrl/api/public/company-profiles/$id');

  static final Uri companyProfiles = Uri.parse('$baseUrl/api/company-profiles');

  static final Uri companyProfilesMe = Uri.parse(
    '$baseUrl/api/company-profiles/me',
  );

  static Uri companyProfileById(int id) =>
      Uri.parse('$baseUrl/api/company-profiles/$id');

  // ---- Reports ----
  static final Uri reports = Uri.parse('$baseUrl/api/reports');

  static final Uri reportsSummary = Uri.parse('$baseUrl/api/reports/summary');

  static Uri reportById(int id) => Uri.parse('$baseUrl/api/reports/$id');

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
