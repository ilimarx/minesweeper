// Author: Ilia Markelov (xmarke00)

/// Represents the model for the homepage.
/// Stores user-selected preferences for difficulty and theme.
class HomepageModel {
  String selectedDifficulty = 'Medium'; // Default difficulty level.
  String selectedTheme = 'Light'; // Default theme.

  // Available difficulty options.
  List<String> difficulties = ['Easy', 'Medium', 'Hard'];

  // Available theme options.
  List<String> themes = ['Light', 'Dark'];

  /// Sets the selected difficulty.
  /// [difficulty] - The chosen difficulty level.
  void setDifficulty(String difficulty) {
    selectedDifficulty = difficulty;
  }

  /// Sets the selected theme.
  /// [theme] - The chosen theme.
  void setTheme(String theme) {
    selectedTheme = theme;
  }
}
