class CarPart {
  int? partID;
  String? partName;
  int? lastReplaced;
  int? lifeTime;
  bool needReplacment = false;

  CarPart({this.partName, this.lastReplaced});

  set imagePath(String imagePath) {}

  set replacementInterval(int replacementInterval) {}

  set lastReplacedTime(int lastReplacedTime) {}
}
