class HomepageModel {
  String selectedDifficulty = 'Medium'; // Default difficulty
  String selectedTheme = 'Light'; // Default difficulty
  List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  List<String> themes = ['Light', 'Dark'];

  void setDifficulty(String difficulty) {
    selectedDifficulty = difficulty;
  }

  void setTheme(String theme) {
    selectedTheme = theme;
  }
}