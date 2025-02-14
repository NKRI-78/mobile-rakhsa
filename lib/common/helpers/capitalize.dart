extension StringExtensions on String {
  String capitalizeEachWord() {
    return trim().split(RegExp(r'\s+')).map((word) {
      if (word.toUpperCase() == word) return word; // Tetap pertahankan singkatan
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }
}