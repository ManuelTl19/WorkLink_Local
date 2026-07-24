import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:worklink_local/helpers/apis.dart';
import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/reviews/models/review_model.dart';

class ReviewsFlowException implements Exception {
  final int? statusCode;
  final String message;

  const ReviewsFlowException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ReviewsService {
  static Future<List<ReviewModel>> listMyReviews() async {
    return _fetchReviews(Apis.reviews, authorized: true);
  }

  static Future<List<ReviewModel>> listReviewsForUser(int userId) async {
    return _fetchReviews(Apis.publicReviewsByUserId(userId), authorized: false);
  }

  static Future<List<ReviewModel>> listReviewsForFreelancer(int freelancerId) async {
    return _fetchReviews(Apis.publicReviewsByFreelancerId(freelancerId), authorized: false);
  }

  static Future<List<ReviewModel>> listReviewsForCompany(int companyId) async {
    return _fetchReviews(Apis.publicReviewsByCompanyId(companyId), authorized: false);
  }

  static Future<ReviewModel?> getReviewById(int id) async {
    try {
      final response = await _authorizedGet(Apis.reviewById(id));
      final body = _decodeBody(response.body);

      if (!_isSuccessful(response.statusCode, body)) {
        throw ReviewsFlowException(
          _extractMessage(body, 'No se pudo obtener la reseña.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isEmpty) return null;
      return ReviewModel.fromJson(data);
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is ReviewsFlowException) rethrow;
      throw ReviewsFlowException(_normalizeError(e));
    }
  }

  static Future<ReviewModel> createReview({
    required int contractId,
    required int reviewedUserId,
    required String reviewedUserName,
    required String reviewedUserType,
    required double rating,
    required String comment,
    String reviewerName = 'Tú',
    String reviewerAvatarUrl = '',
    bool isPublic = true,
  }) async {
    try {
      final trimmedComment = comment.trim();
      if (rating < 1 || rating > 5) {
        throw ReviewsFlowException('La calificación debe estar entre 1 y 5.');
      }

      final response = await _authorizedPost(
        Apis.reviews,
        body: jsonEncode({
          'contract_id': contractId,
          'reviewed_user_id': reviewedUserId,
          'reviewed_user_name': reviewedUserName,
          'reviewed_user_type': reviewedUserType,
          'reviewer_name': reviewerName,
          'reviewer_avatar_url': reviewerAvatarUrl,
          'rating': rating,
          'comment': trimmedComment,
          'is_public': isPublic,
        }),
      );

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw ReviewsFlowException(
          _extractMessage(body, 'No se pudo enviar la reseña.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) return ReviewModel.fromJson(data);

      return ReviewModel(
        id: 0,
        contractId: contractId,
        reviewerId: 0,
        reviewerName: reviewerName,
        reviewerAvatarUrl: reviewerAvatarUrl,
        reviewedUserId: reviewedUserId,
        reviewedUserName: reviewedUserName,
        reviewedUserType: reviewedUserType,
        rating: rating,
        comment: trimmedComment,
        isPublic: isPublic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is ReviewsFlowException) rethrow;
      throw ReviewsFlowException(_normalizeError(e));
    }
  }

  static Future<ReviewModel> updateReview({
    required int reviewId,
    required double rating,
    required String comment,
    bool? isPublic,
  }) async {
    try {
      final response = await _authorizedPatch(
        Apis.reviewById(reviewId),
        body: jsonEncode({
          'rating': rating,
          'comment': comment.trim(),
          if (isPublic != null) 'is_public': isPublic,
        }),
      );

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw ReviewsFlowException(
          _extractMessage(body, 'No se pudo actualizar la reseña.'),
          statusCode: response.statusCode,
        );
      }

      final data = _extractDataMap(body);
      if (data.isNotEmpty) return ReviewModel.fromJson(data);

      final existing = await getReviewById(reviewId);
      if (existing != null) {
        return existing.copyWith(
          rating: rating,
          comment: comment.trim(),
          isPublic: isPublic ?? existing.isPublic,
          updatedAt: DateTime.now(),
        );
      }

      throw ReviewsFlowException('No se pudo reconstruir la reseña actualizada.');
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is ReviewsFlowException) rethrow;
      throw ReviewsFlowException(_normalizeError(e));
    }
  }

  static Future<void> deleteReview(int reviewId) async {
    try {
      final response = await _authorizedDelete(Apis.reviewById(reviewId));
      if (response.statusCode == 204) return;

      final body = _decodeBody(response.body);
      if (!_isSuccessful(response.statusCode, body)) {
        throw ReviewsFlowException(
          _extractMessage(body, 'No se pudo eliminar la reseña.'),
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is ReviewsFlowException) rethrow;
      throw ReviewsFlowException(_normalizeError(e));
    }
  }

  static Future<List<ReviewModel>> _fetchReviews(
    Uri uri, {
    required bool authorized,
  }) async {
    try {
      final response = authorized
          ? await _authorizedGet(uri)
          : await _publicGet(uri);
      final body = _decodeBody(response.body);

      if (!_isSuccessful(response.statusCode, body)) {
        throw ReviewsFlowException(
          _extractMessage(body, 'No se pudieron cargar las reseñas.'),
          statusCode: response.statusCode,
        );
      }

      return _extractDataList(body).map(ReviewModel.fromJson).toList();
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is ReviewsFlowException) rethrow;
      throw ReviewsFlowException(_normalizeError(e));
    }
  }

  static Future<http.Response> _publicGet(Uri uri) {
    return http.get(uri).timeout(const Duration(seconds: 20));
  }

  static Future<http.Response> _authorizedGet(Uri uri) async {
    final headers = await _headers();
    return http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
  }

  static Future<http.Response> _authorizedPost(
    Uri uri, {
    required String body,
  }) async {
    final headers = await _headers();
    return http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));
  }

  static Future<http.Response> _authorizedPatch(
    Uri uri, {
    required String body,
  }) async {
    final headers = await _headers();
    return http
        .patch(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));
  }

  static Future<http.Response> _authorizedDelete(Uri uri) async {
    final headers = await _headers();
    return http.delete(uri, headers: headers).timeout(const Duration(seconds: 20));
  }

  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.trim().isEmpty) {
      throw const ReviewsFlowException('No se encontró un token de acceso.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) return const <String, dynamic>{};
    try {
      return jsonDecode(body);
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  static bool _isSuccessful(int statusCode, dynamic body) {
    if (statusCode >= 200 && statusCode < 300) return true;
    if (body is Map<String, dynamic>) {
      final success = body['success'];
      if (success is bool) return success;
    }
    return false;
  }

  static List<Map<String, dynamic>> _extractDataList(dynamic body) {
    if (body is List) {
      return body.whereType<Map<String, dynamic>>().toList();
    }

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();

      final items = body['items'];
      if (items is List) return items.whereType<Map<String, dynamic>>().toList();

      final reviews = body['reviews'];
      if (reviews is List) return reviews.whereType<Map<String, dynamic>>().toList();
    }

    return const <Map<String, dynamic>>[];
  }

  static Map<String, dynamic> _extractDataMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;

      final result = body['result'];
      if (result is Map<String, dynamic>) return result;

      return body;
    }

    return const <String, dynamic>{};
  }

  static String _extractMessage(dynamic body, String fallback) {
    if (body is Map<String, dynamic>) {
      final message = body['message'] ?? body['error'] ?? body['detail'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return fallback;
  }

  static String _normalizeError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}