class Location {
  final int id;
  final String name;

  Location(this.id, this.name);

  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}


class Commodity {
  final int id;
  final String name;

  Commodity(this.id, this.name);
  
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Commodity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}