import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:worklink_local/helpers/apis.dart';

class LegalDocumentMetadata {
  final String documentKey;
  final String format;
  final DateTime? updatedAt;
  final int fileSize;
  final String pdfUrl;

  const LegalDocumentMetadata({
    required this.documentKey,
    required this.format,
    required this.updatedAt,
    required this.fileSize,
    required this.pdfUrl,
  });

  factory LegalDocumentMetadata.fromJson(Map<String, dynamic> json) {
    return LegalDocumentMetadata(
      documentKey: json['document_key']?.toString() ?? '',
      format: json['format']?.toString() ?? '',
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      fileSize: _parseInt(json['file_size']) ?? 0,
      pdfUrl: json['pdf_url']?.toString() ?? '',
    );
  }

  static int? _parseInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class LegalDocumentsService {
  static Future<LegalDocumentMetadata> fetchTermsAndConditionsMetadata() async {
    try {
      final response = await http
          .get(
            Apis.publicTermsAndConditions,
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 20));

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Respuesta invalida del servidor.');
      }

      final success = decoded['success'] == true;
      final data = decoded['data'];
      if (!success || data is! Map<String, dynamic>) {
        throw Exception(
          decoded['message']?.toString() ??
              'No se pudo obtener terminos y condiciones.',
        );
      }

      final metadata = LegalDocumentMetadata.fromJson(data);
      if (metadata.format.toLowerCase() != 'pdf' || metadata.pdfUrl.isEmpty) {
        throw Exception('El documento de terminos no esta disponible en PDF.');
      }

      return metadata;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      if (e is TimeoutException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<void> openTermsAndConditionsPdf(
    LegalDocumentMetadata metadata,
  ) async {
    final resolvedUri = _resolvePdfUri(metadata.pdfUrl);
    final opened = await launchUrl(
      resolvedUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      throw Exception('No se pudo abrir el documento PDF.');
    }
  }

  static Uri _resolvePdfUri(String rawUrl) {
    final parsed = Uri.tryParse(rawUrl);
    if (parsed == null || parsed.host.isEmpty) {
      throw Exception('URL de PDF invalida.');
    }

    final backend = Uri.parse(Apis.baseUrl);
    final host = parsed.host;
    if (host == '127.0.0.1' || host == 'localhost') {
      return parsed.replace(
        scheme: backend.scheme,
        host: backend.host,
        port: backend.hasPort ? backend.port : null,
      );
    }

    return parsed;
  }

  static String formatUpdatedAt(DateTime? date) {
    if (date == null) return '-';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '-';
    if (bytes < 1024) return '$bytes B';

    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';

    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }
}
