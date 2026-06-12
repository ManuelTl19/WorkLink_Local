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

  static final String baseUrl = 'http://192.168.1.11:8000';
  static final String accessKey = '-';
  // ---- Auth ----

  // Login
  static final Uri login = Uri.parse('$baseUrl/api/login');
  
}
