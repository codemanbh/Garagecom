import 'package:flutter/material.dart';

class CarPart {
  String? partName;
  String? itemImagePath;
  String? receiptImagePath;
  int? lastReplaced; // In kilometers
  int? lastReplacedTime; // In months
  String? lastReplacedDate;
  String? nextReplacedDate;
  String? replacementInterval;
  double? lifespanProgress; // Value between 0.0 and 1.0
  String? notes;
  String? warrantyExpiryDate;
  String? storeLocation;
  final int carId; // Car identifier
  int? carPartId; // The ID for this specific car part

  CarPart({
    this.partName,
    this.itemImagePath,
    this.receiptImagePath,
    this.lastReplaced,
    this.lastReplacedTime,
    this.lastReplacedDate,
    this.nextReplacedDate,
    this.replacementInterval,
    this.lifespanProgress,
    this.notes,
    this.warrantyExpiryDate,
    this.storeLocation, 
    required this.carId,
    this.carPartId,
  });
}