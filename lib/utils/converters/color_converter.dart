import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// Permite serializar y deserializar objetos [Color] como enteros (ARGB)
class ColorConverter implements JsonConverter<Color?, int?> {
  const ColorConverter();

  @override
  Color? fromJson(int? json) => json != null ? Color(json) : null;

  @override
  int? toJson(Color? object) => object?.value;
}
