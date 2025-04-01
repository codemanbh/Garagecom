class CarPart {
  String? partName;
  String? itemImagePath; // New field
  String? receiptImagePath; // New field
  int? lastReplaced; // In kilometers
  int? lastReplacedTime; // In months
  String? lastReplacedDate;
  String? nextReplacedDate;
  String? replacementInterval;
  double? lifespanProgress; // Value between 0.0 and 1.0
  String? notes;
  String? warrantyExpiryDate;
  String? storeLocation; // New field

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
  });

  int? get replacementIntervalMonths => null;

  set replacementIntervalMonths(int? replacementIntervalMonths) {}
}