class CarPart {
  String? partName;
  String? imagePath;
  int? lastReplaced; // In kilometers
  int? lastReplacedTime; // In months
  String? lastReplacedDate;
  String? nextReplacedDate;
  String? replacementInterval; // New field
  double? lifespanProgress; // New field (value between 0.0 and 1.0)

  CarPart({
    this.partName,
    this.imagePath,
    this.lastReplaced,
    this.lastReplacedTime,
    this.lastReplacedDate,
    this.nextReplacedDate,
    this.replacementInterval,
    this.lifespanProgress,
  });
}