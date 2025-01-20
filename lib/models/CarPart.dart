class CarPart {
  int? partID;
  String? partName;
  int? lastReplaced;
  int? lifeTime;
  bool needReplacment = false;

  CarPart({this.partName, this.lastReplaced});
}
