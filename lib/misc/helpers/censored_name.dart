String censorName(String name) {
  if (name.length <= 2) {
    return name;
  }

  String start = name.substring(0, 2);
  String end = name.substring(name.length - 1);
  
  String censoredPart = '*' * (name.length - 3);

  return start + censoredPart + end;
}