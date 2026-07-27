import 'package:flutter/material.dart';

/// Temporary fixture/presentation model for Milestone 002 static UI. Not an
/// authoritative domain contract — Milestone 003 defines parsing,
/// normalization, duplicate identity and persistence models separately.
class ResultFieldFixture {
  const ResultFieldFixture({
    required this.label,
    required this.value,
    this.icon,
    this.masked = false,
    this.monospace = false,
  });

  final String label;
  final String value;
  final IconData? icon;

  /// True for values (e.g. a Wi-Fi password) that should render as masked
  /// dots by default with a local reveal toggle.
  final bool masked;

  /// True for values best read in a monospace face (identifiers, raw
  /// technical fields).
  final bool monospace;
}
